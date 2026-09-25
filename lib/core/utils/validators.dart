class Validators {
  Validators._();

  static String? abhaId(String? value) {
    if (value == null || value.isEmpty) return 'ABHA ID is required';
    final cleaned = value.replaceAll('-', '').replaceAll(' ', '');
    if (cleaned.length != 14) return 'ABHA ID must be 14 digits';
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) return 'ABHA ID must be numeric';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length != 10) return 'Enter valid 10-digit number';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Enter valid Indian mobile number';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.length < 6) return 'Enter 6-digit OTP';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? vitalsRange(String? value, String label, double min, double max) {
    if (value == null || value.isEmpty) return '$label is required';
    final n = double.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n < min || n > max) return '$label must be between $min–$max';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name is too short';
    if (!RegExp(r"^[a-zA-Z\u0900-\u097F\s.'-]+$").hasMatch(value.trim())) {
      return 'Name contains invalid characters';
    }
    return null;
  }
}
