import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_card.dart';
import '../../../data/repositories/dev_worker_report_repository.dart';
import '../../../data/models/worker_report_model.dart';
import 'worker_assigned_patients_screen.dart';
import 'worker_pending_tasks_screen.dart';
import 'worker_critical_alerts_screen.dart';

class WorkerReportsScreen extends ConsumerWidget {
  const WorkerReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportRepo = ref.read(devWorkerReportRepositoryProvider);
    final performance = reportRepo.getWorkerPerformance();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScAppBar(
        title: 'Reports & Analytics',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance Summary Card
            _PerformanceSummaryCard(performance: performance),
            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.people,
                    title: 'Assigned Patients',
                    subtitle: '${reportRepo.getAssignedPatients().length} Patients',
                    color: AppColors.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerAssignedPatientsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.task_alt,
                    title: 'Pending Tasks',
                    subtitle: '${reportRepo.getPendingTasks().length} Tasks',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerPendingTasksScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Critical Alerts
            _CriticalAlertsSection(
              alerts: reportRepo.getCriticalAlerts(),
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkerCriticalAlertsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceSummaryCard extends StatelessWidget {
  final WorkerPerformance performance;

  const _PerformanceSummaryCard({required this.performance});

  @override
  Widget build(BuildContext context) {
    return ScCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.secondary, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'प्रदर्शन सारांश',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Total Visits',
                  value: performance.totalVisits.toString(),
                  icon: Icons.home_work,
                  color: AppColors.secondary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Completed',
                  value: performance.completedVisits.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Pending',
                  value: performance.pendingVisits.toString(),
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Referrals',
                  value: performance.referralsMade.toString(),
                  icon: Icons.send,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Success Rate
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Success Rate',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Row(
                  children: [
                    Text(
                      '${(performance.successRate * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      performance.successRate >= 0.8
                          ? Icons.trending_up
                          : Icons.trending_flat,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScCard(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}

class _CriticalAlertsSection extends StatelessWidget {
  final List<CriticalAlert> alerts;
  final VoidCallback onViewAll;

  const _CriticalAlertsSection({
    required this.alerts,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Critical Alerts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'महत्वपूर्ण अलर्ट',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: onViewAll,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (alerts.isEmpty)
          ScCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No Critical Alerts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...alerts.take(3).map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CriticalAlertItem(alert: alert),
              )),
      ],
    );
  }
}

class _CriticalAlertItem extends StatelessWidget {
  final CriticalAlert alert;

  const _CriticalAlertItem({required this.alert});

  Color _getSeverityColor() {
    switch (alert.severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getSeverityIcon() {
    switch (alert.severity) {
      case 'critical':
        return Icons.warning;
      case 'high':
        return Icons.priority_high;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: _getSeverityColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Icon(_getSeverityIcon(), color: _getSeverityColor()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.patientName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.alertType,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
