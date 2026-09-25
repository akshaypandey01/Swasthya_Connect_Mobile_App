import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';
import '../../shared/widgets/sc_text_field.dart';

class SchemeEligibilityScreen extends StatefulWidget {
  const SchemeEligibilityScreen({super.key});
  @override
  State<SchemeEligibilityScreen> createState() =>
      _SchemeEligibilityScreenState();
}

class _SchemeEligibilityScreenState extends State<SchemeEligibilityScreen> {
  final _incomeCtrl = TextEditingController();
  String _category = 'general';
  String _state = 'Uttar Pradesh';
  bool _hasRationCard = false;
  bool _isChecked = false;
  List<_Scheme> _eligible = [];

  final _states = ['Uttar Pradesh', 'Bihar', 'Rajasthan', 'Madhya Pradesh',
      'Jharkhand', 'Odisha', 'Other'];

  void _checkEligibility() {
    final income = int.tryParse(_incomeCtrl.text) ?? 0;
    final schemes = <_Scheme>[];

    // PMJAY / Ayushman Bharat rules
    if (income <= 100000 ||
        _category == 'sc' || _category == 'st' || _hasRationCard) {
      schemes.add(const _Scheme(
        'Ayushman Bharat — PMJAY',
        'Free hospitalisation up to ₹5 lakh per year',
        'pmjay.gov.in',
        true,
      ));
    }

    if (income <= 50000 || _category == 'sc' || _category == 'st') {
      schemes.add(const _Scheme(
        'Pradhan Mantri Suraksha Bima',
        'Accident insurance — ₹2 lakh at ₹12/year premium',
        'jansuraksha.gov.in',
        true,
      ));
    }

    if (_category == 'general' && income > 100000) {
      schemes.add(const _Scheme(
        'Rashtriya Swasthya Bima Yojana',
        'May not qualify — income too high',
        '',
        false,
      ));
    }

    schemes.add(const _Scheme(
      'Janani Suraksha Yojana',
      'Cash benefit for institutional delivery (for pregnant women)',
      'nhm.gov.in',
      true,
    ));

    setState(() {
      _eligible = schemes;
      _isChecked = true;
    });
  }

  @override
  void dispose() {
    _incomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Scheme Eligibility'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Fill in basic details to check eligibility for government health schemes like PMJAY / Ayushman Bharat.',
                style: TextStyle(fontSize: 13, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            ScTextField(
              label: 'Annual Household Income (₹)',
              hint: 'e.g. 80000',
              controller: _incomeCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),
            const Text('Social Category',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _CategoryChip('General', 'general', _category, (v) => setState(() => _category = v)),
                _CategoryChip('OBC', 'obc', _category, (v) => setState(() => _category = v)),
                _CategoryChip('SC', 'sc', _category, (v) => setState(() => _category = v)),
                _CategoryChip('ST', 'st', _category, (v) => setState(() => _category = v)),
              ],
            ),
            const SizedBox(height: 20),
            // Ration card
            Row(
              children: [
                Switch(
                  value: _hasRationCard,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _hasRationCard = v),
                ),
                const SizedBox(width: 8),
                const Text('Has BPL/Ration Card',
                    style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 20),
            // State dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('State',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _state,
                  items: _states
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _state = v ?? _state),
                  decoration: const InputDecoration(),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ScButton(
              label: 'Check Eligibility',
              icon: Icons.search_rounded,
              onPressed: _checkEligibility,
            ),
            if (_isChecked) ...[
              const SizedBox(height: 28),
              const Text('Eligibility Results',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._eligible.map((s) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: s.eligible
                      ? AppColors.secondaryContainer
                      : AppColors.emergencyLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: s.eligible
                        ? AppColors.secondary
                        : AppColors.triageRed,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      s.eligible
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: s.eligible
                          ? AppColors.secondary
                          : AppColors.triageRed,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: s.eligible
                                      ? AppColors.secondary
                                      : AppColors.triageRed)),
                          Text(s.benefit,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _Scheme {
  final String name, benefit, url;
  final bool eligible;
  const _Scheme(this.name, this.benefit, this.url, this.eligible);
}

Widget _CategoryChip(String label, String value, String selected,
    void Function(String) onSelected) {
  final isSel = selected == value;
  return GestureDetector(
    onTap: () => onSelected(value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSel ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isSel ? AppColors.primary : AppColors.border),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSel ? Colors.white : AppColors.textPrimary)),
    ),
  );
}
