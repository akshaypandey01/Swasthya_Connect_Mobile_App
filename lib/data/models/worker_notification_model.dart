/// Worker notification and alert data model

enum NotificationType {
  patientAlert,
  abnormalVitals,
  missedFollowUp,
  referralUpdate,
  teleconsultAssignment,
  doctorFeedback,
  appointmentConfirmation,
  emergencyAlert,
  systemNotification
}

enum NotificationPriority {
  low,
  medium,
  high,
  critical
}

class WorkerNotification {
  final String id;
  final String workerId;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String message;
  final String? patientId;
  final String? patientName;
  final String? relatedEntityId; // referral ID, appointment ID, etc.
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final bool isRead;
  final DateTime? readAt;
  final bool requiresAction;
  final String? actionLabel;
  final String? actionRoute;

  WorkerNotification({
    required this.id,
    required this.workerId,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    this.patientId,
    this.patientName,
    this.relatedEntityId,
    this.metadata,
    required this.timestamp,
    this.isRead = false,
    this.readAt,
    this.requiresAction = false,
    this.actionLabel,
    this.actionRoute,
  });

  bool get isHighPriority =>
      priority == NotificationPriority.high ||
      priority == NotificationPriority.critical;

  bool get isCritical => priority == NotificationPriority.critical;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
