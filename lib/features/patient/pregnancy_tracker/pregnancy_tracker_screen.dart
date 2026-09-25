import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';

class PregnancyTrackerScreen extends StatefulWidget {
  const PregnancyTrackerScreen({super.key});
  @override
  State<PregnancyTrackerScreen> createState() => _PregnancyTrackerScreenState();
}

class _PregnancyTrackerScreenState extends State<PregnancyTrackerScreen> {
  DateTime? _lmpDate;
  int get _gestationalWeeks {
    if (_lmpDate == null) return 0;
    return DateTime.now().difference(_lmpDate!).inDays ~/ 7;
  }
  int get _trimester => _gestationalWeeks < 13 ? 1 : _gestationalWeeks < 27 ? 2 : 3;

  final _checkups = [
    _Checkup('1st ANC Visit', 'Within 12 weeks', false),
    _Checkup('Blood & Urine Test', 'Week 10–12', false),
    _Checkup('Ultrasound Scan', 'Week 11–14', true),
    _Checkup('2nd ANC Visit', 'Week 14–28', false),
    _Checkup('Glucose Test', 'Week 24–28', false),
    _Checkup('3rd ANC Visit', 'Week 28–36', false),
    _Checkup('4th ANC Visit', 'Week 36–40', false),
    _Checkup('Delivery Plan', 'Week 36+', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(
          title: 'Pregnancy Tracker',
          backgroundColor: Color(0xFFFF6F00)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LMP picker
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 30)),
                  firstDate: DateTime.now().subtract(const Duration(days: 280)),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _lmpDate = d);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFF6F00)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Color(0xFFFF6F00), size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Last Menstrual Period (LMP)',
                            style: TextStyle(fontSize: 12, color: Color(0xFFE65100))),
                        Text(
                          _lmpDate == null
                              ? 'Tap to enter date'
                              : '${_lmpDate!.day}/${_lmpDate!.month}/${_lmpDate!.year}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF6F00)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_lmpDate != null) ...[
              // Week + trimester
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      label: 'Week',
                      value: '$_gestationalWeeks',
                      sub: 'of 40',
                      color: const Color(0xFFFF6F00),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      label: 'Trimester',
                      value: '$_trimester',
                      sub: _trimester == 1 ? '1st' : _trimester == 2 ? '2nd' : '3rd',
                      color: const Color(0xFFFF6F00),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      label: 'EDD',
                      value: '${_lmpDate!.add(const Duration(days: 280)).day}/${_lmpDate!.add(const Duration(days: 280)).month}',
                      sub: 'Due date',
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              LinearProgressIndicator(
                value: _gestationalWeeks / 40,
                minHeight: 10,
                backgroundColor: const Color(0xFFFFF8E1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF6F00)),
              ),
              const SizedBox(height: 24),
            ],
            const Text('Antenatal Checkups',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._checkups.asMap().entries.map((entry) => _CheckupTile(
                  checkup: entry.value,
                  index: entry.key,
                  onToggle: () => setState(
                      () => _checkups[entry.key].done = !_checkups[entry.key].done),
                )),
            const SizedBox(height: 24),
            ScButton(
              label: 'Save Progress',
              color: const Color(0xFFFF6F00),
              onPressed: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Saved'))),
            ),
          ],
        ),
      ),
    );
  }
}

class _Checkup {
  final String name, timing;
  bool done;
  _Checkup(this.name, this.timing, this.done);
}

class _CheckupTile extends StatelessWidget {
  final _Checkup checkup;
  final int index;
  final VoidCallback onToggle;
  const _CheckupTile({required this.checkup, required this.index, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: checkup.done ? const Color(0xFFFFF3E0) : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: checkup.done
                ? const Color(0xFFFF6F00)
                : AppColors.border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checkup.done
                    ? const Color(0xFFFF6F00)
                    : AppColors.surface,
                border: Border.all(
                    color: checkup.done
                        ? const Color(0xFFFF6F00)
                        : AppColors.border,
                    width: 2),
              ),
              child: checkup.done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(checkup.name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: checkup.done
                            ? const Color(0xFFE65100)
                            : AppColors.textPrimary)),
                Text(checkup.timing,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _InfoCard({required this.label, required this.value, required this.sub, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
