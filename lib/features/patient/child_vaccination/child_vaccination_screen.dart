import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';

class ChildVaccinationScreen extends StatefulWidget {
  const ChildVaccinationScreen({super.key});
  @override
  State<ChildVaccinationScreen> createState() => _ChildVaccinationScreenState();
}

class _ChildVaccinationScreenState extends State<ChildVaccinationScreen> {
  final List<_Vaccine> _vaccines = [
    _Vaccine('BCG', 'At birth', true, false),
    _Vaccine('Hepatitis B (1st dose)', 'At birth', true, false),
    _Vaccine('OPV (Birth dose)', 'At birth', true, false),
    _Vaccine('DPT (1st dose)', '6 weeks', true, false),
    _Vaccine('OPV (2nd dose)', '6 weeks', true, false),
    _Vaccine('Hib (1st dose)', '6 weeks', false, false),
    _Vaccine('DPT (2nd dose)', '10 weeks', false, false),
    _Vaccine('OPV (3rd dose)', '10 weeks', false, false),
    _Vaccine('DPT (3rd dose)', '14 weeks', false, false),
    _Vaccine('Measles (1st)', '9 months', false, false),
    _Vaccine('Vitamin A (1st)', '9 months', false, false),
    _Vaccine('MMR', '12 months', false, true),
    _Vaccine('DPT Booster', '16–24 months', false, true),
    _Vaccine('Measles (2nd)', '16–24 months', false, true),
  ];

  @override
  Widget build(BuildContext context) {
    final done = _vaccines.where((v) => v.given).length;
    final total = _vaccines.length;
    final overdue = _vaccines.where((v) => v.overdue && !v.given).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(
          title: 'Child Vaccination',
          backgroundColor: Color(0xFF43A047)),
      body: Column(
        children: [
          // Summary header
          Container(
            color: const Color(0xFFE8F5E9),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryChip('$done/$total\nCompleted', AppColors.secondary),
                _SummaryChip('${total - done}\nPending', AppColors.triageYellow),
                _SummaryChip('$overdue\nOverdue', AppColors.triageRed),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: LinearProgressIndicator(
              value: done / total,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8F5E9),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF43A047)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _vaccines.length,
              itemBuilder: (_, i) {
                final v = _vaccines[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: v.given
                        ? const Color(0xFFE8F5E9)
                        : v.overdue
                            ? AppColors.emergencyLight
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: v.given
                          ? AppColors.secondary
                          : v.overdue
                              ? AppColors.triageRed
                              : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _vaccines[i].given = !v.given),
                        child: Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: v.given
                                ? AppColors.secondary
                                : Colors.transparent,
                            border: Border.all(
                              color: v.given
                                  ? AppColors.secondary
                                  : v.overdue
                                      ? AppColors.triageRed
                                      : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: v.given
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
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
                                    color: v.given
                                        ? AppColors.secondary
                                        : AppColors.textPrimary)),
                            Text(v.timing,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (v.overdue && !v.given)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.emergencyLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('OVERDUE',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.triageRed)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Vaccine {
  final String name, timing;
  bool given;
  final bool overdue;
  _Vaccine(this.name, this.timing, this.given, this.overdue);
}

class _SummaryChip extends StatelessWidget {
  final String text;
  final Color color;
  const _SummaryChip(this.text, this.color);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: color));
  }
}
