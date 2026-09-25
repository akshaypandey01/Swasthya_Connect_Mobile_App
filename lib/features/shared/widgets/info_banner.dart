import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum BannerType { info, warning, success, error, offline }

class InfoBanner extends StatelessWidget {
  final String message;
  final BannerType type;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const InfoBanner({
    super.key,
    required this.message,
    this.type = BannerType.info,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  Color get _bg {
    switch (type) {
      case BannerType.info: return AppColors.primaryContainer;
      case BannerType.warning: return const Color(0xFFFFF8E1);
      case BannerType.success: return AppColors.secondaryContainer;
      case BannerType.error: return AppColors.emergencyLight;
      case BannerType.offline: return const Color(0xFFFFF3E0);
    }
  }

  Color get _fg {
    switch (type) {
      case BannerType.info: return AppColors.primary;
      case BannerType.warning: return AppColors.triageYellow;
      case BannerType.success: return AppColors.secondary;
      case BannerType.error: return AppColors.triageRed;
      case BannerType.offline: return AppColors.syncPending;
    }
  }

  IconData get _icon {
    switch (type) {
      case BannerType.info: return Icons.info_rounded;
      case BannerType.warning: return Icons.warning_rounded;
      case BannerType.success: return Icons.check_circle_rounded;
      case BannerType.error: return Icons.error_rounded;
      case BannerType.offline: return Icons.wifi_off_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: _fg.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _fg, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: _fg),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: _fg),
              child: Text(actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, color: _fg, size: 18),
            ),
        ],
      ),
    );
  }
}
