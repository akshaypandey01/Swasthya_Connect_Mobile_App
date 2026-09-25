import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../data/models/encounter_model.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/models/tracker_entry_model.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';

class SyncStatusScreen extends ConsumerWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.read(syncServiceProvider);
    final isSyncing = ref.watch(isSyncingProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final lastSynced = ref.watch(lastSyncedProvider);

    final patientBox = Hive.box<PatientModel>(HiveConstants.patientBox);
    final encounterBox = Hive.box<EncounterModel>(HiveConstants.encounterBox);
    final trackerBox = Hive.box<TrackerEntryModel>(HiveConstants.trackerBox);

    final pendingPatients =
        patientBox.values.where((p) => p.syncStatus == 'pending').toList();
    final pendingEncounters =
        encounterBox.values.where((e) => e.syncStatus == 'pending').toList();
    final pendingTrackers =
        trackerBox.values.where((t) => t.syncStatus == 'pending').toList();

    final totalPending =
        pendingPatients.length + pendingEncounters.length + pendingTrackers.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Sync Status'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isOnline
                      ? [AppColors.secondary, AppColors.secondaryDark]
                      : [AppColors.syncPending, const Color(0xFFE65100)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'Connected' : 'Offline Mode',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          totalPending > 0
                              ? '$totalPending record(s) pending sync'
                              : 'All records synced',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                        if (lastSynced != null)
                          Text(
                            'Last synced: ${DateFormat('dd MMM yyyy, hh:mm a').format(lastSynced)}',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Sync now button ────────────────────────────────────────────
            ScButton(
              label: isSyncing ? 'Syncing…' : 'Sync Now',
              icon: Icons.sync_rounded,
              color: isOnline ? AppColors.primary : AppColors.disabled,
              isLoading: isSyncing,
              onPressed: isOnline && !isSyncing
                  ? () => syncService.syncAll()
                  : null,
            ),
            const SizedBox(height: 28),

            // ── Breakdown ─────────────────────────────────────────────────
            const Text('Pending Records',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _SyncCategory(
              icon: Icons.person_rounded,
              title: 'Patients',
              pending: pendingPatients.length,
              total: patientBox.length,
            ),
            _SyncCategory(
              icon: Icons.medical_information_rounded,
              title: 'Encounters / Visits',
              pending: pendingEncounters.length,
              total: encounterBox.length,
            ),
            _SyncCategory(
              icon: Icons.event_note_rounded,
              title: 'Tracker Entries',
              pending: pendingTrackers.length,
              total: trackerBox.length,
            ),
            const SizedBox(height: 28),

            // ── Pending list ───────────────────────────────────────────────
            if (pendingPatients.isNotEmpty) ...[
              const Text('Pending Patients',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...pendingPatients.map((p) => _PendingTile(
                    title: p.name,
                    subtitle: p.displayId,
                    icon: Icons.person_rounded,
                  )),
            ],
            if (pendingEncounters.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Pending Encounters',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...pendingEncounters.map((e) => _PendingTile(
                    title: 'Visit: ${e.timestamp.substring(0, 10)}',
                    subtitle: 'Patient: ${e.patientId}',
                    icon: Icons.medical_information_rounded,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _SyncCategory extends StatelessWidget {
  final IconData icon;
  final String title;
  final int pending;
  final int total;
  const _SyncCategory(
      {required this.icon,
      required this.title,
      required this.pending,
      required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pending pending',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: pending > 0
                      ? AppColors.syncPending
                      : AppColors.syncSynced,
                ),
              ),
              Text('$total total',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _PendingTile(
      {required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.syncPending.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.syncPending.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.syncPending),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.cloud_upload_rounded,
              size: 16, color: AppColors.syncPending),
        ],
      ),
    );
  }
}
