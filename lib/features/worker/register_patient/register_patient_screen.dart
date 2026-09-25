import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../data/models/patient_model.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';
import '../../shared/widgets/sc_text_field.dart';

class RegisterPatientScreen extends ConsumerStatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  ConsumerState<RegisterPatientScreen> createState() =>
      _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends ConsumerState<RegisterPatientScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _abhaCtrl = TextEditingController();

  String _gender = 'female';
  DateTime? _dob;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _abhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  String _generateTempId() {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    return 'TMP${ts.substring(ts.length - 8)}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date of birth')));
      return;
    }

    setState(() => _isSaving = true);

    final isAbha = _tabCtrl.index == 0;
    final isOnline = ref.read(isOnlineProvider);
    final uuid = const Uuid().v4();
    final tempId = isAbha ? null : _generateTempId();

    final dobStr =
        '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}';

    final patient = PatientModel(
      patientId: uuid,
      name: _nameCtrl.text.trim(),
      dob: dobStr,
      gender: _gender,
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      abhaId: isAbha ? _abhaCtrl.text.trim() : null,
      tempId: tempId,
      isAbhaRegistered: isAbha,
      syncStatus: isOnline ? 'synced' : 'pending',
    );

    // Always save locally first
    final box = Hive.box<PatientModel>(HiveConstants.patientBox);
    await box.put(uuid, patient);

    // If online, push to Firestore
    if (isOnline) {
      try {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(uuid)
            .set(patient.toFirestore());
      } catch (_) {
        patient.syncStatus = 'pending';
        await patient.save();
      }
    }

    setState(() => _isSaving = false);

    if (mounted) {
      final msg = isOnline
          ? 'Patient registered successfully!'
          : 'Patient saved offline. Temp ID: ${tempId ?? 'N/A'}';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
      context.push(AppRoutes.workerPatientProfile,
          extra: {'patientId': uuid});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScAppBar(title: 'Register Patient'),
      body: Column(
        children: [
          if (!isOnline)
            Container(
              color: AppColors.syncPending.withOpacity(0.12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 18, color: AppColors.syncPending),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline — patient will be saved with a Temp ID and synced later.',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.syncPending),
                    ),
                  ),
                ],
              ),
            ),
          TabBar(
            controller: _tabCtrl,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(icon: Icon(Icons.fingerprint_rounded), text: 'Via ABHA ID'),
              Tab(
                  icon: Icon(Icons.offline_bolt_rounded),
                  text: 'Offline / Temp ID'),
            ],
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildForm(showAbha: true),
                  _buildForm(showAbha: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm({required bool showAbha}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!showAbha)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_rounded,
                      color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A unique Temp ID will be generated and can be linked to ABHA ID later.',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

          // ABHA field (tab 0 only)
          if (showAbha) ...[
            ScTextField(
              label: 'ABHA ID',
              hint: '14-digit ABHA Number',
              controller: _abhaCtrl,
              keyboardType: TextInputType.number,
              maxLength: 14,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (!showAbha) return null;
                if (v == null || v.isEmpty) return 'ABHA ID is required';
                if (v.length < 14) return 'Must be 14 digits';
                return null;
              },
            ),
            const SizedBox(height: 20),
          ],

          // Full name
          ScTextField(
            label: 'Full Name / पूरा नाम',
            hint: 'Patient full name',
            controller: _nameCtrl,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 20),

          // DOB
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Date of Birth / जन्म तिथि',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDob,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _dob == null
                            ? 'Select date of birth'
                            : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _dob == null
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gender
          const Text('Gender / लिंग',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Row(
            children: [
              _genderOption('Female', 'female', Icons.female_rounded),
              const SizedBox(width: 8),
              _genderOption('Male', 'male', Icons.male_rounded),
              const SizedBox(width: 8),
              _genderOption('Other', 'other', Icons.transgender_rounded),
            ],
          ),
          const SizedBox(height: 20),

          // Phone
          ScTextField(
            label: 'Mobile Number / मोबाइल',
            hint: '10-digit mobile number',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (v == null || v.length < 10) {
                return 'Enter valid 10-digit number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Address
          ScTextField(
            label: 'Address / पता',
            hint: 'Village, District',
            controller: _addressCtrl,
            maxLines: 2,
          ),
          const SizedBox(height: 36),

          ScButton(
            label: 'Register Patient / पंजीकृत करें',
            icon: Icons.person_add_rounded,
            isLoading: _isSaving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Widget _genderOption(String label, String value, IconData icon) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color:
                selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 22,
                  color: selected
                      ? Colors.white
                      : AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : AppColors.textPrimary),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
