/// Worker referral data model for creating and managing patient referrals

enum ReferralUrgencyLevel {
  normal,
  urgent,
  emergency
}

enum ReferralStatusType {
  pending,
  accepted,
  inTransit,
  completed,
  rejected,
  cancelled
}

class WorkerReferral {
  final String id;
  final String patientId;
  final String patientName;
  final String workerId;
  final String workerName;
  final String fromFacility;
  final String toFacility;
  final String toFacilityAddress;
  final String? toFacilityPhone;
  final String specialization;
  final String reason;
  final String? suspectedCondition;
  final ReferralUrgencyLevel urgency;
  final ReferralStatusType status;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final DateTime? completedAt;
  final Map<String, dynamic> relevantVitals;
  final String? medicalHistory;
  final String? specialInstructions;
  final List<String> attachedDocuments;
  final List<ReferralStatusHistory> statusHistory;
  final String? rejectionReason;
  final String? feedback;

  WorkerReferral({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.workerId,
    required this.workerName,
    required this.fromFacility,
    required this.toFacility,
    required this.toFacilityAddress,
    this.toFacilityPhone,
    required this.specialization,
    required this.reason,
    this.suspectedCondition,
    required this.urgency,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.completedAt,
    required this.relevantVitals,
    this.medicalHistory,
    this.specialInstructions,
    required this.attachedDocuments,
    required this.statusHistory,
    this.rejectionReason,
    this.feedback,
  });
}

class ReferralStatusHistory {
  final ReferralStatusType status;
  final DateTime timestamp;
  final String? note;
  final String? updatedBy;

  ReferralStatusHistory({
    required this.status,
    required this.timestamp,
    this.note,
    this.updatedBy,
  });
}
