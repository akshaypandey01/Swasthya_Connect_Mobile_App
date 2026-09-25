import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/family_member_model.dart';
import '../../../data/repositories/dev_family_repository.dart';
import '../../shared/widgets/sc_app_bar.dart';
import '../../shared/widgets/sc_button.dart';
import '../../shared/widgets/sc_card.dart';

class FamilyListScreen extends StatefulWidget {
  const FamilyListScreen({super.key});

  @override
  State<FamilyListScreen> createState() => _FamilyListScreenState();
}

class _FamilyListScreenState extends State<FamilyListScreen> {
  final _repository = DevFamilyRepository();
  List<FamilyMember> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    final box = Hive.box(HiveConstants.settingsBox);
    final userId = box.get(HiveConstants.userIdKey, defaultValue: 'patient_123') as String;

    try {
      final members = await _repository.getFamilyMembers(userId);
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScAppBar(
        title: 'Family Members',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadMembers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _loadMembers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _members.length,
                    itemBuilder: (context, index) => _FamilyMemberCard(
                      member: _members[index],
                      onTap: () => _navigateToDetails(_members[index].id),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.addFamilyMember);
          _loadMembers();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Member'),
      ),
    );
  }

  void _navigateToDetails(String memberId) async {
    await context.push(AppRoutes.familyMemberDetails, extra: memberId);
    _loadMembers();
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.family_restroom_rounded,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text('No Family Members',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          const Text('Add family members to manage their health',
              style: TextStyle(fontSize: 13, color: AppColors.textHint)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await context.push(AppRoutes.addFamilyMember);
              _loadMembers();
            },
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add Family Member'),
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onTap;

  const _FamilyMemberCard({required this.member, required this.onTap});

  Color get _genderColor {
    switch (member.gender) {
      case Gender.male:
        return const Color(0xFF2196F3);
      case Gender.female:
        return const Color(0xFFE91E63);
      case Gender.other:
        return AppColors.textSecondary;
    }
  }

  IconData get _relationshipIcon {
    switch (member.relationship) {
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

  @override
  Widget build(BuildContext context) {
    return ScCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _genderColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: member.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      member.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        _relationshipIcon,
                        color: _genderColor,
                        size: 28,
                      ),
                    ),
                  )
                : Icon(
                    _relationshipIcon,
                    color: _genderColor,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.isVerified)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.triageGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified_rounded,
                                size: 12, color: AppColors.triageGreen),
                            SizedBox(width: 2),
                            Text(
                              'ABHA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.triageGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  member.relationshipDisplay,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.cake_rounded,
                        size: 13, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      '${member.age} years',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                    if (member.bloodGroup != null) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.bloodtype_rounded,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        member.bloodGroup!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Access level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: member.accessLevel == AccessLevel.full
                  ? AppColors.secondary.withOpacity(0.12)
                  : AppColors.textHint.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  member.accessLevel == AccessLevel.full
                      ? Icons.admin_panel_settings_rounded
                      : Icons.visibility_rounded,
                  size: 14,
                  color: member.accessLevel == AccessLevel.full
                      ? AppColors.secondary
                      : AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  member.accessLevel == AccessLevel.full ? 'Full' : 'View',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: member.accessLevel == AccessLevel.full
                        ? AppColors.secondary
                        : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
