import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../data/repositories/dev_worker_report_repository.dart';
import '../../shared/widgets/sc_card.dart';
import '../../shared/widgets/sync_badge.dart';
import '../../shared/widgets/worker_bottom_nav.dart';
import '../../shared/widgets/section_header.dart';
import 'package:intl/intl.dart';

class WorkerHomeScreen extends ConsumerWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = Hive.box(HiveConstants.settingsBox);
    final name = box.get('worker_name', defaultValue: 'Worker') as String;
    final isSyncing = ref.watch(isSyncingProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final lastSynced = ref.watch(lastSyncedProvider);
    final syncService = ref.read(syncServiceProvider);
    final pendingCount = syncService.pendingCount;
    
    // Get actual notification count from repository
    final reportRepo = ref.read(devWorkerReportRepositoryProvider);
    final notificationCount = reportRepo.getCriticalAlerts().length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppColors.secondary,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_rounded, color: Colors.white),
                onPressed: () => context.push(AppRoutes.workerProfile),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondaryDark, AppColors.secondaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: Image.asset(
                                        'assets/images/swasthya_connect_logo.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('SwasthyaConnect',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('By HealthSync1 | Team ID: 165109',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.85))),
                              const SizedBox(height: 10),
                              const Text('Frontline Worker',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70)),
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        const SyncBadge(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Sync Status Card ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ScCard(
                color: isOnline ? AppColors.secondaryContainer : const Color(0xFFFFF8E1),
                child: Row(
                  children: [
                    Icon(
                      isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                      color: isOnline ? AppColors.secondary : AppColors.syncPending,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOnline ? 'Connected' : 'Offline Mode',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isOnline
                                  ? AppColors.secondary
                                  : AppColors.syncPending,
                            ),
                          ),
                          Text(
                            pendingCount > 0
                                ? '$pendingCount record(s) pending sync'
                                : lastSynced != null
                                    ? 'Last synced: ${DateFormat('dd MMM, hh:mm a').format(lastSynced)}'
                                    : 'All records synced',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (isOnline)
                      TextButton(
                        onPressed: isSyncing
                            ? null
                            : () => ref.read(syncServiceProvider).syncAll(),
                        child: Text(isSyncing ? 'Syncing…' : 'Sync Now'),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── QUICK ACTIONS ────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Quick Actions',
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _PrimaryActionButton(
                      icon: Icons.person_search_rounded,
                      label: 'Find Patient',
                      labelHi: 'मरीज़ खोजें',
                      color: AppColors.primary,
                      bg: AppColors.primaryContainer,
                      onTap: () => context.push(AppRoutes.findPatient),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PrimaryActionButton(
                      icon: Icons.person_add_rounded,
                      label: 'Register',
                      labelHi: 'पंजीकरण',
                      color: AppColors.secondary,
                      bg: AppColors.secondaryContainer,
                      onTap: () => context.push(AppRoutes.registerPatient),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── NOTIFICATIONS & ALERTS ───────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Notifications & Alerts',
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.workerNotifications),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.notifications_rounded,
                                color: Color(0xFFE65100),
                                size: 28,
                              ),
                            ),
                            // Badge for notification count
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.triageRed,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  notificationCount > 99 
                                      ? '99+' 
                                      : notificationCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications & Alerts',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notificationCount == 0
                              ? 'No new alerts'
                              : notificationCount == 1
                                  ? '1 new alert requires attention'
                                  : '$notificationCount new alerts require attention',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── CARE WORKFLOW ────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Care Workflow',
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildListDelegate([
                // Row 1: Vitals Entry | Symptom Input | Emergency
                DashboardTile(
                  icon: Icons.monitor_heart_rounded,
                  label: 'Vitals\nEntry',
                  iconColor: AppColors.primary,
                  bgColor: AppColors.primaryContainer,
                  onTap: () {
                    final patientId = box.get('current_patient_id', defaultValue: 'demo-patient-001') as String;
                    context.push(AppRoutes.vitalsEntry, extra: {'patientId': patientId});
                  },
                ),
                DashboardTile(
                  icon: Icons.sick_rounded,
                  label: 'Symptom\nInput',
                  iconColor: AppColors.primary,
                  bgColor: AppColors.primaryContainer,
                  onTap: () {
                    final patientId = box.get('current_patient_id', defaultValue: 'demo-patient-001') as String;
                    context.push(AppRoutes.symptomInput, extra: {'patientId': patientId});
                  },
                ),
                DashboardTile(
                  icon: Icons.emergency_rounded,
                  label: 'Emergency',
                  iconColor: AppColors.emergency,
                  bgColor: AppColors.emergencyLight,
                  onTap: () {
                    final patientId = box.get('current_patient_id', defaultValue: 'demo-patient-001') as String;
                    context.push(AppRoutes.emergencyEscalation, extra: {'patientId': patientId});
                  },
                ),
                
                // Row 2: Tele-consult | Referral Management | Follow-ups
                DashboardTile(
                  icon: Icons.video_call_rounded,
                  label: 'Tele-\nconsult',
                  iconColor: AppColors.primary,
                  bgColor: AppColors.primaryContainer,
                  onTap: () => context.push(AppRoutes.workerTeleconsult,
                      extra: {'priority': 'routine'}),
                ),
                DashboardTile(
                  icon: Icons.send_rounded,
                  label: 'Referral\nManagement',
                  iconColor: AppColors.primary,
                  bgColor: AppColors.primaryContainer,
                  onTap: () => context.push(AppRoutes.workerReferralList),
                ),
                DashboardTile(
                  icon: Icons.event_repeat_rounded,
                  label: 'Follow-\nups',
                  iconColor: AppColors.primary,
                  bgColor: AppColors.primaryContainer,
                  onTap: () {
                    final patientId = box.get('current_patient_id', defaultValue: 'demo-patient-001') as String;
                    context.push(AppRoutes.followUpTrackers, extra: {'patientId': patientId});
                  },
                ),
                
                // Row 3: Upload Records | Sync Status | Reports & Analytics
                DashboardTile(
                  icon: Icons.upload_file_rounded,
                  label: 'Upload\nRecords',
                  iconColor: AppColors.primary,
                  bgColor: AppColors.primaryContainer,
                  onTap: () {
                    final patientId = box.get('current_patient_id', defaultValue: 'demo-patient-001') as String;
                    context.push(AppRoutes.uploadRecords, extra: {'patientId': patientId});
                  },
                ),
                DashboardTile(
                  icon: Icons.sync_rounded,
                  label: 'Sync\nStatus',
                  iconColor: AppColors.primary,
                  bgColor: AppColors.primaryContainer,
                  badgeCount: pendingCount,
                  onTap: () => context.push(AppRoutes.workerSyncStatus),
                ),
                DashboardTile(
                  icon: Icons.analytics_rounded,
                  label: 'Reports &\nAnalytics',
                  iconColor: AppColors.primary,
                  bgColor: AppColors.primaryContainer,
                  onTap: () => context.push(AppRoutes.workerReports),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 0),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label, labelHi;
  final Color color, bg;
  final VoidCallback onTap;
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.labelHi,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  Text(labelHi,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
