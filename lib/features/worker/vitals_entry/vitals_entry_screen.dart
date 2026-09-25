import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/encounter_model.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';

class VitalsEntryScreen extends ConsumerStatefulWidget {
  final String patientId;
  const VitalsEntryScreen({super.key, required this.patientId});
  @override
  ConsumerState<VitalsEntryScreen> createState() => _VitalsEntryScreenState();
}

class _VitalsEntryScreenState extends ConsumerState<VitalsEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bpSystolicCtrl = TextEditingController();
  final _bpDiastolicCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _bpSystolicCtrl.dispose();
    _bpDiastolicCtrl.dispose();
    _spo2Ctrl.dispose();
    _tempCtrl.dispose();
    _weightCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final encounterId = const Uuid().v4();
    final box = Hive.box(HiveConstants.settingsBox);
    final workerId = box.get(HiveConstants.userIdKey, defaultValue: '') as String;

    final vitals = {
      'bp_systolic': int.tryParse(_bpSystolicCtrl.text) ?? 0,
      'bp_diastolic': int.tryParse(_bpDiastolicCtrl.text) ?? 0,
      'spo2': double.tryParse(_spo2Ctrl.text) ?? 0.0,
      'temperature': double.tryParse(_tempCtrl.text) ?? 0.0,
      'weight': double.tryParse(_weightCtrl.text) ?? 0.0,
      'pulse': int.tryParse(_pulseCtrl.text) ?? 0,
    };

    final encounter = EncounterModel(
      encounterId: encounterId,
      patientId: widget.patientId,
      workerId: workerId,
      timestamp: DateTime.now().toIso8601String(),
      vitals: vitals,
      syncStatus: 'pending',
    );

    final encBox = Hive.box<EncounterModel>(HiveConstants.encounterBox);
    await encBox.put(encounterId, encounter);

    setState(() => _isSaving = false);

    if (mounted) {
      context.push(AppRoutes.symptomInput, extra: {'encounterId': encounterId});
    }
  }

  Widget _vitalField({
    required String label,
    required String labelHi,
    required String unit,
    required TextEditingController ctrl,
    required String hint,
    required String? Function(String?) validator,
    IconData? icon,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color ?? AppColors.primary),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(width: 4),
            Text('($labelHi)',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))
          ],
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit,
            suffixStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Record Vitals'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.patientId.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Patient: ${widget.patientId}',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.primary)),
                      ],
                    ),
                  ),
                // BP
                const Text('Blood Pressure',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _vitalField(
                        label: 'Systolic',
                        labelHi: 'सिस्टोलिक',
                        unit: 'mmHg',
                        ctrl: _bpSystolicCtrl,
                        hint: 'e.g. 120',
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = int.tryParse(v);
                          if (n == null || n < 60 || n > 250) {
                            return '60–250';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('/',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    ),
                    Expanded(
                      child: _vitalField(
                        label: 'Diastolic',
                        labelHi: 'डायस्टोलिक',
                        unit: 'mmHg',
                        ctrl: _bpDiastolicCtrl,
                        hint: 'e.g. 80',
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = int.tryParse(v);
                          if (n == null || n < 40 || n > 150) {
                            return '40–150';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _vitalField(
                  label: 'SpO₂',
                  labelHi: 'ऑक्सीजन',
                  unit: '%',
                  ctrl: _spo2Ctrl,
                  hint: 'e.g. 98',
                  icon: Icons.air_rounded,
                  color: const Color(0xFF0288D1),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = double.tryParse(v);
                    if (n == null || n < 50 || n > 100) return '50–100';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _vitalField(
                  label: 'Temperature',
                  labelHi: 'तापमान',
                  unit: '°F',
                  ctrl: _tempCtrl,
                  hint: 'e.g. 98.6',
                  icon: Icons.thermostat_rounded,
                  color: AppColors.triageRed,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = double.tryParse(v);
                    if (n == null || n < 90 || n > 110) return '90–110°F';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _vitalField(
                  label: 'Weight',
                  labelHi: 'वजन',
                  unit: 'kg',
                  ctrl: _weightCtrl,
                  hint: 'e.g. 55',
                  icon: Icons.monitor_weight_rounded,
                  color: AppColors.secondary,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = double.tryParse(v);
                    if (n == null || n < 1 || n > 300) return '1–300 kg';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _vitalField(
                  label: 'Pulse Rate',
                  labelHi: 'नाड़ी',
                  unit: 'bpm',
                  ctrl: _pulseCtrl,
                  hint: 'e.g. 72',
                  icon: Icons.favorite_rounded,
                  color: AppColors.triageRed,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = int.tryParse(v);
                    if (n == null || n < 30 || n > 250) return '30–250';
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                ScButton(
                  label: 'Save & Continue to Symptoms →',
                  isLoading: _isSaving,
                  onPressed: _saveAndContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
