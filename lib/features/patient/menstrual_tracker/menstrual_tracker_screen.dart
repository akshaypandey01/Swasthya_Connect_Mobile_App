import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';

class MenstrualTrackerScreen extends StatefulWidget {
  const MenstrualTrackerScreen({super.key});
  @override
  State<MenstrualTrackerScreen> createState() => _MenstrualTrackerScreenState();
}

class _MenstrualTrackerScreenState extends State<MenstrualTrackerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Set<DateTime> _periodDays = {};
  int _cycleLength = 28;
  int _periodLength = 5;

  DateTime get _nextPeriod {
    if (_periodDays.isEmpty) return DateTime.now().add(Duration(days: _cycleLength));
    final last = _periodDays.reduce((a, b) => a.isAfter(b) ? a : b);
    return last.add(Duration(days: _cycleLength));
  }

  bool _isPeriodDay(DateTime day) =>
      _periodDays.any((d) => isSameDay(d, day));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(
          title: 'Menstrual Tracker',
          backgroundColor: Color(0xFFE91E63)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0xFFFCE4EC),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFFE91E63),
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                  if (_isPeriodDay(selected)) {
                    _periodDays.removeWhere((d) => isSameDay(d, selected));
                  } else {
                    _periodDays.add(selected);
                  }
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  if (_isPeriodDay(day)) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE91E63),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: Color(0xFFE91E63), size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Next Period Expected',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFAD1457))),
                            Text(
                              '${_nextPeriod.day}/${_nextPeriod.month}/${_nextPeriod.year}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE91E63)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Cycle Settings',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cycle Length: ${_cycleLength} days'),
                            Slider(
                              value: _cycleLength.toDouble(),
                              min: 21, max: 35,
                              divisions: 14,
                              activeColor: const Color(0xFFE91E63),
                              onChanged: (v) =>
                                  setState(() => _cycleLength = v.toInt()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Tap dates on calendar to mark period days',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 24),
                  ScButton(
                    label: 'Save Cycle Log',
                    color: const Color(0xFFE91E63),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cycle log saved')));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
