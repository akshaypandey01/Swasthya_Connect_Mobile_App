import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/config/api_config.dart';
import '../../core/services/api_client.dart';
import '../models/api_response.dart';
import '../models/triage_session_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRIAGE API SERVICE PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final triageApiServiceProvider = Provider<TriageApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TriageApiService(apiClient: apiClient);
});

// ═══════════════════════════════════════════════════════════════════════════
// TRIAGE API SERVICE
// ═══════════════════════════════════════════════════════════════════════════

/// Triage API Service
/// 
/// Handles communication with the backend triage API:
/// - POST /api/triage/start - Start AI triage session
/// - POST /api/triage/next-question - Get adaptive next question
/// - POST /api/triage/submit - Submit triage and get risk assessment
class TriageApiService {
  final ApiClient apiClient;
  final Logger _logger = Logger();

  TriageApiService({required this.apiClient});

  // ═════════════════════════════════════════════════════════════════════════
  // START TRIAGE SESSION
  // ═════════════════════════════════════════════════════════════════════════

  /// Start a new AI triage session
  /// 
  /// **Request:**
  /// ```json
  /// {
  ///   "patientId": "uuid",
  ///   "chiefComplaint": "Fever and headache",
  ///   "language": "en",
  ///   "conductedBy": "patient"
  /// }
  /// ```
  /// 
  /// **Response:**
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "sessionId": "uuid",
  ///     "patientId": "uuid",
  ///     "chiefComplaint": "Fever and headache",
  ///     "language": "en",
  ///     "firstQuestion": { /* TriageQuestion */ },
  ///     "createdAt": "2026-09-20T10:30:00Z"
  ///   }
  /// }
  /// ```
  Future<TriageSessionModel> startTriageSession({
    required String patientId,
    required String chiefComplaint,
    required String language,
    String conductedBy = 'patient',
    String? facilityId,
  }) async {
    try {
      _logger.i('Starting triage session for patient: $patientId');

      final response = await apiClient.post<Map<String, dynamic>>(
        ApiConfig.triageStart,
        data: {
          'patientId': patientId,
          'chiefComplaint': chiefComplaint,
          'language': language,
          'conductedBy': conductedBy,
          if (facilityId != null) 'facilityId': facilityId,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final sessionData = apiResponse.data!;
        
        // Parse session
        final session = TriageSessionModel.fromJson(sessionData);
        
        // If first question is provided, add it to the session
        if (sessionData['firstQuestion'] != null) {
          final firstQuestion = TriageQuestion.fromJson(
            sessionData['firstQuestion'] as Map<String, dynamic>,
          );
          return session.copyWith(
            questionsAsked: [firstQuestion],
          );
        }
        
        return session;
      }

      throw Exception(apiResponse.error ?? 'Failed to start triage session');
    } on ApiException {
      rethrow;
    } catch (e) {
      _logger.e('Error starting triage session: $e');
      rethrow;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // GET NEXT QUESTION
  // ═════════════════════════════════════════════════════════════════════════

  /// Get the next adaptive question based on previous answers
  /// 
  /// **Request:**
  /// ```json
  /// {
  ///   "sessionId": "uuid",
  ///   "previousAnswer": {
  ///     "questionId": "q1",
  ///     "answer": "yes"
  ///   }
  /// }
  /// ```
  /// 
  /// **Response:**
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "nextQuestion": { /* TriageQuestion */ },
  ///     "hasMoreQuestions": true,
  ///     "completionPercentage": 45
  ///   }
  /// }
  /// ```
  Future<NextQuestionResponse> getNextQuestion({
    required String sessionId,
    required String questionId,
    required dynamic answer,
  }) async {
    try {
      _logger.i('Getting next triage question for session: $sessionId');

      final response = await apiClient.post<Map<String, dynamic>>(
        ApiConfig.triageNextQuestion,
        data: {
          'sessionId': sessionId,
          'previousAnswer': {
            'questionId': questionId,
            'answer': answer,
          },
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;
        
        return NextQuestionResponse(
          nextQuestion: data['nextQuestion'] != null
              ? TriageQuestion.fromJson(data['nextQuestion'])
              : null,
          hasMoreQuestions: data['hasMoreQuestions'] ?? false,
          completionPercentage: (data['completionPercentage'] as num?)?.toInt() ?? 0,
        );
      }

      throw Exception(apiResponse.error ?? 'Failed to get next question');
    } on ApiException {
      rethrow;
    } catch (e) {
      _logger.e('Error getting next question: $e');
      rethrow;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // SUBMIT TRIAGE
  // ═════════════════════════════════════════════════════════════════════════

  /// Submit completed triage and get risk assessment
  /// 
  /// **Request:**
  /// ```json
  /// {
  ///   "sessionId": "uuid",
  ///   "finalAnswer": {
  ///     "questionId": "q5",
  ///     "answer": "no"
  ///   }
  /// }
  /// ```
  /// 
  /// **Response:**
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "sessionId": "uuid",
  ///     "riskAssessment": {
  ///       "riskScore": 65,
  ///       "riskLevel": "moderate",
  ///       "recommendation": "Schedule facility visit today...",
  ///       "triggeringFactors": ["Fever > 101°F", "Headache"],
  ///       "confidenceScore": 0.85,
  ///       "modelVersion": "xgboost-v2.1"
  ///     },
  ///     "completedAt": "2026-09-20T10:35:00Z"
  ///   }
  /// }
  /// ```
  Future<TriageSessionModel> submitTriage({
    required String sessionId,
    String? finalQuestionId,
    dynamic finalAnswer,
  }) async {
    try {
      _logger.i('Submitting triage session: $sessionId');

      final response = await apiClient.post<Map<String, dynamic>>(
        ApiConfig.triageSubmit,
        data: {
          'sessionId': sessionId,
          if (finalQuestionId != null && finalAnswer != null)
            'finalAnswer': {
              'questionId': finalQuestionId,
              'answer': finalAnswer,
            },
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return TriageSessionModel.fromJson(apiResponse.data!);
      }

      throw Exception(apiResponse.error ?? 'Failed to submit triage');
    } on ApiException {
      rethrow;
    } catch (e) {
      _logger.e('Error submitting triage: $e');
      rethrow;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESPONSE MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Next Question Response
class NextQuestionResponse {
  final TriageQuestion? nextQuestion;
  final bool hasMoreQuestions;
  final int completionPercentage;

  NextQuestionResponse({
    this.nextQuestion,
    required this.hasMoreQuestions,
    required this.completionPercentage,
  });
}
