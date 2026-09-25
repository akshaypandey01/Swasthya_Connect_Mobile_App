import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});
  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  String? _selectedFacility;
  String? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedSlot;
  int _step = 0;

  final _facilities = ['PHC Rampur', 'CHC Bijnor', 'District Hospital'];
  final _doctors = ['Dr. Anita Singh', 'Dr. Ramesh Gupta', 'Dr. Priya Sharma'];
  final _slots = ['9:00 AM', '10:00 AM', '11:00 AM',
      '2:00 PM', '3:00 PM', '4:00 PM'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Book Appointment'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper indicator
            Row(
              children: List.generate(4, (i) {
                final done = _step > i;
                final active = _step == i;
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: done
                              ? AppColors.secondary
                              : active
                                  ? AppColors.primary
                                  : AppColors.border,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : Text('${i + 1}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: active
                                          ? Colors.white
                                          : AppColors.textHint)),
                        ),
                      ),
                      if (i < 3)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: done ? AppColors.secondary : AppColors.border,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // Step 0: Facility
            if (_step == 0) ...[
              const Text('Select Facility',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              ..._facilities.map((f) => _OptionTile(
                    label: f,
                    selected: _selectedFacility == f,
                    onTap: () => setState(() => _selectedFacility = f),
                  )),
            ],

            // Step 1: Doctor
            if (_step == 1) ...[
              const Text('Select Doctor',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              ..._doctors.map((d) => _OptionTile(
                    label: d,
                    selected: _selectedDoctor == d,
                    onTap: () => setState(() => _selectedDoctor = d),
                  )),
            ],

            // Step 2: Date
            if (_step == 2) ...[
              const Text('Select Date',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (d != null) setState(() => _selectedDate = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Tap to select date'
                            : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate == null
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Step 3: Time slot
            if (_step == 3) ...[
              const Text('Select Time Slot',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _slots.map((s) {
                  final sel = _selectedSlot == s;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSlot = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: sel ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(s,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textPrimary)),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 36),
            Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ScButton(
                    label: _step < 3 ? 'Next →' : 'Confirm Booking',
                    onPressed: () {
                      if (_step < 3) {
                        setState(() => _step++);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Appointment booked!')),
                        );
                        context.push(AppRoutes.liveQueue,
                            extra: {'appointmentId': 'APT001'});
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1.5),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
