import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDisplay(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  static String formatShort(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  static String formatTimestamp(DateTime dt) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(dt);

  static String formatIso(DateTime date) => date.toIso8601String();

  static DateTime? parseIso(String? s) =>
      s == null ? null : DateTime.tryParse(s);

  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDisplay(dt);
  }

  static int ageFromDob(String dob) {
    final d = DateTime.tryParse(dob);
    if (d == null) return 0;
    final now = DateTime.now();
    int age = now.year - d.year;
    if (now.month < d.month ||
        (now.month == d.month && now.day < d.day)) age--;
    return age;
  }
}
