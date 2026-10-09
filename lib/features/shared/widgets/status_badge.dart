import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Status badge for displaying appointment/record status
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final bool small;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
    this.small = false,
  });

  /// Creates a status badge with predefined styling
  factory StatusBadge.success(String label, {bool small = false}) {
    return StatusBadge(
      label: label,
      color: AppColors.triageGreen,
      backgroundColor: AppColors.triageGreen.withOpacity(0.12),
      small: small,
    );
  }

  factory StatusBadge.pending(String label, {bool small = false}) {
    return StatusBadge(
      label: label,
      color: AppColors.triageYellow,
      backgroundColor: AppColors.triageYellow.withOpacity(0.12),
      small: small,
    );
  }

  factory StatusBadge.cancelled(String label, {bool small = false}) {
    return StatusBadge(
      label: label,
      color: AppColors.triageRed,
      backgroundColor: AppColors.triageRed.withOpacity(0.12),
      small: small,
    );
  }

  factory StatusBadge.neutral(String label, {bool small = false}) {
    return StatusBadge(
      label: label,
      color: AppColors.textSecondary,
      backgroundColor: AppColors.surfaceVariant,
      small: small,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(small ? 6 : 8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w700,
          color: color ?? AppColors.textSecondary,
          height: 1.2,
        ),
      ),
    );
  }
}
