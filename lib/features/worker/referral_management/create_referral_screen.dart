import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/worker_referral_model.dart';
import '../../../data/repositories/dev_worker_referral_repository.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';

class CreateReferralScreen extends StatefulWidget {
  const CreateReferralScreen({super.key});

  @override
  State<CreateReferralScreen> createState() => _CreateReferralScreenState();
}

class _CreateReferralScreenState extends State<CreateReferralScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = DevWorkerReferralRepository();
  final _patientNameController = TextEditingController();
  final _reasonController = TextEditingController();
  final _suspectedConditionController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  String _selectedFacility = 'District Hospital, Bijnor';
  String _selectedSpecialization = 'Cardiology';
  ReferralUrgencyLevel _urgency = ReferralUrgencyLevel.normal;
  final Map<String, String> _vitals = {};
  bool _isSaving = false;

  final List<String> _facilities = [
    'District Hospital, Bijnor',
    'Community Health Center, Chandpur',
    'Sub-District Hospital, Najibabad',
  ];

  final List<String> _specializations = [
    'Cardiology',
    'Obstetrics',
    'Orthopedics',
    'Neurology',
    'General Surgery',
    'Pediatrics',
  ];

  @override
  void dispose() {
    _patientNameController.dispose();
    _reasonController.dispose();
    _suspectedConditionController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _saveReferral() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final box = Hive.box(HiveConstants.settingsBox);
      final workerId = box.get(HiveConstants.userIdKey, defaultValue: 'worker_123') as String;
      final workerName = box.get('worker_name', defaultValue: 'Worker') as String;

      await _repository.createReferral(
        patientId: 'pat_new_${DateTime.now().millisecondsSinceEpoch}',
        patientName: _patientNameController.text.trim(),
        workerId: workerId,
        workerName: workerName,
        fromFacility: 'SwasthyaConnect PHC, Rampur',
        toFacility: _selectedFacility,
        toFacilityAddress: 'Address for $_selectedFacility',
        specialization: _selectedSpecialization,
        reason: _reasonController.text.trim(),
        suspectedCondition: _suspectedConditionController.text.trim().isNotEmpty
            ? _suspectedConditionController.text.trim()
            : null,
        urgency: _urgency,
        relevantVitals: _vitals,
        specialInstructions: _specialInstructionsController.text.trim().isNotEmpty
            ? _specialInstructionsController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Referral created successfully')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(
        title: 'Create Referral',
        backgroundColor: AppColors.secondary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _patientNameController,
              decoration: const InputDecoration(
                labelText: 'Patient Name *',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFacility,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Destination Facility *',
                prefixIcon: Icon(Icons.local_hospital_rounded),
              ),
              items: _facilities.map((f) => DropdownMenuItem(
                value: f, 
                child: Text(
                  f,
                  overflow: TextOverflow.ellipsis,
                ),
              )).toList(),
              onChanged: (v) => setState(() => _selectedFacility = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecialization,
              decoration: const InputDecoration(
                labelText: 'Specialization *',
                prefixIcon: Icon(Icons.medical_services_rounded),
              ),
              items: _specializations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _selectedSpecialization = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for Referral *',
                prefixIcon: Icon(Icons.description_rounded),
                alignLabelWithHint: true,
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _suspectedConditionController,
              decoration: const InputDecoration(
                labelText: 'Suspected Condition (Optional)',
                prefixIcon: Icon(Icons.coronavirus_rounded),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Urgency Level *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: ReferralUrgencyLevel.values.map((level) {
                final isSelected = _urgency == level;
                final color = level == ReferralUrgencyLevel.emergency
                    ? AppColors.triageRed
                    : level == ReferralUrgencyLevel.urgent
                        ? AppColors.triageYellow
                        : AppColors.triageGreen;
                return ChoiceChip(
                  label: Text(level.name.toUpperCase()),
                  selected: isSelected,
                  onSelected: (v) => setState(() => _urgency = level),
                  selectedColor: color.withOpacity(0.2),
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialInstructionsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Special Instructions (Optional)',
                prefixIcon: Icon(Icons.note_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),
            ScButton(
              label: 'Create Referral',
              icon: Icons.send_rounded,
              onPressed: _saveReferral,
              isLoading: _isSaving,
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
