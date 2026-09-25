import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/models/family_member_model.dart';
import '../../../data/repositories/dev_family_repository.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';
import '../../shared/widgets/sc_card.dart';

class FamilyMemberDetailsScreen extends StatefulWidget {
  final String memberId;

  const FamilyMemberDetailsScreen({super.key, required this.memberId});

  @override
  State<FamilyMemberDetailsScreen> createState() =>
      _FamilyMemberDetailsScreenState();
}

class _FamilyMemberDetailsScreenState extends State<FamilyMemberDetailsScreen> {
  final _repository = DevFamilyRepository();
  FamilyMember? _member;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  Future<void> _loadMember() async {
    setState(() => _isLoading = true);
    try {
      final member = await _repository.getFamilyMember(widget.memberId);
      setState(() {
        _member = member;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color get _genderColor {
    if (_member == null) return AppColors.textHint;
    switch (_member!.gender) {
      case Gender.male:
        return const Color(0xFF2196F3);
      case Gender.female:
        return const Color(0xFFE91E63);
      case Gender.other:
        return AppColors.textSecondary;
    }
  }

  IconData get _relationshipIcon {
    if (_member == null) return Icons.person_rounded;
    switch (_member!.relationship) {
      case Relationship.spouse:
        return Icons.favorite_rounded;
      case Relationship.child:
        return Icons.child_care_rounded;
      case Relationship.parent:
        return Icons.elderly_rounded;
      case Relationship.sibling:
        return Icons.people_rounded;
      case Relationship.grandparent:
        return Icons.elderly_woman_rounded;
      case Relationship.grandchild:
        return Icons.child_friendly_rounded;
      case Relationship.other:
        return Icons.person_rounded;
    }
  }

  Future<void> _deleteMember() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Family Member'),
        content: Text(
          'Are you sure you want to remove ${_member!.name} from your family list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.triageRed),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _repository.deleteFamilyMember(widget.memberId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family member removed')),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  void _bookAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Book appointment for ${_member!.name}'),
        action: SnackBarAction(
          label: 'Go',
          onPressed: () => context.push(AppRoutes.appointmentBooking),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScAppBar(
        title: 'Member Details',
        actions: [
          if (_member != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _deleteMember,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _member == null
              ? _errorState()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_genderColor.withOpacity(0.2), _genderColor.withOpacity(0.05)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: _genderColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                              ),
                              child: _member!.photoUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _member!.photoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          _relationshipIcon,
                                          color: _genderColor,
                                          size: 50,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      _relationshipIcon,
                                      color: _genderColor,
                                      size: 50,
                                    ),
                            ),
                            const SizedBox(height: 14),

                            // Name
                            Text(
                              _member!.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Relationship
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: _genderColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _member!.relationshipDisplay,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _genderColor,
                                ),
                              ),
                            ),

                            // ABHA verified badge
                            if (_member!.isVerified) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.triageGreen.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.verified_rounded,
                                        size: 16, color: AppColors.triageGreen),
                                    SizedBox(width: 5),
                                    Text(
                                      'ABHA Verified',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.triageGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Basic info
                            _SectionCard(
                              title: 'Basic Information',
                              icon: Icons.info_outline_rounded,
                              iconColor: AppColors.primary,
                              children: [
                                _InfoRow('Age', '${_member!.age} years'),
                                _InfoRow(
                                  'Date of Birth',
                                  DateFormat('dd MMMM yyyy')
                                      .format(_member!.dateOfBirth),
                                ),
                                _InfoRow(
                                  'Gender',
                                  _member!.gender.name[0].toUpperCase() +
                                      _member!.gender.name.substring(1),
                                ),
                                if (_member!.bloodGroup != null)
                                  _InfoRow('Blood Group', _member!.bloodGroup!),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Health IDs
                            if (_member!.abhaId != null || _member!.healthId != null)
                              _SectionCard(
                                title: 'Health IDs',
                                icon: Icons.badge_rounded,
                                iconColor: AppColors.secondary,
                                children: [
                                  if (_member!.abhaId != null)
                                    _InfoRow('ABHA ID', _member!.abhaId!),
                                  if (_member!.healthId != null)
                                    _InfoRow('Health ID', _member!.healthId!),
                                ],
                              ),

                            if (_member!.abhaId != null || _member!.healthId != null)
                              const SizedBox(height: 12),

                            // Contact info
                            if (_member!.phone != null || _member!.email != null)
                              _SectionCard(
                                title: 'Contact Information',
                                icon: Icons.contact_phone_rounded,
                                iconColor: const Color(0xFF0288D1),
                                children: [
                                  if (_member!.phone != null)
                                    _InfoRow('Phone', _member!.phone!),
                                  if (_member!.email != null)
                                    _InfoRow('Email', _member!.email!),
                                ],
                              ),

                            if (_member!.phone != null || _member!.email != null)
                              const SizedBox(height: 12),

                            // Access level
                            _SectionCard(
                              title: 'Access Permissions',
                              icon: Icons.security_rounded,
                              iconColor: const Color(0xFF7B2FBE),
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _member!.accessLevel == AccessLevel.full
                                            ? AppColors.secondary.withOpacity(0.12)
                                            : AppColors.textHint.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _member!.accessLevel == AccessLevel.full
                                            ? Icons.admin_panel_settings_rounded
                                            : Icons.visibility_rounded,
                                        color: _member!.accessLevel == AccessLevel.full
                                            ? AppColors.secondary
                                            : AppColors.textHint,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _member!.accessLevel == AccessLevel.full
                                                ? 'Full Access'
                                                : 'View Only',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _member!.accessLevel == AccessLevel.full
                                                ? 'Can view records and book appointments'
                                                : 'Can only view health records',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Medical info
                            if (_member!.medicalConditions.isNotEmpty ||
                                _member!.allergies.isNotEmpty)
                              _SectionCard(
                                title: 'Medical Information',
                                icon: Icons.medical_information_rounded,
                                iconColor: AppColors.triageRed,
                                children: [
                                  if (_member!.medicalConditions.isNotEmpty) ...[
                                    const Text(
                                      'Medical Conditions:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ..._member!.medicalConditions.map(
                                      (condition) => Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.circle,
                                              size: 6,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                condition,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (_member!.allergies.isNotEmpty) ...[
                                    if (_member!.medicalConditions.isNotEmpty)
                                      const SizedBox(height: 12),
                                    const Text(
                                      'Allergies:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ..._member!.allergies.map(
                                      (allergy) => Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.warning_rounded,
                                              size: 16,
                                              color: AppColors.triageYellow,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                allergy,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                            if (_member!.medicalConditions.isNotEmpty ||
                                _member!.allergies.isNotEmpty)
                              const SizedBox(height: 12),

                            // Notes
                            if (_member!.notes != null)
                              _SectionCard(
                                title: 'Notes',
                                icon: Icons.note_rounded,
                                iconColor: AppColors.textSecondary,
                                children: [
                                  Text(
                                    _member!.notes!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),

                            if (_member!.notes != null) const SizedBox(height: 20),

                            // Action buttons
                            if (_member!.accessLevel == AccessLevel.full)
                              ScButton(
                                label: 'Book Appointment',
                                icon: Icons.calendar_month_rounded,
                                onPressed: _bookAppointment,
                              ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text(
            'Family member not found',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ScCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
