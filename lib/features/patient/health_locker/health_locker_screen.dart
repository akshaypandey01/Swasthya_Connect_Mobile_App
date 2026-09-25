import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/hive_constants.dart';
import '../../shared/widgets/sc_app_bar.dart';

class HealthLockerScreen extends StatelessWidget {
  const HealthLockerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(HiveConstants.settingsBox);
    final patientId = box.get(HiveConstants.userIdKey, defaultValue: '') as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Health Locker'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('encounters')
            .where('patient_id', isEqualTo: patientId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _empty();
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return _RecordTile(data: data);
            },
          );
        },
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off_rounded, size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            const Text('No health records yet',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            const Text('Your visit records will appear here',
                style: TextStyle(fontSize: 13, color: AppColors.textHint)),
          ],
        ),
      );
}

class _RecordTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RecordTile({required this.data});

  String get _severity => data['triage_severity'] ?? 'unknown';

  Color get _color {
    switch (_severity) {
      case 'critical': return AppColors.triageCritical;
      case 'red': return AppColors.triageRed;
      case 'yellow': return AppColors.triageYellow;
      default: return AppColors.triageGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = (data['timestamp'] ?? '').toString();
    final date = ts.length >= 10 ? ts.substring(0, 10) : ts;
    final vitals = data['vitals'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: _color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(date,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_severity.toUpperCase(),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _color)),
              ),
            ],
          ),
          if (vitals.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                if (vitals['bp_systolic'] != null)
                  _VitalChip('BP',
                      '${vitals['bp_systolic']}/${vitals['bp_diastolic']}'),
                if (vitals['spo2'] != null)
                  _VitalChip('SpO₂', '${vitals['spo2']}%'),
                if (vitals['temperature'] != null)
                  _VitalChip('Temp', '${vitals['temperature']}°F'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VitalChip extends StatelessWidget {
  final String label, value;
  const _VitalChip(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $value',
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
    );
  }
}
