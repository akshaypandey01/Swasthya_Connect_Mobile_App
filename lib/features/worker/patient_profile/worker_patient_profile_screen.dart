import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/models/encounter_model.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_card.dart';

class WorkerPatientProfileScreen extends ConsumerWidget {
  final String patientId;
  const WorkerPatientProfileScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patBox = Hive.box<PatientModel>(HiveConstants.patientBox);
    final encBox = Hive.box<EncounterModel>(HiveConstants.encounterBox);

    final patient = patBox.get(patientId);
    final encounters = encBox.values
        .where((e) => e.patientId == patientId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (patient == null) {
      return Scaffold(
        appBar: const ScAppBar(title: 'Patient Profile'),
        body: const Center(child: Text('Patient not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScAppBar(
        title: patient.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Patient summary card ───────────────────────────────────────
            ScCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      patient.name.isNotEmpty
                          ? patient.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(
                            '${patient.gender.toUpperCase()} • ${patient.dob}',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                        Text(patient.phone,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(patient.displayId,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  if (patient.syncStatus == 'pending')
                    const Icon(Icons.cloud_upload_rounded,
                        color: AppColors.syncPending, size: 22),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Actions ────────────────────────────────────────────────────
            const Text('Actions',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ActionChip(
                  icon: Icons.monitor_heart_rounded,
                  label: 'Log Visit',
                  color: AppColors.primary,
                  onTap: () => context.push(
                    AppRoutes.vitalsEntry,
                    extra: {'patientId': patientId},
                  ),
                ),
                _ActionChip(
                  icon: Icons.upload_file_rounded,
                  label: 'Upload Records',
                  color: const Color(0xFF7B2FBE),
                  onTap: () => context.push(
                    AppRoutes.uploadRecords,
                    extra: {'patientId': patientId},
                  ),
                ),
                _ActionChip(
                  icon: Icons.event_repeat_rounded,
                  label: 'Follow-up',
                  color: AppColors.secondary,
                  onTap: () => context.push(
                    AppRoutes.followUpTrackers,
                    extra: {'patientId': patientId},
                  ),
                ),
                _ActionChip(
                  icon: Icons.video_call_rounded,
                  label: 'Teleconsult',
                  color: const Color(0xFF00897B),
                  onTap: () => context.push(
                    AppRoutes.workerTeleconsult,
                    extra: {'priority': 'routine'},
                  ),
                ),
                _ActionChip(
                  icon: Icons.emergency_rounded,
                  label: 'Emergency',
                  color: AppColors.emergency,
                  onTap: () => context.push(
                    AppRoutes.emergencyEscalation,
                    extra: {'patientId': patientId},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Visit history ──────────────────────────────────────────────
            const Text('Visit History',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            if (encounters.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No visits recorded yet',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                ),
              )
            else
              ...encounters.map((e) => _EncounterTile(encounter: e)),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _EncounterTile extends StatelessWidget {
  final EncounterModel encounter;
  const _EncounterTile({required this.encounter});

  Color get _triageColor {
    switch (encounter.triageSeverity) {
      case 'critical': return AppColors.triageCritical;
      case 'red': return AppColors.triageRed;
      case 'yellow': return AppColors.triageYellow;
      default: return AppColors.triageGreen;
    }
  }

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
          Container(
            width: 6,
            height: 50,
            decoration: BoxDecoration(
              color: _triageColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  encounter.timestamp.substring(0, 10),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (encounter.triageSeverity != null)
                  Text(
                    'Triage: ${encounter.triageSeverity!.toUpperCase()}',
                    style: TextStyle(fontSize: 12, color: _triageColor),
                  ),
                Text(
                  encounter.syncStatus == 'pending'
                      ? '⚠ Pending sync'
                      : '✓ Synced',
                  style: TextStyle(
                      fontSize: 11,
                      color: encounter.syncStatus == 'pending'
                          ? AppColors.syncPending
                          : AppColors.syncSynced),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textHint),
        ],
      ),
    );
  }
}
