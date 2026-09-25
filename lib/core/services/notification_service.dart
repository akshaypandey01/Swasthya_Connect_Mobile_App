import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notification service - placeholder for future implementation
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  Future<void> initialize() async {
    // Placeholder - notifications temporarily disabled
  }

  Future<void> showNotification(String title, String body) async {
    // Placeholder - notifications temporarily disabled
  }

  Future<void> scheduleNotification(
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    // Placeholder - notifications temporarily disabled
  }
}
