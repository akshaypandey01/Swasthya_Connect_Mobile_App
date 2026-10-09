import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/hive_constants.dart';
import '../../shared/widgets/patient_bottom_nav.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/status_badge.dart';
import 'package:intl/intl.dart';

class HealthLockerScreen extends StatelessWidget {
  const HealthLockerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(HiveConstants.settingsBox);
    final patientId = box.get(HiveConstants.userIdKey, defaultValue: '') as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Records'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // Filter functionality
            },
          ),
        ],
      ),
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
            return EmptyState(
              icon: Icons.folder_off_rounded,
              title: 'No health records yet',
              subtitle: 'Your visit records and reports will appear here',
            );
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return _RecordCard(data: data);
            },
          );
        },
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 2),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RecordCard({required this.data});

  String get _severity => data['triage_severity'] ?? 'unknown';

  Widget _buildStatusBadge() {
    switch (_severity) {
      case 'critical':
        return StatusBadge(
          label: 'Critical',
          color: AppColors.triageCritical,
          backgroundColor: AppColors.triageCritical.withOpacity(0.12),
          small: true,
        );
      case 'red':
        return StatusBadge(
          label: 'Urgent',
          color: AppColors.triageRed,
          backgroundColor: AppColors.triageRed.withOpacity(0.12),
          small: true,
        );
      case 'yellow':
        return StatusBadge(
          label: 'Moderate',
          color: AppColors.triageYellow,
          backgroundColor: AppColors.triageYellow.withOpacity(0.12),
          small: true,
        );
      default:
        return StatusBadge.neutral('Normal', small: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = data['timestamp'];
    DateTime? date;
    
    if (timestamp is String) {
      try {
        date = DateTime.parse(timestamp);
      } catch (e) {
        date = null;
      }
    } else if (timestamp is Timestamp) {
      date = timestamp.toDate();
    }

    final vitals = data['vitals'] as Map<String, dynamic>? ?? {};
    final symptoms = data['symptoms'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to record details
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Date and Status
                Row(
                  children: [
                    const Icon(
                      Icons.medical_information_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        date != null
                            ? DateFormat('dd MMMM yyyy, hh:mm a').format(date)
                            : 'Date unavailable',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _buildStatusBadge(),
                  ],
                ),

                // Vitals
                if (vitals.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (vitals['bp_systolic'] != null)
                        _VitalChip(
                          icon: Icons.favorite_rounded,
                          label: 'BP',
                          value: '${vitals['bp_systolic']}/${vitals['bp_diastolic']}',
                        ),
                      if (vitals['spo2'] != null)
                        _VitalChip(
                          icon: Icons.air_rounded,
                          label: 'SpO₂',
                          value: '${vitals['spo2']}%',
                        ),
                      if (vitals['temperature'] != null)
                        _VitalChip(
                          icon: Icons.thermostat_rounded,
                          label: 'Temp',
                          value: '${vitals['temperature']}°F',
                        ),
                      if (vitals['heart_rate'] != null)
                        _VitalChip(
                          icon: Icons.monitor_heart_rounded,
                          label: 'HR',
                          value: '${vitals['heart_rate']} bpm',
                        ),
                    ],
                  ),
                ],

                // Symptoms
                if (symptoms.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.sick_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Symptoms: ${symptoms.take(3).join(", ")}${symptoms.length > 3 ? "..." : ""}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // View Details
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Spacer(),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VitalChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _VitalChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
