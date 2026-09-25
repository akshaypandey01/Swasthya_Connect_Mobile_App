import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_card.dart';
import '../../shared/widgets/sc_button.dart';
import '../../../data/models/worker_notification_model.dart';

class WorkerNotificationDetailsScreen extends ConsumerWidget {
  final WorkerNotification notification;

  const WorkerNotificationDetailsScreen({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScAppBar(
        title: 'Notification Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            ScCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getPriorityColor().withOpacity(0.2),
                        radius: 28,
                        child: Icon(
                          _getTypeIcon(),
                          color: _getPriorityColor(),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getPriorityLabel(),
                                style: TextStyle(
                                  color: _getPriorityColor(),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getTypeLabel(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateTime(notification.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Body Content
            ScCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Additional Data
            if (notification.metadata != null &&
                notification.metadata!.isNotEmpty) ...[
              const SizedBox(height: 16),
              ScCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...notification.metadata!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                '${entry.key}:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            _ActionButtons(notification: notification),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (notification.priority) {
      case NotificationPriority.high:
        return Colors.red;
      case NotificationPriority.medium:
        return Colors.orange;
      case NotificationPriority.low:
        return Colors.blue;
      case NotificationPriority.critical:
        return Colors.red[900]!;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.patientAlert:
        return Icons.warning;
      case NotificationType.abnormalVitals:
        return Icons.favorite;
      case NotificationType.missedFollowUp:
        return Icons.event_busy;
      case NotificationType.referralUpdate:
        return Icons.send;
      case NotificationType.teleconsultAssignment:
        return Icons.video_call;
      case NotificationType.doctorFeedback:
        return Icons.feedback;
      case NotificationType.appointmentConfirmation:
        return Icons.event;
      case NotificationType.emergencyAlert:
        return Icons.emergency;
      case NotificationType.systemNotification:
        return Icons.system_update;
    }
  }

  String _getPriorityLabel() {
    switch (notification.priority) {
      case NotificationPriority.high:
        return 'HIGH PRIORITY';
      case NotificationPriority.medium:
        return 'MEDIUM PRIORITY';
      case NotificationPriority.low:
        return 'LOW PRIORITY';
      case NotificationPriority.critical:
        return 'CRITICAL';
    }
  }

  String _getTypeLabel() {
    switch (notification.type) {
      case NotificationType.patientAlert:
        return 'Patient Alert';
      case NotificationType.abnormalVitals:
        return 'Abnormal Vitals';
      case NotificationType.missedFollowUp:
        return 'Missed Follow-up';
      case NotificationType.referralUpdate:
        return 'Referral Update';
      case NotificationType.teleconsultAssignment:
        return 'Teleconsult Assignment';
      case NotificationType.doctorFeedback:
        return 'Doctor Feedback';
      case NotificationType.appointmentConfirmation:
        return 'Appointment Confirmation';
      case NotificationType.emergencyAlert:
        return 'Emergency Alert';
      case NotificationType.systemNotification:
        return 'System Notification';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} at $hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }
}

class _ActionButtons extends StatelessWidget {
  final WorkerNotification notification;

  const _ActionButtons({required this.notification});

  @override
  Widget build(BuildContext context) {
    // Different actions based on notification type
    switch (notification.type) {
      case NotificationType.patientAlert:
      case NotificationType.abnormalVitals:
      case NotificationType.emergencyAlert:
        return Column(
          children: [
            ScButton(
              label: 'View Patient',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to patient details')),
                );
              },
              color: AppColors.secondary,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ScOutlineButton(
                    label: 'Call Patient',
                    icon: Icons.phone,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Initiating call...')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ScOutlineButton(
                    label: 'Schedule Visit',
                    icon: Icons.home,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Schedule home visit')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );

      case NotificationType.referralUpdate:
        return ScButton(
          label: 'View Referral',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigate to referral details')),
            );
          },
          color: AppColors.secondary,
        );

      case NotificationType.missedFollowUp:
        return Column(
          children: [
            ScButton(
              label: 'Schedule Follow-up',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open schedule dialog')),
                );
              },
              color: AppColors.secondary,
            ),
            const SizedBox(height: 8),
            ScOutlineButton(
              label: 'Contact Patient',
              icon: Icons.phone,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Initiating call...')),
                );
              },
            ),
          ],
        );

      case NotificationType.teleconsultAssignment:
        return ScButton(
          label: 'Join Teleconsult',
          icon: Icons.video_call,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Joining teleconsultation...')),
            );
          },
          color: AppColors.secondary,
        );

      case NotificationType.appointmentConfirmation:
        return Column(
          children: [
            ScButton(
              label: 'View Appointment',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to appointment details')),
                );
              },
              color: AppColors.secondary,
            ),
            const SizedBox(height: 8),
            ScOutlineButton(
              label: 'Reschedule',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open reschedule dialog')),
                );
              },
            ),
          ],
        );

      case NotificationType.doctorFeedback:
        return ScButton(
          label: 'View Feedback',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigate to feedback details')),
            );
          },
          color: AppColors.secondary,
        );

      case NotificationType.systemNotification:
        return ScOutlineButton(
          label: 'Dismiss',
          onPressed: () {
            Navigator.pop(context);
          },
        );
    }
  }
}
