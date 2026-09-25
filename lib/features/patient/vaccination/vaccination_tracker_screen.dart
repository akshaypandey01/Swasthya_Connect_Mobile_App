import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';

class VaccinationTrackerScreen extends StatelessWidget {
  const VaccinationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vaccines = [
      _VaccRecord('COVID-19 (Dose 1)', 'Covishield', '15 Jan 2022', 'Done'),
      _VaccRecord('COVID-19 (Dose 2)', 'Covishield', '20 Mar 2022', 'Done'),
      _VaccRecord('COVID-19 (Booster)', 'Corbevax', '01 Aug 2022', 'Done'),
      _VaccRecord('Influenza', 'Vaxigrip', '10 Oct 2023', 'Done'),
      _VaccRecord('Typhoid', 'Typbar-TCV', '—', 'Pending'),
      _VaccRecord('Hepatitis A', '—', '—', 'Pending'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Vaccination Record'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vaccines.length,
        itemBuilder: (_, i) {
          final v = vaccines[i];
          final isDone = v.status == 'Done';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDone ? AppColors.secondaryContainer : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDone ? AppColors.secondary : AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.secondary : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDone ? Icons.vaccines_rounded : Icons.schedule_rounded,
                    color: Colors.white, size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.name,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDone
                                  ? AppColors.secondary
                                  : AppColors.textPrimary)),
                      if (v.brand != '—')
                        Text(v.brand,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      Text(v.date == '—' ? 'Not yet given' : 'Given: ${v.date}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.secondary.withOpacity(0.15)
                        : AppColors.triageYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(v.status,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDone
                              ? AppColors.secondary
                              : AppColors.triageYellow)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VaccRecord {
  final String name, brand, date, status;
  const _VaccRecord(this.name, this.brand, this.date, this.status);
}
