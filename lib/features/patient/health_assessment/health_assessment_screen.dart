import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';

class HealthAssessmentScreen extends StatefulWidget {
  const HealthAssessmentScreen({super.key});
  @override
  State<HealthAssessmentScreen> createState() => _HealthAssessmentScreenState();
}

class _HealthAssessmentScreenState extends State<HealthAssessmentScreen> {
  final Map<String, bool> _symptoms = {
    'Fever / बुखार': false,
    'Headache / सिरदर्द': false,
    'Cough / खांसी': false,
    'Shortness of breath / सांस की तकलीफ': false,
    'Chest pain / सीने में दर्द': false,
    'Nausea / मतली': false,
    'Vomiting / उल्टी': false,
    'Diarrhoea / दस्त': false,
    'Fatigue / थकान': false,
    'Body ache / शरीर दर्द': false,
    'Rash / दाने': false,
    'Dizziness / चक्कर': false,
  };

  double _painLevel = 0;
  String _duration = 'Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Health Assessment'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How are you feeling today?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const Text('आज आप कैसा महसूस कर रहे हैं?',
                style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            const Text('Select Symptoms',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _symptoms.keys.map((s) {
                final selected = _symptoms[s]!;
                return FilterChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (v) => setState(() => _symptoms[s] = v),
                  selectedColor: AppColors.primaryContainer,
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            const Text('Pain Level (0 = None, 10 = Severe)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            Slider(
              value: _painLevel,
              min: 0,
              max: 10,
              divisions: 10,
              label: _painLevel.toStringAsFixed(0),
              activeColor: _painLevel > 7
                  ? AppColors.triageRed
                  : _painLevel > 4
                      ? AppColors.triageYellow
                      : AppColors.triageGreen,
              onChanged: (v) => setState(() => _painLevel = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('0 — None', style: TextStyle(fontSize: 12)),
                Text('10 — Severe', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 28),

            const Text('Duration of Symptoms',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['Today', '2–3 days', '1 week', '2+ weeks']
                  .map((d) => ChoiceChip(
                        label: Text(d),
                        selected: _duration == d,
                        onSelected: (_) => setState(() => _duration = d),
                        selectedColor: AppColors.primaryContainer,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 40),
            ScButton(
              label: 'Submit Assessment',
              icon: Icons.send_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Assessment submitted')));
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
