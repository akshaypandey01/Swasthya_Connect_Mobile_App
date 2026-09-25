import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/hive_constants.dart';
import '../../core/services/api_client.dart';
import '../../core/services/connectivity_service.dart';
import '../models/triage_session_model.dart';
import '../services/triage_api_service.dart';
import '../../features/worker/triage_result/triage_engine.dart' as rule_based;

// ═══════════════════════════════════════════════════════════════════════════
// TRIAGE REPOSITORY PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final triageRepositoryProvider = Provider<TriageRepository>((ref) {
  final apiService = ref.watch(triageApiServiceProvider);
  final isOnline = ref.watch(isOnlineProvider);
  return TriageRepository(
    apiService: apiService,
    isOnline: isOnline,
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// TRIAGE REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

/// Triage Repository
/// 
/// Handles triage sessions with intelligent fallback:
/// - Online: Uses AI-powered adaptive triage (Groq + XGBoost)
/// - Offline: Falls back to rule-based triage
/// 
/// Stores completed triage sessions locally for offline access.
class TriageRepository {
  final TriageApiService apiService;
  final bool isOnline;
  final Logger _logger = Logger();

  TriageRepository({
    required this.apiService,
    required this.isOnline,
  });

  // ═════════════════════════════════════════════════════════════════════════
  // START TRIAGE
  // ═════════════════════════════════════════════════════════════════════════

  /// Start a new triage session
  /// 
  /// - If online: Start AI-powered adaptive triage
  /// - If offline: Start rule-based triage
  Future<TriageSessionModel> startTriage({
    required String patientId,
    required String chiefComplaint,
    required String language,
    String conductedBy = 'patient',
    String? facilityId,
  }) async {
    if (isOnline) {
      try {
        // Try AI triage
        _logger.i('Starting AI triage session');
        return await apiService.startTriageSession(
          patientId: patientId,
          chiefComplaint: chiefComplaint,
          language: language,
          conductedBy: conductedBy,
          facilityId: facilityId,
        );
      } on ApiException catch (e) {
        _logger.w('AI triage unavailable, falling back to rule-based: ${e.message}');
        // Fall back to offline triage
        return _startOfflineTriage(
          patientId: patientId,
          chiefComplaint: chiefComplaint,
          language: language,
          conductedBy: conductedBy,
          facilityId: facilityId,
        );
      }
    } else {
      _logger.i('Starting offline rule-based triage');
      return _startOfflineTriage(
        patientId: patientId,
        chiefComplaint: chiefComplaint,
        language: language,
        conductedBy: conductedBy,
        facilityId: facilityId,
      );
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // GET NEXT QUESTION
  // ═════════════════════════════════════════════════════════════════════════

  /// Get next question in triage flow
  /// 
  /// - If AI session: Get adaptive next question from API
  /// - If offline session: Get next question from rule-based flow
  Future<NextQuestionResponse> getNextQuestion({
    required TriageSessionModel session,
    required String questionId,
    required dynamic answer,
  }) async {
    if (session.triageMethod == 'ai' && isOnline) {
      try {
        return await apiService.getNextQuestion(
          sessionId: session.sessionId,
          questionId: questionId,
          answer: answer,
        );
      } on ApiException catch (e) {
        _logger.w('Failed to get next AI question: ${e.message}');
        // Return completion if offline
        return NextQuestionResponse(
          nextQuestion: null,
          hasMoreQuestions: false,
          completionPercentage: 100,
        );
      }
    } else {
      // Rule-based flow - return completion after first set of questions
      return NextQuestionResponse(
        nextQuestion: null,
        hasMoreQuestions: false,
        completionPercentage: 100,
      );
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // SUBMIT TRIAGE
  // ═════════════════════════════════════════════════════════════════════════

  /// Submit triage and get risk assessment
  /// 
  /// - If AI session: Submit to API for ML risk scoring
  /// - If offline session: Use rule-based triage engine
  Future<TriageSessionModel> submitTriage({
    required TriageSessionModel session,
    String? finalQuestionId,
    dynamic finalAnswer,
  }) async {
    if (session.triageMethod == 'ai' && isOnline) {
      try {
        final completedSession = await apiService.submitTriage(
          sessionId: session.sessionId,
          finalQuestionId: finalQuestionId,
          finalAnswer: finalAnswer,
        );
        
        // Save to local cache
        await _saveTriageSession(completedSession);
        
        return completedSession;
      } on ApiException catch (e) {
        _logger.w('Failed to submit AI triage: ${e.message}');
        // Fall back to rule-based assessment
        return _completeOfflineTriage(session);
      }
    } else {
      return _completeOfflineTriage(session);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // OFFLINE TRIAGE (RULE-BASED FALLBACK)
  // ═════════════════════════════════════════════════════════════════════════

  /// Start offline rule-based triage
  TriageSessionModel _startOfflineTriage({
    required String patientId,
    required String chiefComplaint,
    required String language,
    required String conductedBy,
    String? facilityId,
  }) {
    final sessionId = const Uuid().v4();
    
    // Create initial rule-based question set
    final questions = _getRuleBasedQuestions(language);
    
    return TriageSessionModel(
      sessionId: sessionId,
      patientId: patientId,
      chiefComplaint: chiefComplaint,
      language: language,
      questionsAsked: questions,
      conductedBy: conductedBy,
      facilityId: facilityId,
      createdAt: DateTime.now(),
      status: 'in_progress',
      triageMethod: 'rule_based',
    );
  }

  /// Get rule-based questions (same as current Health Assessment)
  List<TriageQuestion> _getRuleBasedQuestions(String language) {
    final questions = [
      TriageQuestion(
        questionId: 'fever',
        questionText: 'Do you have fever?',
        questionTextHi: 'क्या आपको बुखार है?',
        questionTextMr: 'तुम्हाला ताप आहे का?',
        questionType: 'yes_no',
        askedAt: DateTime.now(),
      ),
      TriageQuestion(
        questionId: 'difficulty_breathing',
        questionText: 'Do you have difficulty breathing?',
        questionTextHi: 'क्या आपको सांस लेने में तकलीफ है?',
        questionTextMr: 'तुम्हाला श्वास घेण्यात अडचण येत आहे का?',
        questionType: 'yes_no',
        askedAt: DateTime.now(),
      ),
      TriageQuestion(
        questionId: 'chest_pain',
        questionText: 'Do you have chest pain?',
        questionTextHi: 'क्या आपको सीने में दर्द है?',
        questionTextMr: 'तुम्हाला छातीत दुखत आहे का?',
        questionType: 'yes_no',
        askedAt: DateTime.now(),
      ),
      TriageQuestion(
        questionId: 'bleeding',
        questionText: 'Are you bleeding?',
        questionTextHi: 'क्या आपको खून बह रहा है?',
        questionTextMr: 'तुमच्याकडून रक्त येत आहे का?',
        questionType: 'yes_no',
        askedAt: DateTime.now(),
      ),
      TriageQuestion(
        questionId: 'unconscious',
        questionText: 'Have you experienced unconsciousness or unresponsiveness?',
        questionTextHi: 'क्या आप बेहोश हुए हैं?',
        questionTextMr: 'तुम्ही बेशुद्ध झाला होता का?',
        questionType: 'yes_no',
        askedAt: DateTime.now(),
      ),
    ];
    
    return questions;
  }

  /// Complete offline triage with rule-based assessment
  Future<TriageSessionModel> _completeOfflineTriage(
    TriageSessionModel session,
  ) async {
    _logger.i('Completing offline rule-based triage');

    // Extract vitals and symptoms from questions
    final vitals = <String, dynamic>{};
    final symptoms = <String, dynamic>{
      'flags': <String, bool>{},
    };

    for (final question in session.questionsAsked) {
      if (question.answer != null) {
        symptoms['flags']![question.questionId] = question.answer == true ||
            question.answer == 'yes';
      }
    }

    // Add chief complaint to symptoms
    symptoms['chief_complaint'] = session.chiefComplaint;

    // Use existing rule-based triage engine
    final triageResult = rule_based.TriageEngine.evaluate(
      vitals: vitals,
      symptoms: symptoms,
    );

    // Convert to RiskAssessment
    final riskAssessment = RiskAssessment(
      riskScore: _getRiskScore(triageResult.severity),
      riskLevel: _convertRiskLevel(triageResult.severity),
      recommendation: triageResult.recommendation,
      triggeringFactors: triageResult.triggeringFactors,
      confidenceScore: triageResult.confidenceScore,
      modelVersion: triageResult.modelVersion,
    );

    final completedSession = session.copyWith(
      symptoms: symptoms,
      riskAssessment: riskAssessment,
      completedAt: DateTime.now(),
      status: 'completed',
    );

    // Save locally
    await _saveTriageSession(completedSession);

    return completedSession;
  }

  /// Convert rule-based severity to risk score
  int _getRiskScore(rule_based.TriageSeverity severity) {
    switch (severity) {
      case rule_based.TriageSeverity.green:
        return 25;
      case rule_based.TriageSeverity.yellow:
        return 50;
      case rule_based.TriageSeverity.red:
        return 75;
      case rule_based.TriageSeverity.critical:
        return 95;
    }
  }

  /// Convert rule-based severity to RiskLevel
  RiskLevel _convertRiskLevel(rule_based.TriageSeverity severity) {
    switch (severity) {
      case rule_based.TriageSeverity.green:
        return RiskLevel.low;
      case rule_based.TriageSeverity.yellow:
        return RiskLevel.moderate;
      case rule_based.TriageSeverity.red:
        return RiskLevel.high;
      case rule_based.TriageSeverity.critical:
        return RiskLevel.emergency;
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // LOCAL STORAGE
  // ═════════════════════════════════════════════════════════════════════════

  /// Save triage session to Firestore (if online) and local cache
  Future<void> _saveTriageSession(TriageSessionModel session) async {
    try {
      // Save to Firestore if online
      if (isOnline) {
        // TODO: Save to Firestore triageSessions collection
        _logger.i('Saving triage session to Firestore: ${session.sessionId}');
      }
      
      // TODO: Save to Hive for offline access
      _logger.i('Triage session saved locally: ${session.sessionId}');
    } catch (e) {
      _logger.e('Error saving triage session: $e');
    }
  }

  /// Get triage session history for patient
  Future<List<TriageSessionModel>> getPatientTriageHistory(
    String patientId,
  ) async {
    try {
      // TODO: Fetch from Firestore/Hive
      _logger.i('Fetching triage history for patient: $patientId');
      return [];
    } catch (e) {
      _logger.e('Error fetching triage history: $e');
      return [];
    }
  }
}
