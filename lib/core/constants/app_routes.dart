class AppRoutes {
  AppRoutes._();

  // Shared
  static const String splash = '/';
  static const String languageSelect = '/language-select';

  // Patient auth
  static const String patientLogin = '/patient/login';
  static const String patientOtp = '/patient/otp';

  // Worker auth
  static const String workerLogin = '/worker/login';
  static const String workerOtp = '/worker/otp';

  // Patient app
  static const String patientHome = '/patient/home';
  static const String healthAssessment = '/patient/health-assessment';
  static const String healthLocker = '/patient/health-locker';
  static const String appointmentBooking = '/patient/appointment';
  static const String appointmentsList = '/patient/appointments';
  static const String liveQueue = '/patient/queue';
  static const String teleconsult = '/patient/teleconsult';
  static const String menstrualTracker = '/patient/menstrual';
  static const String pregnancyTracker = '/patient/pregnancy';
  static const String childVaccination = '/patient/child-vaccination';
  static const String vaccinationTracker = '/patient/vaccination';
  static const String consentManagement = '/patient/consent';
  static const String myMedicine = '/patient/medicine';
  static const String healthInfo = '/patient/health-info';
  static const String schemeEligibility = '/patient/scheme';
  static const String feedbackGrievance = '/patient/feedback';
  static const String emergencySos = '/patient/sos';
  static const String patientProfile = '/patient/profile';
  static const String referralTracker = '/patient/referral';
  static const String referralDetails = '/patient/referral/details';
  static const String followUpTracker = '/patient/followup';
  static const String followUpDetails = '/patient/followup/details';
  static const String familyMembers = '/patient/family';
  static const String addFamilyMember = '/patient/family/add';
  static const String editFamilyMember = '/patient/family/edit';
  static const String familyMemberDetails = '/patient/family/details';
  static const String medibot = '/patient/medibot';

  // Worker app
  static const String workerHome = '/worker/home';
  static const String myWork = '/worker/my-work';
  static const String workerPatients = '/worker/patients';
  static const String findPatient = '/worker/find-patient';
  static const String registerPatient = '/worker/register-patient';
  static const String workerPatientProfile = '/worker/patient-profile';
  static const String uploadRecords = '/worker/upload-records';
  static const String vitalsEntry = '/worker/vitals';
  static const String symptomInput = '/worker/symptoms';
  static const String triageResult = '/worker/triage';
  static const String workerTeleconsult = '/worker/teleconsult';
  static const String emergencyEscalation = '/worker/emergency';
  static const String followUpTrackers = '/worker/follow-up';
  static const String workerSyncStatus = '/worker/sync';
  static const String workerProfile = '/worker/profile';
  static const String workerReferralList = '/worker/referral';
  static const String createReferral = '/worker/referral/create';
  static const String workerReferralDetails = '/worker/referral/details';
  static const String workerReports = '/worker/reports';
  static const String workerAssignedPatients = '/worker/reports/patients';
  static const String workerPendingTasks = '/worker/reports/tasks';
  static const String workerCriticalAlerts = '/worker/reports/alerts';
  static const String workerNotifications = '/worker/notifications';
  static const String workerNotificationDetails = '/worker/notifications/details';
}
