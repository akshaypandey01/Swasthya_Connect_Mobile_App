/// Worker performance and analytics data models

class WorkerPerformance {
  final String workerId;
  final String workerName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int patientsRegistered;
  final int triageSessions;
  final int referralsMade;
  final int followUpsCompleted;
  final int teleconsultsFacilitated;
  final int emergencyCases;
  final int recordsUploaded;
  final Map<String, int> triageByCategory; // green, yellow, red, critical
  final double averageSessionTime; // in minutes
  final List<DailyActivity> dailyActivities;
  
  // Additional properties for UI
  final int totalVisits;
  final int completedVisits;
  final int pendingVisits;
  final double successRate; // 0.0 to 1.0

  WorkerPerformance({
    required this.workerId,
    required this.workerName,
    required this.periodStart,
    required this.periodEnd,
    required this.patientsRegistered,
    required this.triageSessions,
    required this.referralsMade,
    required this.followUpsCompleted,
    required this.teleconsultsFacilitated,
    required this.emergencyCases,
    required this.recordsUploaded,
    required this.triageByCategory,
    required this.averageSessionTime,
    required this.dailyActivities,
    required this.totalVisits,
    required this.completedVisits,
    required this.pendingVisits,
    required this.successRate,
  });

  int get totalActivities =>
      patientsRegistered +
      triageSessions +
      referralsMade +
      followUpsCompleted +
      teleconsultsFacilitated;
}

class DailyActivity {
  final DateTime date;
  final int patientsRegistered;
  final int triageSessions;
  final int referralsMade;
  final int followUpsCompleted;

  DailyActivity({
    required this.date,
    required this.patientsRegistered,
    required this.triageSessions,
    required this.referralsMade,
    required this.followUpsCompleted,
  });
}

class AssignedPatient {
  final String patientId;
  final String name;
  final int age;
  final String gender;
  final String? abhaId;
  final String? phone;
  final DateTime lastVisit;
  final int totalVisits;
  final String? latestCondition;
  final bool hasPendingFollowUp;
  final bool hasAbnormalVitals;
  
  // Additional properties for UI
  final String village;
  final String riskLevel; // low, medium, high
  final List<String> conditions;
  final DateTime? nextVisitDue;

  AssignedPatient({
    required this.patientId,
    required this.name,
    required this.age,
    required this.gender,
    this.abhaId,
    this.phone,
    required this.lastVisit,
    required this.totalVisits,
    this.latestCondition,
    this.hasPendingFollowUp = false,
    this.hasAbnormalVitals = false,
    required this.village,
    required this.riskLevel,
    required this.conditions,
    this.nextVisitDue,
  });
}

class PendingTask {
  final String id;
  final String taskType; // home_visit, follow_up, vaccination, screening
  final String patientId;
  final String patientName;
  final String description;
  final DateTime dueDate;
  final String priority; // low, medium, high
  final bool isOverdue;

  PendingTask({
    required this.id,
    required this.taskType,
    required this.patientId,
    required this.patientName,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isOverdue,
  });
}

class CriticalAlert {
  final String id;
  final String patientId;
  final String patientName;
  final String alertType; // abnormal-vitals, emergency, missed-followup
  final String message; // Changed from description to message
  final String severity; // low, medium, high, critical
  final DateTime timestamp;
  final bool acknowledged;
  final String recommendedAction;

  CriticalAlert({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.alertType,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.acknowledged = false,
    required this.recommendedAction,
  });
}
