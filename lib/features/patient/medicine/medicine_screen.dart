import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meds = [
      _Med('Metformin 500mg', 'Twice daily after meals', 30, 15, 'Diabetes'),
      _Med('Amlodipine 5mg', 'Once daily morning', 30, 28, 'Hypertension'),
      _Med('Folic Acid 5mg', 'Once daily', 60, 5, 'Pregnancy supplement'),
      _Med('Iron + Folic Acid', 'Once daily at night', 90, 45, 'Anaemia'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'My Medicines'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: meds.length,
        itemBuilder: (_, i) => _MedCard(med: meds[i]),
      ),
    );
  }
}

class _Med {
  final String name, dosage, condition;
  final int totalDays, daysLeft;
  const _Med(this.name, this.dosage, this.totalDays, this.daysLeft, this.condition);
  bool get needsRefill => daysLeft <= 7;
}

class _MedCard extends StatelessWidget {
  final _Med med;
  const _MedCard({required this.med});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: med.needsRefill ? AppColors.triageYellow : AppColors.border,
          width: med.needsRefill ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medication_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(med.condition,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (med.needsRefill)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.triageYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('REFILL SOON',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.triageYellow)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(med.dosage,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: med.daysLeft / med.totalDays,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    med.daysLeft <= 7
                        ? AppColors.triageYellow
                        : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${med.daysLeft} days left',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: med.daysLeft <= 7
                          ? AppColors.triageYellow
                          : AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
