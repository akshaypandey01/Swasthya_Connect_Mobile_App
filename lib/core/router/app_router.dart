import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/patient/patient_login_screen.dart';
import '../../features/auth/patient/patient_otp_screen.dart';
import '../../features/auth/worker/worker_login_screen.dart';
import '../../features/auth/worker/worker_otp_screen.dart';
import '../../features/shared/splash_screen.dart';
import '../../features/shared/language_select_screen.dart';
import '../../features/shared/role_select_screen.dart';

// Patient screens
import '../../features/patient/home/patient_home_screen.dart';
import '../../features/patient/health_assessment/health_assessment_screen.dart';
import '../../features/patient/health_locker/health_locker_screen.dart';
import '../../features/patient/appointment/appointment_booking_screen.dart';
import '../../features/patient/appointment/appointments_list_screen.dart';
import '../../features/patient/queue/live_queue_screen.dart';
import '../../features/patient/teleconsult/teleconsult_screen.dart';
import '../../features/patient/menstrual_tracker/menstrual_tracker_screen.dart';
import '../../features/patient/pregnancy_tracker/pregnancy_tracker_screen.dart';
import '../../features/patient/child_vaccination/child_vaccination_screen.dart';
import '../../features/patient/vaccination/vaccination_tracker_screen.dart';
import '../../features/patient/consent/consent_screen.dart';
import '../../features/patient/medicine/medicine_screen.dart';
import '../../features/patient/health_info/health_info_screen.dart';
import '../../features/patient/scheme_eligibility/scheme_eligibility_screen.dart';
import '../../features/patient/feedback/feedback_screen.dart';
import '../../features/patient/emergency_sos/emergency_sos_screen.dart';
import '../../features/patient/profile/patient_profile_screen.dart';
import '../../features/patient/referral/referral_list_screen.dart';
import '../../features/patient/referral/referral_details_screen.dart';
import '../../features/patient/followup/followup_list_screen.dart';
import '../../features/patient/followup/followup_details_screen.dart';
import '../../features/patient/family/family_list_screen.dart';
import '../../features/patient/family/add_family_member_screen.dart';
import '../../features/patient/family/family_member_details_screen.dart';
import '../../features/patient/medibot/medibot_screen.dart';

// Worker screens
import '../../features/worker/home/worker_home_screen.dart';
import '../../features/worker/my_work/my_work_screen.dart';
import '../../features/worker/patients/worker_patients_screen.dart';
import '../../features/worker/find_patient/find_patient_screen.dart';
import '../../features/worker/register_patient/register_patient_screen.dart';
import '../../features/worker/patient_profile/worker_patient_profile_screen.dart';
import '../../features/worker/upload_records/upload_records_screen.dart';
import '../../features/worker/vitals_entry/vitals_entry_screen.dart';
import '../../features/worker/symptom_input/symptom_input_screen.dart';
import '../../features/worker/triage_result/triage_result_screen.dart';
import '../../features/worker/teleconsult/worker_teleconsult_screen.dart';
import '../../features/worker/emergency_escalation/emergency_escalation_screen.dart';
import '../../features/worker/follow_up/follow_up_screen.dart';
import '../../features/worker/sync_status/sync_status_screen.dart';
import '../../features/worker/profile/worker_profile_screen.dart';
import '../../features/worker/referral_management/worker_referral_list_screen.dart';
import '../../features/worker/referral_management/create_referral_screen.dart';
import '../../features/worker/referral_management/worker_referral_details_screen.dart';
import '../../features/worker/reports_analytics/worker_reports_screen.dart';
import '../../features/worker/reports_analytics/worker_assigned_patients_screen.dart';
import '../../features/worker/reports_analytics/worker_pending_tasks_screen.dart';
import '../../features/worker/reports_analytics/worker_critical_alerts_screen.dart';
import '../../features/worker/notifications/worker_notifications_screen.dart';

import '../constants/app_routes.dart';
import '../constants/hive_constants.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final box = Hive.box(HiveConstants.settingsBox);
      final roleStr = box.get(HiveConstants.userRoleKey) as String?;

      final isAtAuth = state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.languageSelect ||
          state.matchedLocation == '/role-select' ||
          state.matchedLocation.startsWith('/patient/login') ||
          state.matchedLocation.startsWith('/patient/otp') ||
          state.matchedLocation.startsWith('/worker/login') ||
          state.matchedLocation.startsWith('/worker/otp');

      if (roleStr == null && !isAtAuth) return AppRoutes.splash;
      return null;
    },
    routes: [
      // ── Shared ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.languageSelect,
        builder: (_, __) => const LanguageSelectScreen(),
      ),
      GoRoute(
        path: '/role-select',
        builder: (_, __) => const RoleSelectScreen(),
      ),

      // ── Patient auth ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.patientLogin,
        builder: (_, __) => const PatientLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientOtp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PatientOtpScreen(
            abhaId: extra?['abhaId'] as String? ?? '',
            phone: extra?['phone'] as String? ?? '',
          );
        },
      ),

      // ── Worker auth ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.workerLogin,
        builder: (_, __) => const WorkerLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerOtp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WorkerOtpScreen(
            rchId: extra?['rchId'] as String? ?? '',
            phone: extra?['phone'] as String? ?? '',
          );
        },
      ),

      // ── Patient app ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.patientHome,
        builder: (_, __) => const PatientHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthAssessment,
        builder: (_, __) => const HealthAssessmentScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthLocker,
        builder: (_, __) => const HealthLockerScreen(),
      ),
      GoRoute(
        path: AppRoutes.appointmentBooking,
        builder: (_, __) => const AppointmentBookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.appointmentsList,
        builder: (_, __) => const AppointmentsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.liveQueue,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return LiveQueueScreen(appointmentId: extra?['appointmentId'] as String? ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.teleconsult,
        builder: (_, __) => const TeleconsultScreen(),
      ),
      GoRoute(
        path: AppRoutes.menstrualTracker,
        builder: (_, __) => const MenstrualTrackerScreen(),
      ),
      GoRoute(
        path: AppRoutes.pregnancyTracker,
        builder: (_, __) => const PregnancyTrackerScreen(),
      ),
      GoRoute(
        path: AppRoutes.childVaccination,
        builder: (_, __) => const ChildVaccinationScreen(),
      ),
      GoRoute(
        path: AppRoutes.vaccinationTracker,
        builder: (_, __) => const VaccinationTrackerScreen(),
      ),
      GoRoute(
        path: AppRoutes.consentManagement,
        builder: (_, __) => const ConsentScreen(),
      ),
      GoRoute(
        path: AppRoutes.myMedicine,
        builder: (_, __) => const MedicineScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthInfo,
        builder: (_, __) => const HealthInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.schemeEligibility,
        builder: (_, __) => const SchemeEligibilityScreen(),
      ),
      GoRoute(
        path: AppRoutes.feedbackGrievance,
        builder: (_, __) => const FeedbackScreen(),
      ),
      GoRoute(
        path: AppRoutes.emergencySos,
        builder: (_, __) => const EmergencySosScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientProfile,
        builder: (_, __) => const PatientProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.referralTracker,
        builder: (_, __) => const ReferralListScreen(),
      ),
      GoRoute(
        path: AppRoutes.referralDetails,
        builder: (context, state) {
          final referralId = state.extra as String;
          return ReferralDetailsScreen(referralId: referralId);
        },
      ),
      GoRoute(
        path: AppRoutes.followUpTracker,
        builder: (_, __) => const FollowUpListScreen(),
      ),
      GoRoute(
        path: AppRoutes.followUpDetails,
        builder: (context, state) {
          final followUpId = state.extra as String;
          return FollowUpDetailsScreen(followUpId: followUpId);
        },
      ),
      GoRoute(
        path: AppRoutes.familyMembers,
        builder: (_, __) => const FamilyListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addFamilyMember,
        builder: (_, __) => const AddFamilyMemberScreen(),
      ),
      GoRoute(
        path: AppRoutes.familyMemberDetails,
        builder: (context, state) {
          final memberId = state.extra as String;
          return FamilyMemberDetailsScreen(memberId: memberId);
        },
      ),
      GoRoute(
        path: AppRoutes.medibot,
        builder: (_, __) => const MedibotScreen(),
      ),

      // ── Worker app ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.workerHome,
        builder: (_, __) => const WorkerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.myWork,
        builder: (_, __) => const MyWorkScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerPatients,
        builder: (_, __) => const WorkerPatientsScreen(),
      ),
      GoRoute(
        path: AppRoutes.findPatient,
        builder: (_, __) => const FindPatientScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerPatient,
        builder: (_, __) => const RegisterPatientScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerPatientProfile,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WorkerPatientProfileScreen(
              patientId: extra?['patientId'] as String? ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.uploadRecords,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return UploadRecordsScreen(patientId: extra?['patientId'] as String? ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.vitalsEntry,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VitalsEntryScreen(patientId: extra?['patientId'] as String? ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.symptomInput,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SymptomInputScreen(encounterId: extra?['encounterId'] as String? ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.triageResult,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TriageResultScreen(
            vitals: Map<String, dynamic>.from(extra?['vitals'] ?? {}),
            symptoms: Map<String, dynamic>.from(extra?['symptoms'] ?? {}),
            patientId: extra?['patientId'] ?? '',
            encounterId: extra?['encounterId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.workerTeleconsult,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WorkerTeleconsultScreen(
              priority: extra?['priority'] as String? ?? 'routine');
        },
      ),
      GoRoute(
        path: AppRoutes.emergencyEscalation,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EmergencyEscalationScreen(
              patientId: extra?['patientId'] as String? ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.followUpTrackers,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return FollowUpScreen(patientId: extra?['patientId'] as String? ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.workerSyncStatus,
        builder: (_, __) => const SyncStatusScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerProfile,
        builder: (_, __) => const WorkerProfileScreen(),
      ),

      // ── Worker Referral Management ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.workerReferralList,
        builder: (_, __) => const WorkerReferralListScreen(),
      ),
      GoRoute(
        path: AppRoutes.createReferral,
        builder: (_, __) => const CreateReferralScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerReferralDetails,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WorkerReferralDetailsScreen(
            referralId: extra?['referralId'] as String? ?? '',
          );
        },
      ),

      // ── Worker Reports & Analytics ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.workerReports,
        builder: (_, __) => const WorkerReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerAssignedPatients,
        builder: (_, __) => const WorkerAssignedPatientsScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerPendingTasks,
        builder: (_, __) => const WorkerPendingTasksScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerCriticalAlerts,
        builder: (_, __) => const WorkerCriticalAlertsScreen(),
      ),

      // ── Worker Notifications & Alerts ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.workerNotifications,
        builder: (_, __) => const WorkerNotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.workerNotificationDetails,
        builder: (context, state) {
          // Note: This would need the notification object passed via extra
          // For now, handled via direct navigation in the notification list
          return const WorkerNotificationsScreen();
        },
      ),
    ],
  );
});
