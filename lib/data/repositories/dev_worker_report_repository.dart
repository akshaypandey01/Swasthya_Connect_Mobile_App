/// Development repository for worker reports and analytics with mock data

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/worker_report_model.dart';

final devWorkerReportRepositoryProvider = Provider((ref) => DevWorkerReportRepository());

class DevWorkerReportRepository {
  /// Simulates network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }
  
  /// Synchronous getters for immediate data access (for development)
  WorkerPerformance getWorkerPerformance() {
    return _mockPerformance;
  }
  
  List<AssignedPatient> getAssignedPatients() {
    return _mockAssignedPatients;
  }
  
  List<PendingTask> getPendingTasks() {
    return _mockPendingTasks;
  }
  
  List<CriticalAlert> getCriticalAlerts() {
    return _mockCriticalAlerts.where((a) => !a.acknowledged).toList();
  }

  /// Get worker performance for a period (async version)
  Future<WorkerPerformance> getPerformance({
    required String workerId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    await _simulateDelay();
    return _mockPerformance;
  }

  /// Get assigned patients (async version)
  Future<List<AssignedPatient>> getAssignedPatientsAsync(String workerId) async {
    await _simulateDelay();
    return _mockAssignedPatients;
  }

  /// Get pending tasks (async version)
  Future<List<PendingTask>> getPendingTasksAsync(String workerId) async {
    await _simulateDelay();
    return _mockPendingTasks;
  }

  /// Get critical alerts (async version)
  Future<List<CriticalAlert>> getCriticalAlertsAsync(String workerId) async {
    await _simulateDelay();
    return _mockCriticalAlerts.where((a) => !a.acknowledged).toList();
  }

  /// Acknowledge alert
  Future<bool> acknowledgeAlert(String alertId) async {
    await _simulateDelay();
    final index = _mockCriticalAlerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _mockCriticalAlerts[index] = CriticalAlert(
        id: _mockCriticalAlerts[index].id,
        patientId: _mockCriticalAlerts[index].patientId,
        patientName: _mockCriticalAlerts[index].patientName,
        alertType: _mockCriticalAlerts[index].alertType,
        message: _mockCriticalAlerts[index].message,
        severity: _mockCriticalAlerts[index].severity,
        timestamp: _mockCriticalAlerts[index].timestamp,
        acknowledged: true,
        recommendedAction: _mockCriticalAlerts[index].recommendedAction,
      );
      return true;
    }
    return false;
  }

  /// Mock performance data
  static final _mockPerformance = WorkerPerformance(
    workerId: 'worker_001',
    workerName: 'Sunita Devi',
    periodStart: DateTime.now().subtract(const Duration(days: 30)),
    periodEnd: DateTime.now(),
    patientsRegistered: 42,
    triageSessions: 89,
    referralsMade: 15,
    followUpsCompleted: 56,
    teleconsultsFacilitated: 23,
    emergencyCases: 7,
    recordsUploaded: 134,
    triageByCategory: {
      'green': 45,
      'yellow': 32,
      'red': 10,
      'critical': 2,
    },
    averageSessionTime: 18.5,
    dailyActivities: [],
    totalVisits: 125,
    completedVisits: 112,
    pendingVisits: 13,
    successRate: 0.896,
  );

  /// Mock data
  static final List<AssignedPatient> _mockAssignedPatients = [
    AssignedPatient(
      patientId: 'pat_001',
      name: 'Rajesh Kumar',
      age: 45,
      gender: 'Male',
      abhaId: '12-3456-7890-1234',
      phone: '+91 98765 43210',
      lastVisit: DateTime.now().subtract(const Duration(days: 3)),
      totalVisits: 12,
      latestCondition: 'Hypertension',
      hasPendingFollowUp: true,
      hasAbnormalVitals: false,
      village: 'Rampur',
      riskLevel: 'high',
      conditions: ['Hypertension', 'Pre-diabetes'],
      nextVisitDue: DateTime.now().add(const Duration(days: 4)),
    ),
    AssignedPatient(
      patientId: 'pat_002',
      name: 'Priya Sharma',
      age: 28,
      gender: 'Female',
      abhaId: '98-7654-3210-9876',
      phone: '+91 98234 56789',
      lastVisit: DateTime.now().subtract(const Duration(days: 1)),
      totalVisits: 8,
      latestCondition: 'Gestational Diabetes',
      hasPendingFollowUp: false,
      hasAbnormalVitals: true,
      village: 'Balpur',
      riskLevel: 'high',
      conditions: ['Gestational Diabetes', 'Anemia'],
      nextVisitDue: DateTime.now().add(const Duration(days: 7)),
    ),
    AssignedPatient(
      patientId: 'pat_003',
      name: 'Mohan Singh',
      age: 32,
      gender: 'Male',
      phone: '+91 97123 45678',
      lastVisit: DateTime.now().subtract(const Duration(days: 10)),
      totalVisits: 5,
      latestCondition: 'ACL Tear',
      hasPendingFollowUp: false,
      hasAbnormalVitals: false,
      village: 'Rampur',
      riskLevel: 'low',
      conditions: ['ACL Tear - Recovery'],
      nextVisitDue: DateTime.now().add(const Duration(days: 14)),
    ),
    AssignedPatient(
      patientId: 'pat_004',
      name: 'Lakshmi Devi',
      age: 62,
      gender: 'Female',
      abhaId: '11-2233-4455-6677',
      phone: '+91 96543 21098',
      lastVisit: DateTime.now().subtract(const Duration(days: 7)),
      totalVisits: 25,
      latestCondition: 'Type 2 Diabetes',
      hasPendingFollowUp: true,
      hasAbnormalVitals: false,
      village: 'Singharpur',
      riskLevel: 'medium',
      conditions: ['Type 2 Diabetes', 'Osteoarthritis'],
      nextVisitDue: DateTime.now().add(const Duration(days: 3)),
    ),
    AssignedPatient(
      patientId: 'pat_005',
      name: 'Amit Verma',
      age: 38,
      gender: 'Male',
      phone: '+91 95432 10987',
      lastVisit: DateTime.now().subtract(const Duration(days: 5)),
      totalVisits: 6,
      latestCondition: 'Respiratory Infection',
      hasPendingFollowUp: false,
      hasAbnormalVitals: false,
      village: 'Balpur',
      riskLevel: 'low',
      conditions: ['Respiratory Infection - Resolving'],
      nextVisitDue: null,
    ),
  ];

  static final List<PendingTask> _mockPendingTasks = [
    PendingTask(
      id: 'task_001',
      taskType: 'follow_up',
      patientId: 'pat_001',
      patientName: 'Rajesh Kumar',
      description: 'Blood pressure monitoring follow-up',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: 'high',
      isOverdue: false,
    ),
    PendingTask(
      id: 'task_002',
      taskType: 'home_visit',
      patientId: 'pat_002',
      patientName: 'Priya Sharma',
      description: 'Antenatal check-up and blood sugar monitoring',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      priority: 'high',
      isOverdue: true,
    ),
    PendingTask(
      id: 'task_003',
      taskType: 'screening',
      patientId: 'pat_004',
      patientName: 'Lakshmi Devi',
      description: 'Diabetes management check - HbA1c results review',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      priority: 'medium',
      isOverdue: false,
    ),
    PendingTask(
      id: 'task_004',
      taskType: 'vaccination',
      patientId: 'pat_003',
      patientName: 'Mohan Singh',
      description: 'Tetanus booster vaccination due',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: 'low',
      isOverdue: false,
    ),
  ];

  static final List<CriticalAlert> _mockCriticalAlerts = [
    CriticalAlert(
      id: 'alert_001',
      patientId: 'pat_002',
      patientName: 'Priya Sharma',
      alertType: 'Vital Signs Abnormal',
      message: 'Fasting blood sugar: 195 mg/dL (High). Blood pressure: 145/95 mmHg.',
      severity: 'high',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      acknowledged: false,
      recommendedAction: 'Schedule immediate follow-up visit and consult with physician about medication adjustment.',
    ),
    CriticalAlert(
      id: 'alert_002',
      patientId: 'pat_001',
      patientName: 'Rajesh Kumar',
      alertType: 'Medication Missed',
      message: 'Patient reported missing blood pressure medication for 3 consecutive days.',
      severity: 'high',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      acknowledged: false,
      recommendedAction: 'Contact patient immediately to verify medication status and schedule counseling session.',
    ),
    CriticalAlert(
      id: 'alert_003',
      patientId: 'pat_006',
      patientName: 'Ramesh Yadav',
      alertType: 'Emergency Visit Required',
      message: 'Severe chest pain and difficulty breathing reported during home visit.',
      severity: 'critical',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      acknowledged: false,
      recommendedAction: 'IMMEDIATE ACTION: Call emergency services. Arrange ambulance transport to district hospital.',
    ),
  ];
}
