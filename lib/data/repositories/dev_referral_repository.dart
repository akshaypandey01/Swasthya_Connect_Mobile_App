/// Development repository for referrals with mock data

import '../models/referral_model.dart';

class DevReferralRepository {
  /// Simulates network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  /// Get all referrals for a patient
  Future<List<Referral>> getReferrals({
    required String patientId,
    ReferralStatus? status,
  }) async {
    await _simulateDelay();
    var referrals = _mockReferrals.where((r) => r.patientId == patientId).toList();
    
    if (status != null) {
      referrals = referrals.where((r) => r.status == status).toList();
    }
    
    // Sort by creation date, newest first
    referrals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return referrals;
  }

  /// Get single referral by ID
  Future<Referral?> getReferral(String id) async {
    await _simulateDelay();
    try {
      return _mockReferrals.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get active referrals (pending, scheduled, in-transit)
  Future<List<Referral>> getActiveReferrals(String patientId) async {
    await _simulateDelay();
    return _mockReferrals.where((r) =>
      r.patientId == patientId &&
      (r.status == ReferralStatus.pending ||
       r.status == ReferralStatus.scheduled ||
       r.status == ReferralStatus.inTransit)
    ).toList();
  }

  /// Update referral status
  Future<bool> updateReferralStatus({
    required String referralId,
    required ReferralStatus newStatus,
    String? note,
  }) async {
    await _simulateDelay();
    final index = _mockReferrals.indexWhere((r) => r.id == referralId);
    if (index != -1) {
      final referral = _mockReferrals[index];
      final updatedHistory = List<ReferralStatusUpdate>.from(referral.statusHistory)
        ..add(ReferralStatusUpdate(
          status: newStatus,
          timestamp: DateTime.now(),
          note: note,
          updatedBy: 'Patient',
        ));
      
      _mockReferrals[index] = Referral(
        id: referral.id,
        patientId: referral.patientId,
        fromFacility: referral.fromFacility,
        toFacility: referral.toFacility,
        toFacilityAddress: referral.toFacilityAddress,
        toFacilityPhone: referral.toFacilityPhone,
        referringDoctor: referral.referringDoctor,
        receivingDoctor: referral.receivingDoctor,
        specialization: referral.specialization,
        reason: referral.reason,
        diagnosis: referral.diagnosis,
        urgency: referral.urgency,
        status: newStatus,
        createdAt: referral.createdAt,
        scheduledDate: referral.scheduledDate,
        completedAt: newStatus == ReferralStatus.completed ? DateTime.now() : referral.completedAt,
        attachedDocuments: referral.attachedDocuments,
        transportArranged: referral.transportArranged,
        transportDetails: referral.transportDetails,
        notes: referral.notes,
        statusHistory: updatedHistory,
      );
      return true;
    }
    return false;
  }

  /// Mock referrals data
  static final List<Referral> _mockReferrals = [
    Referral(
      id: 'ref_001',
      patientId: 'patient_123',
      fromFacility: 'SwasthyaConnect PHC, Andheri',
      toFacility: 'Lilavati Hospital',
      toFacilityAddress: 'A-791, Bandra Reclamation, Bandra West, Mumbai - 400050',
      toFacilityPhone: '+91 22 2640 4444',
      referringDoctor: 'Dr. Rajesh Kulkarni',
      receivingDoctor: 'Dr. Suresh Menon',
      specialization: 'Cardiology',
      reason: 'Persistent chest pain and abnormal ECG findings',
      diagnosis: 'Suspected Coronary Artery Disease',
      urgency: ReferralUrgency.urgent,
      status: ReferralStatus.scheduled,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      scheduledDate: DateTime.now().add(const Duration(days: 2)),
      attachedDocuments: ['ECG Report', 'Blood Test Results', 'Consultation Notes'],
      transportArranged: 'Yes',
      transportDetails: 'Ambulance arranged by PHC. Contact: 108',
      notes: 'Patient advised to fast 6 hours before appointment',
      statusHistory: [
        ReferralStatusUpdate(
          status: ReferralStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          note: 'Referral created',
          updatedBy: 'Dr. Rajesh Kulkarni',
        ),
        ReferralStatusUpdate(
          status: ReferralStatus.scheduled,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          note: 'Appointment scheduled for cardiology consultation',
          updatedBy: 'Lilavati Hospital',
        ),
      ],
    ),
    Referral(
      id: 'ref_002',
      patientId: 'patient_123',
      fromFacility: 'SwasthyaConnect PHC, Andheri',
      toFacility: 'KEM Hospital',
      toFacilityAddress: 'Acharya Donde Marg, Parel, Mumbai - 400012',
      toFacilityPhone: '+91 22 2410 7000',
      referringDoctor: 'Dr. Priya Sharma',
      specialization: 'Orthopedics',
      reason: 'Chronic knee pain, suspected arthritis',
      diagnosis: 'Possible Osteoarthritis',
      urgency: ReferralUrgency.routine,
      status: ReferralStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      attachedDocuments: ['X-Ray Knee Joint', 'Physical Examination Notes'],
      transportArranged: 'No',
      notes: 'Patient can visit independently',
      statusHistory: [
        ReferralStatusUpdate(
          status: ReferralStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          note: 'Referral created, awaiting appointment scheduling',
          updatedBy: 'Dr. Priya Sharma',
        ),
      ],
    ),
    Referral(
      id: 'ref_003',
      patientId: 'patient_123',
      fromFacility: 'Apollo Clinic, Bandra',
      toFacility: 'Tata Memorial Hospital',
      toFacilityAddress: 'Dr. E Borges Road, Parel, Mumbai - 400012',
      toFacilityPhone: '+91 22 2417 7000',
      referringDoctor: 'Dr. Anita Desai',
      receivingDoctor: 'Dr. Ramesh Kumar',
      specialization: 'Oncology',
      reason: 'Biopsy results indicate malignancy, specialist review required',
      diagnosis: 'Suspected Breast Cancer',
      urgency: ReferralUrgency.emergency,
      status: ReferralStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      scheduledDate: DateTime.now().subtract(const Duration(days: 40)),
      completedAt: DateTime.now().subtract(const Duration(days: 38)),
      attachedDocuments: ['Biopsy Report', 'Mammography', 'Ultrasound Report', 'Blood Work'],
      transportArranged: 'Yes',
      transportDetails: 'Family arranged private transport',
      notes: 'Patient started treatment at Tata Memorial',
      statusHistory: [
        ReferralStatusUpdate(
          status: ReferralStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(days: 45)),
          note: 'Emergency referral for oncology consultation',
          updatedBy: 'Dr. Anita Desai',
        ),
        ReferralStatusUpdate(
          status: ReferralStatus.scheduled,
          timestamp: DateTime.now().subtract(const Duration(days: 44)),
          note: 'Fast-tracked appointment scheduled',
          updatedBy: 'Tata Memorial Hospital',
        ),
        ReferralStatusUpdate(
          status: ReferralStatus.inTransit,
          timestamp: DateTime.now().subtract(const Duration(days: 40)),
          note: 'Patient en route to hospital',
          updatedBy: 'System',
        ),
        ReferralStatusUpdate(
          status: ReferralStatus.completed,
          timestamp: DateTime.now().subtract(const Duration(days: 38)),
          note: 'Consultation completed, treatment plan initiated',
          updatedBy: 'Dr. Ramesh Kumar',
        ),
      ],
    ),
  ];
}
