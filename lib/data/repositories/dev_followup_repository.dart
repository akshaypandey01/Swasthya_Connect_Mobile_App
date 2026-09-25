/// Development repository for follow-ups with mock data

import '../models/followup_model.dart';

class DevFollowUpRepository {
  /// Simulates network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  /// Get all follow-ups for a patient
  Future<List<FollowUp>> getFollowUps({
    required String patientId,
    FollowUpStatus? status,
  }) async {
    await _simulateDelay();
    var followUps = _mockFollowUps.where((f) => f.patientId == patientId).toList();
    
    if (status != null) {
      followUps = followUps.where((f) => f.status == status).toList();
    }
    
    // Sort by scheduled date
    followUps.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return followUps;
  }

  /// Get upcoming follow-ups
  Future<List<FollowUp>> getUpcomingFollowUps(String patientId) async {
    await _simulateDelay();
    final now = DateTime.now();
    return _mockFollowUps.where((f) =>
      f.patientId == patientId &&
      f.scheduledDate.isAfter(now) &&
      f.status == FollowUpStatus.scheduled
    ).toList()..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Get due follow-ups (within 3 days)
  Future<List<FollowUp>> getDueFollowUps(String patientId) async {
    await _simulateDelay();
    final now = DateTime.now();
    final threeDaysLater = now.add(const Duration(days: 3));
    return _mockFollowUps.where((f) =>
      f.patientId == patientId &&
      f.scheduledDate.isAfter(now) &&
      f.scheduledDate.isBefore(threeDaysLater) &&
      f.status == FollowUpStatus.scheduled
    ).toList()..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Get overdue follow-ups
  Future<List<FollowUp>> getOverdueFollowUps(String patientId) async {
    await _simulateDelay();
    final now = DateTime.now();
    return _mockFollowUps.where((f) =>
      f.patientId == patientId &&
      f.scheduledDate.isBefore(now) &&
      f.status == FollowUpStatus.scheduled
    ).toList()..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  /// Get past/completed follow-ups
  Future<List<FollowUp>> getPastFollowUps(String patientId) async {
    await _simulateDelay();
    return _mockFollowUps.where((f) =>
      f.patientId == patientId &&
      (f.status == FollowUpStatus.completed || f.status == FollowUpStatus.cancelled)
    ).toList()..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  /// Get single follow-up by ID
  Future<FollowUp?> getFollowUp(String id) async {
    await _simulateDelay();
    try {
      return _mockFollowUps.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Mark follow-up as completed
  Future<bool> markAsCompleted(String followUpId, String? notes) async {
    await _simulateDelay();
    final index = _mockFollowUps.indexWhere((f) => f.id == followUpId);
    if (index != -1) {
      final followUp = _mockFollowUps[index];
      _mockFollowUps[index] = FollowUp(
        id: followUp.id,
        patientId: followUp.patientId,
        relatedEncounterId: followUp.relatedEncounterId,
        facility: followUp.facility,
        doctor: followUp.doctor,
        doctorSpecialization: followUp.doctorSpecialization,
        type: followUp.type,
        reason: followUp.reason,
        scheduledDate: followUp.scheduledDate,
        timeSlot: followUp.timeSlot,
        status: FollowUpStatus.completed,
        instructions: followUp.instructions,
        requiredTests: followUp.requiredTests,
        documentsToCarry: followUp.documentsToCarry,
        teleconsultAvailable: followUp.teleconsultAvailable,
        teleconsultPreferred: followUp.teleconsultPreferred,
        createdAt: followUp.createdAt,
        completedAt: DateTime.now(),
        cancellationReason: followUp.cancellationReason,
        notes: notes ?? followUp.notes,
        tokenNumber: followUp.tokenNumber,
      );
      return true;
    }
    return false;
  }

  /// Reschedule follow-up
  Future<bool> rescheduleFollowUp({
    required String followUpId,
    required DateTime newDate,
    String? newTimeSlot,
    String? reason,
  }) async {
    await _simulateDelay();
    final index = _mockFollowUps.indexWhere((f) => f.id == followUpId);
    if (index != -1) {
      final followUp = _mockFollowUps[index];
      _mockFollowUps[index] = FollowUp(
        id: followUp.id,
        patientId: followUp.patientId,
        relatedEncounterId: followUp.relatedEncounterId,
        facility: followUp.facility,
        doctor: followUp.doctor,
        doctorSpecialization: followUp.doctorSpecialization,
        type: followUp.type,
        reason: followUp.reason,
        scheduledDate: newDate,
        timeSlot: newTimeSlot ?? followUp.timeSlot,
        status: FollowUpStatus.rescheduled,
        instructions: followUp.instructions,
        requiredTests: followUp.requiredTests,
        documentsToCarry: followUp.documentsToCarry,
        teleconsultAvailable: followUp.teleconsultAvailable,
        teleconsultPreferred: followUp.teleconsultPreferred,
        createdAt: followUp.createdAt,
        completedAt: followUp.completedAt,
        cancellationReason: followUp.cancellationReason,
        notes: reason != null ? '${followUp.notes ?? ''}\nRescheduled: $reason' : followUp.notes,
        tokenNumber: followUp.tokenNumber,
      );
      return true;
    }
    return false;
  }

  /// Cancel follow-up
  Future<bool> cancelFollowUp(String followUpId, String reason) async {
    await _simulateDelay();
    final index = _mockFollowUps.indexWhere((f) => f.id == followUpId);
    if (index != -1) {
      final followUp = _mockFollowUps[index];
      _mockFollowUps[index] = FollowUp(
        id: followUp.id,
        patientId: followUp.patientId,
        relatedEncounterId: followUp.relatedEncounterId,
        facility: followUp.facility,
        doctor: followUp.doctor,
        doctorSpecialization: followUp.doctorSpecialization,
        type: followUp.type,
        reason: followUp.reason,
        scheduledDate: followUp.scheduledDate,
        timeSlot: followUp.timeSlot,
        status: FollowUpStatus.cancelled,
        instructions: followUp.instructions,
        requiredTests: followUp.requiredTests,
        documentsToCarry: followUp.documentsToCarry,
        teleconsultAvailable: followUp.teleconsultAvailable,
        teleconsultPreferred: followUp.teleconsultPreferred,
        createdAt: followUp.createdAt,
        completedAt: followUp.completedAt,
        cancellationReason: reason,
        notes: followUp.notes,
        tokenNumber: followUp.tokenNumber,
      );
      return true;
    }
    return false;
  }

  /// Mock follow-ups data
  static final List<FollowUp> _mockFollowUps = [
    FollowUp(
      id: 'fu_001',
      patientId: 'patient_123',
      relatedEncounterId: 'enc_001',
      facility: 'SwasthyaConnect PHC, Andheri',
      doctor: 'Dr. Rajesh Kulkarni',
      doctorSpecialization: 'General Medicine',
      type: FollowUpType.postConsultation,
      reason: 'Review blood pressure and medication effectiveness',
      scheduledDate: DateTime.now().add(const Duration(days: 2)),
      timeSlot: '10:00 AM',
      status: FollowUpStatus.scheduled,
      instructions: 'Bring recent BP readings log. Continue current medication.',
      requiredTests: [],
      documentsToCarry: ['BP Log', 'Current Prescription'],
      teleconsultAvailable: true,
      teleconsultPreferred: false,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      tokenNumber: 'T105',
    ),
    FollowUp(
      id: 'fu_002',
      patientId: 'patient_123',
      relatedEncounterId: 'enc_002',
      facility: 'Lilavati Hospital',
      doctor: 'Dr. Suresh Menon',
      doctorSpecialization: 'Cardiology',
      type: FollowUpType.labReview,
      reason: 'Review cardiac stress test results',
      scheduledDate: DateTime.now().add(const Duration(days: 7)),
      timeSlot: '3:00 PM',
      status: FollowUpStatus.scheduled,
      instructions: 'Bring all previous cardiac reports and current medications list.',
      requiredTests: ['Stress Test'],
      documentsToCarry: ['ECG Reports', 'Previous Consultation Notes', 'Medication List'],
      teleconsultAvailable: true,
      teleconsultPreferred: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    FollowUp(
      id: 'fu_003',
      patientId: 'patient_123',
      relatedEncounterId: 'enc_003',
      facility: 'Apollo Clinic, Bandra',
      doctor: 'Dr. Priya Sharma',
      doctorSpecialization: 'Pediatrics',
      type: FollowUpType.chronicCare,
      reason: 'Diabetes management check - HbA1c review',
      scheduledDate: DateTime.now().add(const Duration(days: 15)),
      timeSlot: '11:30 AM',
      status: FollowUpStatus.scheduled,
      instructions: 'Fasting blood sugar test required before visit. Fast for 8-10 hours.',
      requiredTests: ['HbA1c', 'Fasting Blood Sugar'],
      documentsToCarry: ['Previous HbA1c Reports', 'Blood Sugar Log'],
      teleconsultAvailable: true,
      teleconsultPreferred: true,
      createdAt: DateTime.now().subtract(const Duration(days: 75)),
      notes: 'Quarterly diabetes management review',
    ),
    FollowUp(
      id: 'fu_004',
      patientId: 'patient_123',
      relatedEncounterId: 'enc_004',
      facility: 'SwasthyaConnect PHC, Andheri',
      doctor: 'Dr. Anita Desai',
      doctorSpecialization: 'Gynecology',
      type: FollowUpType.postProcedure,
      reason: 'Post-surgery wound check and stitch removal',
      scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
      timeSlot: '2:00 PM',
      status: FollowUpStatus.scheduled,
      instructions: 'Keep wound dry. Bring all post-surgery medications.',
      requiredTests: [],
      documentsToCarry: ['Discharge Summary', 'Post-op Instructions'],
      teleconsultAvailable: false,
      teleconsultPreferred: false,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      notes: 'OVERDUE - Patient needs to reschedule',
    ),
    FollowUp(
      id: 'fu_005',
      patientId: 'patient_123',
      relatedEncounterId: 'enc_005',
      facility: 'KEM Hospital',
      doctor: 'Dr. Ramesh Patel',
      doctorSpecialization: 'Orthopedics',
      type: FollowUpType.postConsultation,
      reason: 'Knee pain reassessment after physiotherapy',
      scheduledDate: DateTime.now().subtract(const Duration(days: 30)),
      timeSlot: '9:00 AM',
      status: FollowUpStatus.completed,
      instructions: 'Complete 4 weeks of physiotherapy before follow-up.',
      requiredTests: [],
      documentsToCarry: ['Physiotherapy Progress Report', 'X-Ray'],
      teleconsultAvailable: false,
      teleconsultPreferred: false,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      completedAt: DateTime.now().subtract(const Duration(days: 30)),
      notes: 'Patient showed significant improvement. Advised to continue exercises.',
      tokenNumber: 'T42',
    ),
  ];
}
