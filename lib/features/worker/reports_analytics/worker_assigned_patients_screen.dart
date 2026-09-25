import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_card.dart';
import '../../../data/repositories/dev_worker_report_repository.dart';
import '../../../data/models/worker_report_model.dart';

class WorkerAssignedPatientsScreen extends ConsumerWidget {
  const WorkerAssignedPatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportRepo = ref.read(devWorkerReportRepositoryProvider);
    final patients = reportRepo.getAssignedPatients();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScAppBar(
        title: 'Assigned Patients',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PatientCard(patient: patient),
          );
        },
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final AssignedPatient patient;

  const _PatientCard({required this.patient});

  Color _getRiskColor() {
    switch (patient.riskLevel) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _getRiskIcon() {
    switch (patient.riskLevel) {
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.priority_high;
      default:
        return Icons.check_circle;
    }
  }

  String _getRiskLabel() {
    switch (patient.riskLevel) {
      case 'high':
        return 'High Risk';
      case 'medium':
        return 'Medium Risk';
      default:
        return 'Low Risk';
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysSinceVisit = DateTime.now().difference(patient.lastVisit).inDays;

    return ScCard(
      onTap: () {
        // Navigate to patient details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open ${patient.name} details')),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and risk
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.secondary.withOpacity(0.2),
                child: Text(
                  patient.name[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${patient.age} years • ${patient.gender}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRiskColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getRiskColor()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getRiskIcon(), size: 16, color: _getRiskColor()),
                    const SizedBox(width: 4),
                    Text(
                      _getRiskLabel(),
                      style: TextStyle(
                        color: _getRiskColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Details
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.location_on,
                  label: 'Village',
                  value: patient.village,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today,
                  label: 'Last Visit',
                  value: '$daysSinceVisit days ago',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Conditions
          if (patient.conditions.isNotEmpty) ...[
            Text(
              'Conditions:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: patient.conditions.map((condition) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    condition,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryDark,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Next visit due
          if (patient.nextVisitDue != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.event, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Next Visit: ${_formatDate(patient.nextVisitDue!)}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
