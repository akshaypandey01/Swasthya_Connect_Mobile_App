import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../core/services/sync_service.dart';
import '../../../data/repositories/dev_worker_report_repository.dart';
import '../../../data/models/worker_report_model.dart';
import '../../shared/widgets/worker_bottom_nav.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/empty_state.dart';

class MyWorkScreen extends ConsumerWidget {
  const MyWorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = Hive.box(HiveConstants.settingsBox);
    final name = box.get('worker_name', defaultValue: 'Worker') as String;
    final reportRepo = ref.read(devWorkerReportRepositoryProvider);
    final syncService = ref.read(syncServiceProvider);
    
    // Get data from existing repository with error handling
    List<dynamic> criticalAlerts = [];
    List<dynamic> pendingTasks = [];
    List<dynamic> assignedPatients = [];
    int pendingSync = 0;
    
    try {
      criticalAlerts = reportRepo.getCriticalAlerts();
      pendingTasks = reportRepo.getPendingTasks();
      assignedPatients = reportRepo.getAssignedPatients();
      pendingSync = syncService.pendingCount;
    } catch (e) {
      // Log error but continue with empty lists
      // In production, this would use proper error reporting
    }

    // Calculate today's metrics
    final todayTasks = pendingTasks.where((task) {
      final today = DateTime.now();
      return task.dueDate.year == today.year &&
          task.dueDate.month == today.month &&
          task.dueDate.day == today.day;
    }).toList();

    final overdueTasks = pendingTasks.where((task) => task.isOverdue).toList();

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
                        const Text('My Work',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── TODAY ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Summary Cards ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              delegate: SliverChildListDelegate([
                _SummaryCard(
                  icon: Icons.warning_rounded,
                  label: 'Critical Alerts',
                  count: criticalAlerts.length,
                  color: AppColors.triageRed,
                  onTap: () => context.push(AppRoutes.workerCriticalAlerts),
                ),
                _SummaryCard(
                  icon: Icons.task_alt_rounded,
                  label: 'Pending Tasks',
                  count: pendingTasks.length,
                  color: AppColors.syncPending,
                  onTap: () => context.push(AppRoutes.workerPendingTasks),
                ),
                _SummaryCard(
                  icon: Icons.people_rounded,
                  label: 'Assigned Patients',
                  count: assignedPatients.length,
                  color: AppColors.primary,
                  onTap: () => context.push(AppRoutes.workerAssignedPatients),
                ),
                _SummaryCard(
                  icon: Icons.sync_problem_rounded,
                  label: 'Pending Sync',
                  count: pendingSync,
                  color: pendingSync > 0 ? AppColors.syncPending : AppColors.syncSynced,
                  onTap: () => context.push(AppRoutes.workerSyncStatus),
                ),
              ]),
            ),
          ),

          // ── TODAY'S SCHEDULE ─────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: "Today's Schedule",
              subtitle: 'Visits and tasks due today',
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: todayTasks.isEmpty
                  ? const EmptyState(
                      icon: Icons.event_available_rounded,
                      title: 'No tasks scheduled for today',
                      subtitle: 'Check upcoming tasks below',
                    )
                  : Column(
                      children: todayTasks.map((task) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TaskCard(task: task),
                        );
                      }).toList(),
                    ),
            ),
          ),

          // ── MY TASKS ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'My Tasks',
              subtitle: overdueTasks.isNotEmpty
                  ? '${overdueTasks.length} overdue'
                  : '${pendingTasks.length} total tasks',
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: pendingTasks.isEmpty
                ? SliverToBoxAdapter(
                    child: const EmptyState(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'No pending tasks',
                      subtitle: 'All tasks completed',
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TaskCard(task: pendingTasks[index]),
                        );
                      },
                      childCount: pendingTasks.length,
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 1),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon at top - fixed size
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              // Count and label at bottom - takes minimum needed space
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final PendingTask task;

  const _TaskCard({required this.task});

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'high':
        return AppColors.triageRed;
      case 'medium':
        return AppColors.syncPending;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTaskIcon() {
    switch (task.taskType) {
      case 'follow_up':
        return Icons.event_repeat_rounded;
      case 'home_visit':
        return Icons.home_rounded;
      case 'screening':
        return Icons.medical_services_rounded;
      case 'vaccination':
        return Icons.vaccines_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  String _getTaskTypeLabel() {
    switch (task.taskType) {
      case 'follow_up':
        return 'Follow-up';
      case 'home_visit':
        return 'Home Visit';
      case 'screening':
        return 'Screening';
      case 'vaccination':
        return 'Vaccination';
      default:
        return 'Task';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;
    final daysUntilDue = task.dueDate.difference(DateTime.now()).inDays;
    
    String dueDateText;
    if (isOverdue) {
      dueDateText = 'Overdue';
    } else if (daysUntilDue == 0) {
      dueDateText = 'Due Today';
    } else if (daysUntilDue == 1) {
      dueDateText = 'Due Tomorrow';
    } else {
      dueDateText = 'Due ${DateFormat('dd MMM').format(task.dueDate)}';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? AppColors.triageRed.withOpacity(0.3)
              : AppColors.border,
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to task details or patient profile
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getPriorityColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTaskIcon(),
                        color: _getPriorityColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getTaskTypeLabel(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getPriorityColor(),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            task.patientName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? AppColors.triageRed.withOpacity(0.12)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dueDateText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOverdue
                                ? AppColors.triageRed
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  task.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Mark as complete
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text(
                          'Complete',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // View patient details
                        },
                        icon: const Icon(Icons.person_rounded, size: 18),
                        label: const Text(
                          'View Patient',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
