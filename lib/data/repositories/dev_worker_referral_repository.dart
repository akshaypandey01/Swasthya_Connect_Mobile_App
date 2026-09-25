/// Development repository for worker referrals with mock data

import '../models/worker_referral_model.dart';

class DevWorkerReferralRepository {
  /// Simulates network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  /// Get all referrals for a worker
  Future<List<WorkerReferral>> getReferrals({
    required String workerId,
    ReferralStatusType? status,
  }) async {
    await _simulateDelay();
    var referrals = _mockReferrals.where((r) => r.workerId == workerId).toList();

    if (status != null) {
      referrals = referrals.where((r) => r.status == status).toList();
    }

    // Sort by creation date, newest first
    referrals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return referrals;
  }

  /// Get active referrals
  Future<List<WorkerReferral>> getActiveReferrals(String workerId) async {
    await _simulateDelay();
    return _mockReferrals
        .where((r) =>
            r.workerId == workerId &&
            (r.status == ReferralStatusType.pending ||
                r.status == ReferralStatusType.accepted ||
                r.status == ReferralStatusType.inTransit))
        .toList();
  }

  /// Get single referral by ID
  Future<WorkerReferral?> getReferral(String id) async {
    await _simulateDelay();
    try {
      return _mockReferrals.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create new referral
  Future<WorkerReferral> createReferral({
    required String patientId,
    required String patientName,
    required String workerId,
    required String workerName,
    required String fromFacility,
    required String toFacility,
    required String toFacilityAddress,
    String? toFacilityPhone,
    required String specialization,
    required String reason,
    String? suspectedCondition,
    required ReferralUrgencyLevel urgency,
    required Map<String, dynamic> relevantVitals,
    String? medicalHistory,
    String? specialInstructions,
  }) async {
    await _simulateDelay();

    final referral = WorkerReferral(
      id: 'ref_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      patientName: patientName,
      workerId: workerId,
      workerName: workerName,
      fromFacility: fromFacility,
      toFacility: toFacility,
      toFacilityAddress: toFacilityAddress,
      toFacilityPhone: toFacilityPhone,
      specialization: specialization,
      reason: reason,
      suspectedCondition: suspectedCondition,
      urgency: urgency,
      status: ReferralStatusType.pending,
      createdAt: DateTime.now(),
      relevantVitals: relevantVitals,
      medicalHistory: medicalHistory,
      specialInstructions: specialInstructions,
      attachedDocuments: [],
      statusHistory: [
        ReferralStatusHistory(
          status: ReferralStatusType.pending,
          timestamp: DateTime.now(),
          note: 'Referral created',
          updatedBy: workerName,
        ),
      ],
    );

    _mockReferrals.insert(0, referral);
    return referral;
  }

  /// Update referral status
  Future<bool> updateReferralStatus({
    required String referralId,
    required ReferralStatusType newStatus,
    String? note,
    String? feedback,
    String? rejectionReason,
  }) async {
    await _simulateDelay();

    final index = _mockReferrals.indexWhere((r) => r.id == referralId);
    if (index != -1) {
      final referral = _mockReferrals[index];
      final updatedHistory = List<ReferralStatusHistory>.from(referral.statusHistory)
        ..add(ReferralStatusHistory(
          status: newStatus,
          timestamp: DateTime.now(),
          note: note,
          updatedBy: 'System',
        ));

      _mockReferrals[index] = WorkerReferral(
        id: referral.id,
        patientId: referral.patientId,
        patientName: referral.patientName,
        workerId: referral.workerId,
        workerName: referral.workerName,
        fromFacility: referral.fromFacility,
        toFacility: referral.toFacility,
        toFacilityAddress: referral.toFacilityAddress,
        toFacilityPhone: referral.toFacilityPhone,
        specialization: referral.specialization,
        reason: referral.reason,
        suspectedCondition: referral.suspectedCondition,
        urgency: referral.urgency,
        status: newStatus,
        createdAt: referral.createdAt,
        scheduledDate: referral.scheduledDate,
        completedAt: newStatus == ReferralStatusType.completed
            ? DateTime.now()
            : referral.completedAt,
        relevantVitals: referral.relevantVitals,
        medicalHistory: referral.medicalHistory,
        specialInstructions: referral.specialInstructions,
        attachedDocuments: referral.attachedDocuments,
        statusHistory: updatedHistory,
        rejectionReason: rejectionReason ?? referral.rejectionReason,
        feedback: feedback ?? referral.feedback,
      );
      return true;
    }
    return false;
  }

  /// Mock referrals data
  static final List<WorkerReferral> _mockReferrals = [
    WorkerReferral(
      id: 'ref_001',
      patientId: 'pat_001',
      patientName: 'Rajesh Kumar',
      workerId: 'worker_123',
      workerName: 'Sunita Devi',
      fromFacility: 'SwasthyaConnect PHC, Rampur',
      toFacility: 'District Hospital, Bijnor',
      toFacilityAddress: 'Civil Lines, Bijnor, UP - 246701',
      toFacilityPhone: '+91 1342 262300',
      specialization: 'Cardiology',
      reason: 'Persistent chest pain with abnormal ECG findings',
      suspectedCondition: 'Acute Coronary Syndrome',
      urgency: ReferralUrgencyLevel.urgent,
      status: ReferralStatusType.accepted,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      scheduledDate: DateTime.now().add(const Duration(hours: 12)),
      relevantVitals: {
        'bp': '160/95',
        'pulse': '92',
        'spo2': '96%',
        'temperature': '98.6°F',
      },
      medicalHistory: 'Hypertension for 5 years, currently on medication',
      specialInstructions: 'Patient advised to fast for 6 hours. Ambulance arranged.',
      attachedDocuments: ['ECG Report', 'Medication List'],
      statusHistory: [
        ReferralStatusHistory(
          status: ReferralStatusType.pending,
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          note: 'Referral created by frontline worker',
          updatedBy: 'Sunita Devi',
        ),
        ReferralStatusHistory(
          status: ReferralStatusType.accepted,
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          note: 'Referral accepted. Scheduled for cardiology consultation.',
          updatedBy: 'District Hospital',
        ),
      ],
    ),
    WorkerReferral(
      id: 'ref_002',
      patientId: 'pat_002',
      patientName: 'Priya Sharma',
      workerId: 'worker_123',
      workerName: 'Sunita Devi',
      fromFacility: 'SwasthyaConnect PHC, Rampur',
      toFacility: 'Community Health Center, Chandpur',
      toFacilityAddress: 'Main Road, Chandpur, UP - 244925',
      toFacilityPhone: '+91 5924 222111',
      specialization: 'Obstetrics',
      reason: 'High-risk pregnancy - gestational diabetes detected',
      suspectedCondition: 'Gestational Diabetes Mellitus',
      urgency: ReferralUrgencyLevel.normal,
      status: ReferralStatusType.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      relevantVitals: {
        'bp': '130/85',
        'weight': '72 kg',
        'bloodSugar': '180 mg/dL (fasting)',
      },
      medicalHistory: '28 weeks pregnant, first pregnancy',
      specialInstructions: 'Patient needs glucose tolerance test and specialist consultation',
      attachedDocuments: ['Blood Test Report', 'Ultrasound Report'],
      statusHistory: [
        ReferralStatusHistory(
          status: ReferralStatusType.pending,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          note: 'Referral created for high-risk pregnancy monitoring',
          updatedBy: 'Sunita Devi',
        ),
      ],
    ),
    WorkerReferral(
      id: 'ref_003',
      patientId: 'pat_003',
      patientName: 'Mohan Singh',
      workerId: 'worker_123',
      workerName: 'Sunita Devi',
      fromFacility: 'SwasthyaConnect PHC, Rampur',
      toFacility: 'District Hospital, Bijnor',
      toFacilityAddress: 'Civil Lines, Bijnor, UP - 246701',
      toFacilityPhone: '+91 1342 262300',
      specialization: 'Orthopedics',
      reason: 'Severe knee pain with suspected ligament tear',
      suspectedCondition: 'ACL Tear',
      urgency: ReferralUrgencyLevel.normal,
      status: ReferralStatusType.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      scheduledDate: DateTime.now().subtract(const Duration(days: 12)),
      completedAt: DateTime.now().subtract(const Duration(days: 10)),
      relevantVitals: {
        'bp': '120/80',
        'pulse': '72',
      },
      medicalHistory: 'Sports injury sustained 3 weeks ago',
      specialInstructions: 'X-ray and MRI recommended',
      attachedDocuments: ['X-Ray Report', 'Physical Exam Notes'],
      statusHistory: [
        ReferralStatusHistory(
          status: ReferralStatusType.pending,
          timestamp: DateTime.now().subtract(const Duration(days: 15)),
          note: 'Referral created',
          updatedBy: 'Sunita Devi',
        ),
        ReferralStatusHistory(
          status: ReferralStatusType.accepted,
          timestamp: DateTime.now().subtract(const Duration(days: 14)),
          note: 'Referral accepted',
          updatedBy: 'District Hospital',
        ),
        ReferralStatusHistory(
          status: ReferralStatusType.completed,
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          note: 'Patient consulted. MRI scheduled. Conservative treatment recommended.',
          updatedBy: 'Dr. Ramesh Patel',
        ),
      ],
      feedback: 'Patient responded well to physiotherapy. Follow-up in 4 weeks.',
    ),
  ];
}
