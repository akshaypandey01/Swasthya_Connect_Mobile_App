import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_card.dart';
import '../../shared/widgets/sc_button.dart';
import '../../../data/repositories/dev_worker_report_repository.dart';
import '../../../data/models/worker_report_model.dart';

class WorkerCriticalAlertsScreen extends ConsumerWidget {
  const WorkerCriticalAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportRepo = ref.read(devWorkerReportRepositoryProvider);
    final alerts = reportRepo.getCriticalAlerts();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScAppBar(
        title: 'Critical Alerts',
      ),
      body: alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.green[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No Critical Alerts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All patients are doing well',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AlertCard(alert: alert),
                );
              },
            ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final CriticalAlert alert;

  const _AlertCard({required this.alert});

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

  IconData _getAlertTypeIcon() {
    switch (alert.alertType) {
      case 'Vital Signs Abnormal':
        return Icons.favorite;
      case 'Medication Missed':
        return Icons.medication;
      case 'Emergency Visit Required':
        return Icons.local_hospital;
      case 'High Risk Patient':
        return Icons.warning_amber;
      default:
        return Icons.notifications_active;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(alert.timestamp);

    return ScCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with severity indicator
          Row(
            children: [
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: _getSeverityColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: _getSeverityColor().withOpacity(0.2),
                child: Icon(_getSeverityIcon(), color: _getSeverityColor()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getSeverityColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            alert.severity.toUpperCase(),
                            style: TextStyle(
                              color: _getSeverityColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeAgo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alert.patientName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      alert.patientId,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Alert Type
          Row(
            children: [
              Icon(_getAlertTypeIcon(), size: 20, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                alert.alertType,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryDark,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              alert.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          // Recommended Action
          if (alert.recommendedAction.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommended Action',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.recommendedAction,
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Actions
          Row(
            children: [
              Expanded(
                child: ScButton(
                  label: 'Take Action',
                  onPressed: () {
                    _showActionDialog(context);
                  },
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ScOutlineButton(
                  label: 'View Patient',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Open ${alert.patientName} details')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Take Action'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Patient'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Initiating call...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Schedule Home Visit'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Home visit scheduled')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Create Referral'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to create referral')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Mark as Resolved'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alert marked as resolved')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
