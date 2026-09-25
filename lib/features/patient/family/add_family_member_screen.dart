import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/family_member_model.dart';
import '../../../data/repositories/dev_family_repository.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = DevFamilyRepository();
  final _nameController = TextEditingController();
  final _abhaIdController = TextEditingController();
  final _healthIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  Relationship _selectedRelationship = Relationship.child;
  Gender _selectedGender = Gender.male;
  AccessLevel _selectedAccessLevel = AccessLevel.full;
  DateTime? _dateOfBirth;
  String? _selectedBloodGroup;
  bool _isSaving = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void dispose() {
    _nameController.dispose();
    _abhaIdController.dispose();
    _healthIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920, 1, 1),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _dateOfBirth = date);
    }
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final box = Hive.box(HiveConstants.settingsBox);
      final userId = box.get(HiveConstants.userIdKey, defaultValue: 'patient_123') as String;

      await _repository.addFamilyMember(
        primaryUserId: userId,
        name: _nameController.text.trim(),
        relationship: _selectedRelationship,
        gender: _selectedGender,
        dateOfBirth: _dateOfBirth!,
        abhaId: _abhaIdController.text.trim().isNotEmpty
            ? _abhaIdController.text.trim()
            : null,
        healthId: _healthIdController.text.trim().isNotEmpty
            ? _healthIdController.text.trim()
            : null,
        bloodGroup: _selectedBloodGroup,
        accessLevel: _selectedAccessLevel,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family member added successfully')),
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
      appBar: const ScAppBar(title: 'Add Family Member'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                hintText: 'Enter full name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Relationship
            DropdownButtonFormField<Relationship>(
              value: _selectedRelationship,
              decoration: const InputDecoration(
                labelText: 'Relationship *',
                prefixIcon: Icon(Icons.people_rounded),
              ),
              items: Relationship.values
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(_relationshipDisplayName(r)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRelationship = v!),
            ),
            const SizedBox(height: 16),

            // Gender
            DropdownButtonFormField<Gender>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender *',
                prefixIcon: Icon(Icons.wc_rounded),
              ),
              items: Gender.values
                  .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(_genderDisplayName(g)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGender = v!),
            ),
            const SizedBox(height: 16),

            // Date of Birth
            InkWell(
              onTap: _selectDateOfBirth,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth *',
                  prefixIcon: Icon(Icons.cake_rounded),
                ),
                child: Text(
                  _dateOfBirth == null
                      ? 'Tap to select'
                      : DateFormat('dd MMMM yyyy').format(_dateOfBirth!),
                  style: TextStyle(
                    color: _dateOfBirth == null
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Blood Group
            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              decoration: const InputDecoration(
                labelText: 'Blood Group (Optional)',
                prefixIcon: Icon(Icons.bloodtype_rounded),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Not specified')),
                ..._bloodGroups
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg))),
              ],
              onChanged: (v) => setState(() => _selectedBloodGroup = v),
            ),
            const SizedBox(height: 16),

            // ABHA ID
            TextFormField(
              controller: _abhaIdController,
              decoration: const InputDecoration(
                labelText: 'ABHA ID (Optional)',
                hintText: 'XX-XXXX-XXXX-XXXX',
                prefixIcon: Icon(Icons.badge_rounded),
              ),
            ),
            const SizedBox(height: 16),

            // Health ID
            TextFormField(
              controller: _healthIdController,
              decoration: const InputDecoration(
                labelText: 'Health ID (Optional)',
                hintText: 'username@abdm',
                prefixIcon: Icon(Icons.local_hospital_rounded),
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                hintText: '+91 XXXXX XXXXX',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                hintText: 'email@example.com',
                prefixIcon: Icon(Icons.email_rounded),
              ),
            ),
            const SizedBox(height: 16),

            // Access Level
            DropdownButtonFormField<AccessLevel>(
              value: _selectedAccessLevel,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Access Level *',
                prefixIcon: Icon(Icons.security_rounded),
              ),
              items: const [
                DropdownMenuItem(
                  value: AccessLevel.full,
                  child: Text('Full Access (View & Book Appointments)', 
                    overflow: TextOverflow.ellipsis),
                ),
                DropdownMenuItem(
                  value: AccessLevel.viewOnly,
                  child: Text('View Only (Health Records Only)',
                    overflow: TextOverflow.ellipsis),
                ),
              ],
              onChanged: (v) => setState(() => _selectedAccessLevel = v!),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any additional notes...',
                prefixIcon: Icon(Icons.note_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),

            // Save button
            ScButton(
              label: 'Add Family Member',
              icon: Icons.check_rounded,
              onPressed: _saveMember,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }

  String _relationshipDisplayName(Relationship r) {
    switch (r) {
      case Relationship.spouse:
        return 'Spouse';
      case Relationship.child:
        return 'Child';
      case Relationship.parent:
        return 'Parent';
      case Relationship.sibling:
        return 'Sibling';
      case Relationship.grandparent:
        return 'Grandparent';
      case Relationship.grandchild:
        return 'Grandchild';
      case Relationship.other:
        return 'Other';
    }
  }

  String _genderDisplayName(Gender g) {
    switch (g) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}
