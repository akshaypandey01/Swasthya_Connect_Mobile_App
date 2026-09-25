import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette — calm healthcare blues
  static const Color primary = Color(0xFF1A73A7);
  static const Color primaryDark = Color(0xFF115D8C);
  static const Color primaryLight = Color(0xFF4FA3D1);
  static const Color primaryContainer = Color(0xFFD6EAF8);

  // Secondary palette — health greens
  static const Color secondary = Color(0xFF2E9E6B);
  static const Color secondaryDark = Color(0xFF1E7A50);
  static const Color secondaryLight = Color(0xFF58C490);
  static const Color secondaryContainer = Color(0xFFD5F5E3);

  // Backgrounds
  static const Color background = Color(0xFFF4F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEAF2F8);

  // Text
  static const Color textPrimary = Color(0xFF1A2530);
  static const Color textSecondary = Color(0xFF4A6070);
  static const Color textHint = Color(0xFF8FA8BB);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Triage / Status colours
  static const Color triageGreen = Color(0xFF27AE60);
  static const Color triageYellow = Color(0xFFF39C12);
  static const Color triageRed = Color(0xFFE74C3C);
  static const Color triageCritical = Color(0xFF8E1616);

  // Emergency — ONLY used for SOS / Critical states
  static const Color emergency = Color(0xFFD32F2F);
  static const Color emergencyLight = Color(0xFFFFEBEE);

  // Sync status
  static const Color syncPending = Color(0xFFF39C12);
  static const Color syncSynced = Color(0xFF27AE60);
  static const Color syncError = Color(0xFFE74C3C);

  // Divider / borders
  static const Color divider = Color(0xFFD5E8F3);
  static const Color border = Color(0xFFB8D4E8);

  // Disabled
  static const Color disabled = Color(0xFFBDCDD6);
  static const Color disabledText = Color(0xFF8FA8BB);

  // Card shadow
  static const Color shadow = Color(0x1A1A73A7);
}
