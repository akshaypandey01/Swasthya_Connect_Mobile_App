/// Development repository for worker notifications with mock data

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/worker_notification_model.dart';

final devWorkerNotificationRepositoryProvider = Provider((ref) => DevWorkerNotificationRepository());

class DevWorkerNotificationRepository {
  /// Simulates network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Get all notifications synchronously (for development/UI)
  List<WorkerNotification> getAllNotifications() {
    // Return all mock notifications, sorted by timestamp (newest first)
    final notifications = List<WorkerNotification>.from(_mockNotifications);
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  /// Get all notifications for a worker
  Future<List<WorkerNotification>> getNotifications({
    required String workerId,
    bool? unreadOnly,
  }) async {
    await _simulateDelay();

    var notifications = _mockNotifications.where((n) => n.workerId == workerId).toList();

    if (unreadOnly == true) {
      notifications = notifications.where((n) => !n.isRead).toList();
    }

    // Sort by timestamp, newest first
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  /// Get single notification
  Future<WorkerNotification?> getNotification(String id) async {
    await _simulateDelay();
    try {
      return _mockNotifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get unread count
  Future<int> getUnreadCount(String workerId) async {
    await _simulateDelay();
    return _mockNotifications
        .where((n) => n.workerId == workerId && !n.isRead)
        .length;
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    await _simulateDelay();

    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _mockNotifications[index];
      _mockNotifications[index] = WorkerNotification(
        id: notification.id,
        workerId: notification.workerId,
        type: notification.type,
        priority: notification.priority,
        title: notification.title,
        message: notification.message,
        patientId: notification.patientId,
        patientName: notification.patientName,
        relatedEntityId: notification.relatedEntityId,
        metadata: notification.metadata,
        timestamp: notification.timestamp,
        isRead: true,
        readAt: DateTime.now(),
        requiresAction: notification.requiresAction,
        actionLabel: notification.actionLabel,
        actionRoute: notification.actionRoute,
      );
      return true;
    }
    return false;
  }

  /// Mark all as read
  Future<bool> markAllAsRead(String workerId) async {
    await _simulateDelay();

    for (int i = 0; i < _mockNotifications.length; i++) {
      if (_mockNotifications[i].workerId == workerId && !_mockNotifications[i].isRead) {
        final notification = _mockNotifications[i];
        _mockNotifications[i] = WorkerNotification(
          id: notification.id,
          workerId: notification.workerId,
          type: notification.type,
          priority: notification.priority,
          title: notification.title,
          message: notification.message,
          patientId: notification.patientId,
          patientName: notification.patientName,
          relatedEntityId: notification.relatedEntityId,
          metadata: notification.metadata,
          timestamp: notification.timestamp,
          isRead: true,
          readAt: DateTime.now(),
          requiresAction: notification.requiresAction,
          actionLabel: notification.actionLabel,
          actionRoute: notification.actionRoute,
        );
      }
    }
    return true;
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    await _simulateDelay();
    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _mockNotifications.removeAt(index);
      return true;
    }
    return false;
  }

  /// Mock notifications data
  static final List<WorkerNotification> _mockNotifications = [
    WorkerNotification(
      id: 'notif_001',
      workerId: 'worker_123',
      type: NotificationType.emergencyAlert,
      priority: NotificationPriority.critical,
      title: 'Emergency Alert',
      message: 'Patient Ramesh Yadav reported severe chest pain. Immediate attention required.',
      patientId: 'pat_006',
      patientName: 'Ramesh Yadav',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      isRead: false,
      requiresAction: true,
      actionLabel: 'View Details',
      metadata: {'severity': 'critical', 'symptoms': ['chest_pain', 'breathlessness']},
    ),
    WorkerNotification(
      id: 'notif_002',
      workerId: 'worker_123',
      type: NotificationType.abnormalVitals,
      priority: NotificationPriority.high,
      title: 'Abnormal Vitals Detected',
      message: 'Priya Sharma - Fasting blood sugar: 195 mg/dL (High)',
      patientId: 'pat_002',
      patientName: 'Priya Sharma',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      requiresAction: true,
      actionLabel: 'Review',
      metadata: {'vitalType': 'blood_sugar', 'value': '195', 'unit': 'mg/dL'},
    ),
    WorkerNotification(
      id: 'notif_003',
      workerId: 'worker_123',
      type: NotificationType.referralUpdate,
      priority: NotificationPriority.medium,
      title: 'Referral Status Updated',
      message: 'Referral for Rajesh Kumar (Cardiology) has been accepted by District Hospital',
      patientId: 'pat_001',
      patientName: 'Rajesh Kumar',
      relatedEntityId: 'ref_001',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: false,
      requiresAction: true,
      actionLabel: 'View Referral',
      actionRoute: '/worker/referral/details',
    ),
    WorkerNotification(
      id: 'notif_004',
      workerId: 'worker_123',
      type: NotificationType.missedFollowUp,
      priority: NotificationPriority.medium,
      title: 'Missed Follow-up',
      message: 'Rajesh Kumar missed scheduled follow-up appointment for BP monitoring',
      patientId: 'pat_001',
      patientName: 'Rajesh Kumar',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      requiresAction: true,
      actionLabel: 'Reschedule',
    ),
    WorkerNotification(
      id: 'notif_005',
      workerId: 'worker_123',
      type: NotificationType.teleconsultAssignment,
      priority: NotificationPriority.medium,
      title: 'New Teleconsult Assignment',
      message: 'You have been assigned to facilitate teleconsult for Lakshmi Devi',
      patientId: 'pat_004',
      patientName: 'Lakshmi Devi',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
      readAt: DateTime.now().subtract(const Duration(hours: 7)),
      requiresAction: true,
      actionLabel: 'Start Session',
    ),
    WorkerNotification(
      id: 'notif_006',
      workerId: 'worker_123',
      type: NotificationType.doctorFeedback,
      priority: NotificationPriority.low,
      title: 'Doctor Feedback Received',
      message: 'Dr. Ramesh Patel provided feedback on Mohan Singh referral case',
      patientId: 'pat_003',
      patientName: 'Mohan Singh',
      relatedEntityId: 'ref_003',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
      isRead: true,
      readAt: DateTime.now().subtract(const Duration(days: 1, hours: 9)),
      requiresAction: false,
      metadata: {'feedback': 'Patient responded well to physiotherapy'},
    ),
    WorkerNotification(
      id: 'notif_007',
      workerId: 'worker_123',
      type: NotificationType.appointmentConfirmation,
      priority: NotificationPriority.low,
      title: 'Appointment Confirmed',
      message: 'Appointment confirmed for Priya Sharma at CHC Chandpur on 25th Sept',
      patientId: 'pat_002',
      patientName: 'Priya Sharma',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      readAt: DateTime.now().subtract(const Duration(days: 2)),
      requiresAction: false,
    ),
    WorkerNotification(
      id: 'notif_008',
      workerId: 'worker_123',
      type: NotificationType.systemNotification,
      priority: NotificationPriority.low,
      title: 'System Update',
      message: 'New features available: Referral management and performance analytics',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
      requiresAction: false,
    ),
  ];
}
