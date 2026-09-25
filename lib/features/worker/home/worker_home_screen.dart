import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../shared/widgets/sc_card.dart';
import '../../shared/widgets/sync_badge.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppColors.secondary,
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

          // ── Primary actions ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Actions',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
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
                ],
              ),
            ),
          ),

          // ── Secondary action grid ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildListDelegate([
                DashboardTile(
                  icon: Icons.monitor_heart_rounded,
                  label: 'Vitals\nEntry',
                  iconColor: AppColors.primary,
                  bgColor: AppColors.primaryContainer,
                  onTap: () => context.push(AppRoutes.vitalsEntry,
                      extra: {'patientId': ''}),
                ),
                DashboardTile(
                  icon: Icons.sick_rounded,
                  label: 'Symptom\nInput',
                  iconColor: const Color(0xFFD84315),
                  bgColor: const Color(0xFFFBE9E7),
                  onTap: () => context.push(AppRoutes.symptomInput,
                      extra: {'encounterId': ''}),
                ),
                DashboardTile(
                  icon: Icons.upload_file_rounded,
                  label: 'Upload\nRecords',
                  iconColor: const Color(0xFF7B2FBE),
                  bgColor: const Color(0xFFEDE7F6),
                  onTap: () => context.push(AppRoutes.uploadRecords,
                      extra: {'patientId': ''}),
                ),
                DashboardTile(
                  icon: Icons.video_call_rounded,
                  label: 'Tele-\nconsult',
                  iconColor: const Color(0xFF00897B),
                  bgColor: const Color(0xFFE0F2F1),
                  onTap: () => context.push(AppRoutes.workerTeleconsult,
                      extra: {'priority': 'routine'}),
                ),
                DashboardTile(
                  icon: Icons.emergency_rounded,
                  label: 'Emergency',
                  iconColor: AppColors.emergency,
                  bgColor: AppColors.emergencyLight,
                  onTap: () => context.push(AppRoutes.emergencyEscalation,
                      extra: {'patientId': ''}),
                ),
                DashboardTile(
                  icon: Icons.event_repeat_rounded,
                  label: 'Follow-\nups',
                  iconColor: AppColors.secondary,
                  bgColor: AppColors.secondaryContainer,
                  onTap: () => context.push(AppRoutes.followUpTrackers,
                      extra: {'patientId': ''}),
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
                  icon: Icons.send_rounded,
                  label: 'Referral\nManagement',
                  iconColor: const Color(0xFF0277BD),
                  bgColor: const Color(0xFFE1F5FE),
                  onTap: () => context.push(AppRoutes.workerReferralList),
                ),
                DashboardTile(
                  icon: Icons.analytics_rounded,
                  label: 'Reports &\nAnalytics',
                  iconColor: const Color(0xFF6A1B9A),
                  bgColor: const Color(0xFFF3E5F5),
                  onTap: () => context.push(AppRoutes.workerReports),
                ),
                DashboardTile(
                  icon: Icons.notifications_rounded,
                  label: 'Notifications\n& Alerts',
                  iconColor: const Color(0xFFE65100),
                  bgColor: const Color(0xFFFFF3E0),
                  badgeCount: 3, // Will be dynamic from notification repository
                  onTap: () => context.push(AppRoutes.workerNotifications),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
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
