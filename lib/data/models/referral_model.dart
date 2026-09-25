/// Referral data model for patient referrals to other facilities

enum ReferralStatus {
  pending,
  scheduled,
  inTransit,
  completed,
  cancelled
}

enum ReferralUrgency {
  routine,
  urgent,
  emergency
}

class Referral {
  final String id;
  final String patientId;
  final String fromFacility;
  final String toFacility;
  final String toFacilityAddress;
  final String? toFacilityPhone;
  final String referringDoctor;
  final String? receivingDoctor;
  final String specialization;
  final String reason;
  final String? diagnosis;
  final ReferralUrgency urgency;
  final ReferralStatus status;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final DateTime? completedAt;
  final List<String> attachedDocuments;
  final String? transportArranged;
  final String? transportDetails;
  final String? notes;
  final List<ReferralStatusUpdate> statusHistory;

  Referral({
    required this.id,
    required this.patientId,
    required this.fromFacility,
    required this.toFacility,
    required this.toFacilityAddress,
    this.toFacilityPhone,
    required this.referringDoctor,
    this.receivingDoctor,
    required this.specialization,
    required this.reason,
    this.diagnosis,
    required this.urgency,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.completedAt,
    required this.attachedDocuments,
    this.transportArranged,
    this.transportDetails,
    this.notes,
    required this.statusHistory,
  });
}

class ReferralStatusUpdate {
  final ReferralStatus status;
  final DateTime timestamp;
  final String? note;
  final String? updatedBy;

  ReferralStatusUpdate({
    required this.status,
    required this.timestamp,
    this.note,
    this.updatedBy,
  });
}
