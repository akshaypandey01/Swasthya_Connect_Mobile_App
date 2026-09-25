/// Follow-up appointment data model

enum FollowUpStatus {
  scheduled,
  due,
  overdue,
  completed,
  cancelled,
  rescheduled
}

enum FollowUpType {
  postConsultation,
  postProcedure,
  chronicCare,
  labReview,
  medicationReview,
  general
}

class FollowUp {
  final String id;
  final String patientId;
  final String relatedEncounterId;
  final String facility;
  final String doctor;
  final String? doctorSpecialization;
  final FollowUpType type;
  final String reason;
  final DateTime scheduledDate;
  final String? timeSlot;
  final FollowUpStatus status;
  final String? instructions;
  final List<String> requiredTests;
  final List<String> documentsToCarry;
  final bool teleconsultAvailable;
  final bool teleconsultPreferred;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? cancellationReason;
  final String? notes;
  final String? tokenNumber;

  FollowUp({
    required this.id,
    required this.patientId,
    required this.relatedEncounterId,
    required this.facility,
    required this.doctor,
    this.doctorSpecialization,
    required this.type,
    required this.reason,
    required this.scheduledDate,
    this.timeSlot,
    required this.status,
    this.instructions,
    required this.requiredTests,
    required this.documentsToCarry,
    this.teleconsultAvailable = false,
    this.teleconsultPreferred = false,
    required this.createdAt,
    this.completedAt,
    this.cancellationReason,
    this.notes,
    this.tokenNumber,
  });

  bool get isDue {
    final now = DateTime.now();
    final dueDate = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return dueDate.isBefore(today.add(const Duration(days: 3))) && 
           dueDate.isAfter(today.subtract(const Duration(days: 1)));
  }

  bool get isOverdue {
    final now = DateTime.now();
    return scheduledDate.isBefore(now) && status == FollowUpStatus.scheduled;
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return scheduledDate.isAfter(now) && status == FollowUpStatus.scheduled;
  }
}
