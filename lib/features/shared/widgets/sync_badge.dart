import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/connectivity_service.dart';

/// Compact sync status badge — shown in the worker app bar / dashboard.
class SyncBadge extends ConsumerWidget {
  const SyncBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(isSyncingProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final syncService = ref.read(syncServiceProvider);
    final pending = syncService.pendingCount;

    Color bgColor;
    String label;
    IconData icon;

    if (isSyncing) {
      bgColor = AppColors.primary;
      label = 'Syncing…';
      icon = Icons.sync;
    } else if (!isOnline) {
      bgColor = AppColors.syncPending;
      label = pending > 0 ? '$pending pending' : 'Offline';
      icon = Icons.cloud_off_outlined;
    } else if (pending > 0) {
      bgColor = AppColors.syncPending;
      label = '$pending pending';
      icon = Icons.upload_outlined;
    } else {
      bgColor = AppColors.syncSynced;
      label = 'Synced';
      icon = Icons.cloud_done_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isSyncing
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(bgColor),
                  ),
                )
              : Icon(icon, size: 14, color: bgColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: bgColor,
            ),
          ),
        ],
      ),
    );
  }
}
