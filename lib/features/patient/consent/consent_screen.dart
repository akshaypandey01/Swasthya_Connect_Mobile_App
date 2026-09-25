import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});
  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final Map<String, bool> _consents = {
    'PHC Rampur — can view my records': true,
    'CHC Bijnor — can view my records': true,
    'District Hospital — can view my records': false,
    'Assigned ASHA Worker — can view my records': true,
    'Telemedicine Doctor — can view my records': true,
    'Research purposes (anonymised)': false,
    'National Health Program — can access records': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Data Consent'),
      body: Column(
        children: [
          Container(
            color: AppColors.primaryContainer,
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                Icon(Icons.lock_person_rounded, color: AppColors.primary, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Control who can access your health records. You can change these at any time.',
                    style: TextStyle(fontSize: 13, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _consents.keys.map((provider) {
                final enabled = _consents[provider]!;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_hospital_rounded,
                          color: enabled
                              ? AppColors.secondary
                              : AppColors.textHint,
                          size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(provider,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                      Switch(
                        value: enabled,
                        activeColor: AppColors.secondary,
                        onChanged: (v) =>
                            setState(() => _consents[provider] = v),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ScButton(
              label: 'Save Consent Preferences',
              icon: Icons.save_rounded,
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Consent preferences saved')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
