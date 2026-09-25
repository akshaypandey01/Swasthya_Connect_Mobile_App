import 'package:hive/hive.dart';

/// Triage Session Model
/// 
/// Represents an AI-powered triage session with adaptive questions
/// and risk assessment.
class TriageSessionModel {
  final String sessionId;
  final String patientId;
  final String chiefComplaint;
  final String language; // en | hi | mr
  final List<TriageQuestion> questionsAsked;
  final Map<String, dynamic> symptoms; // Collected symptom data
  final RiskAssessment? riskAssessment;
  final String conductedBy; // patient | worker_id
  final String? facilityId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String status; // in_progress | completed | abandoned
  final String triageMethod; // ai | rule_based

  TriageSessionModel({
    required this.sessionId,
    required this.patientId,
    required this.chiefComplaint,
    required this.language,
    this.questionsAsked = const [],
    this.symptoms = const {},
    this.riskAssessment,
    required this.conductedBy,
    this.facilityId,
    required this.createdAt,
    this.completedAt,
    this.status = 'in_progress',
    this.triageMethod = 'ai',
  });

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'patientId': patientId,
      'chiefComplaint': chiefComplaint,
      'language': language,
      'questionsAsked': questionsAsked.map((q) => q.toJson()).toList(),
      'symptoms': symptoms,
      'riskAssessment': riskAssessment?.toJson(),
      'conductedBy': conductedBy,
      'facilityId': facilityId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status,
      'triageMethod': triageMethod,
    };
  }

  /// Parse from API response
  factory TriageSessionModel.fromJson(Map<String, dynamic> json) {
    return TriageSessionModel(
      sessionId: json['sessionId'] ?? '',
      patientId: json['patientId'] ?? '',
      chiefComplaint: json['chiefComplaint'] ?? '',
      language: json['language'] ?? 'en',
      questionsAsked: (json['questionsAsked'] as List?)
          ?.map((q) => TriageQuestion.fromJson(q))
          .toList() ?? [],
      symptoms: Map<String, dynamic>.from(json['symptoms'] ?? {}),
      riskAssessment: json['riskAssessment'] != null
          ? RiskAssessment.fromJson(json['riskAssessment'])
          : null,
      conductedBy: json['conductedBy'] ?? '',
      facilityId: json['facilityId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      status: json['status'] ?? 'in_progress',
      triageMethod: json['triageMethod'] ?? 'ai',
    );
  }

  /// Copy with
  TriageSessionModel copyWith({
    List<TriageQuestion>? questionsAsked,
    Map<String, dynamic>? symptoms,
    RiskAssessment? riskAssessment,
    DateTime? completedAt,
    String? status,
  }) {
    return TriageSessionModel(
      sessionId: sessionId,
      patientId: patientId,
      chiefComplaint: chiefComplaint,
      language: language,
      questionsAsked: questionsAsked ?? this.questionsAsked,
      symptoms: symptoms ?? this.symptoms,
      riskAssessment: riskAssessment ?? this.riskAssessment,
      conductedBy: conductedBy,
      facilityId: facilityId,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      triageMethod: triageMethod,
    );
  }
}

/// Triage Question (Adaptive)
class TriageQuestion {
  final String questionId;
  final String questionText;
  final String questionTextHi;
  final String questionTextMr;
  final String questionType; // yes_no | multiple_choice | numeric | text
  final List<String>? options;
  final dynamic answer;
  final DateTime askedAt;
  final DateTime? answeredAt;

  TriageQuestion({
    required this.questionId,
    required this.questionText,
    this.questionTextHi = '',
    this.questionTextMr = '',
    required this.questionType,
    this.options,
    this.answer,
    required this.askedAt,
    this.answeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'questionTextHi': questionTextHi,
      'questionTextMr': questionTextMr,
      'questionType': questionType,
      'options': options,
      'answer': answer,
      'askedAt': askedAt.toIso8601String(),
      'answeredAt': answeredAt?.toIso8601String(),
    };
  }

  factory TriageQuestion.fromJson(Map<String, dynamic> json) {
    return TriageQuestion(
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      questionTextHi: json['questionTextHi'] ?? '',
      questionTextMr: json['questionTextMr'] ?? '',
      questionType: json['questionType'] ?? 'yes_no',
      options: (json['options'] as List?)?.cast<String>(),
      answer: json['answer'],
      askedAt: json['askedAt'] != null
          ? DateTime.parse(json['askedAt'])
          : DateTime.now(),
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'])
          : null,
    );
  }

  /// Get localized question text
  String getLocalizedText(String language) {
    switch (language) {
      case 'hi':
        return questionTextHi.isNotEmpty ? questionTextHi : questionText;
      case 'mr':
        return questionTextMr.isNotEmpty ? questionTextMr : questionText;
      default:
        return questionText;
    }
  }

  /// Copy with answer
  TriageQuestion withAnswer(dynamic answer) {
    return TriageQuestion(
      questionId: questionId,
      questionText: questionText,
      questionTextHi: questionTextHi,
      questionTextMr: questionTextMr,
      questionType: questionType,
      options: options,
      answer: answer,
      askedAt: askedAt,
      answeredAt: DateTime.now(),
    );
  }
}

/// Risk Assessment Result
class RiskAssessment {
  final int riskScore; // 0-100
  final RiskLevel riskLevel;
  final String recommendation;
  final List<String> triggeringFactors;
  final double confidenceScore; // 0.0-1.0
  final String modelVersion;

  RiskAssessment({
    required this.riskScore,
    required this.riskLevel,
    required this.recommendation,
    this.triggeringFactors = const [],
    this.confidenceScore = 0.0,
    this.modelVersion = 'unknown',
  });

  Map<String, dynamic> toJson() {
    return {
      'riskScore': riskScore,
      'riskLevel': riskLevel.toString().split('.').last,
      'recommendation': recommendation,
      'triggeringFactors': triggeringFactors,
      'confidenceScore': confidenceScore,
      'modelVersion': modelVersion,
    };
  }

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      riskScore: json['riskScore'] ?? 0,
      riskLevel: _parseRiskLevel(json['riskLevel']),
      recommendation: json['recommendation'] ?? '',
      triggeringFactors: (json['triggeringFactors'] as List?)?.cast<String>() ?? [],
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      modelVersion: json['modelVersion'] ?? 'unknown',
    );
  }

  static RiskLevel _parseRiskLevel(dynamic level) {
    if (level == null) return RiskLevel.moderate;
    final levelStr = level.toString().toLowerCase();
    switch (levelStr) {
      case 'low':
        return RiskLevel.low;
      case 'moderate':
        return RiskLevel.moderate;
      case 'high':
        return RiskLevel.high;
      case 'emergency':
        return RiskLevel.emergency;
      default:
        return RiskLevel.moderate;
    }
  }

  /// Get color for risk level
  Color get color {
    switch (riskLevel) {
      case RiskLevel.low:
        return const Color(0xFF4CAF50); // Green
      case RiskLevel.moderate:
        return const Color(0xFFFFC107); // Yellow
      case RiskLevel.high:
        return const Color(0xFFFF9800); // Orange
      case RiskLevel.emergency:
        return const Color(0xFFD32F2F); // Red
    }
  }

  /// Get icon for risk level
  IconData get icon {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.check_circle_rounded;
      case RiskLevel.moderate:
        return Icons.warning_rounded;
      case RiskLevel.high:
        return Icons.error_rounded;
      case RiskLevel.emergency:
        return Icons.local_hospital_rounded;
    }
  }

  /// Get label for risk level
  String get label {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.moderate:
        return 'Moderate Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.emergency:
        return 'Emergency';
    }
  }

  /// Get localized label (Hindi)
  String get labelHi {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'कम जोखिम';
      case RiskLevel.moderate:
        return 'मध्यम जोखिम';
      case RiskLevel.high:
        return 'उच्च जोखिम';
      case RiskLevel.emergency:
        return 'आपातकाल';
    }
  }
}

/// Risk Level Enum
enum RiskLevel {
  low,
  moderate,
  high,
  emergency,
}
