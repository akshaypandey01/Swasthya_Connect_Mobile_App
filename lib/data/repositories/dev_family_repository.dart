/// Development repository for family members with mock data

import '../models/family_member_model.dart';

class DevFamilyRepository {
  /// Simulates network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  /// Get all family members for a user
  Future<List<FamilyMember>> getFamilyMembers(String primaryUserId) async {
    await _simulateDelay();
    return _mockFamilyMembers
        .where((m) => m.primaryUserId == primaryUserId)
        .toList()
      ..sort((a, b) => a.addedAt.compareTo(b.addedAt));
  }

  /// Get single family member by ID
  Future<FamilyMember?> getFamilyMember(String id) async {
    await _simulateDelay();
    try {
      return _mockFamilyMembers.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new family member
  Future<FamilyMember> addFamilyMember({
    required String primaryUserId,
    required String name,
    required Relationship relationship,
    required Gender gender,
    required DateTime dateOfBirth,
    String? abhaId,
    String? healthId,
    String? bloodGroup,
    AccessLevel accessLevel = AccessLevel.full,
    String? phone,
    String? email,
    List<String>? medicalConditions,
    List<String>? allergies,
    String? notes,
  }) async {
    await _simulateDelay();

    final member = FamilyMember(
      id: 'fm_${DateTime.now().millisecondsSinceEpoch}',
      primaryUserId: primaryUserId,
      name: name,
      relationship: relationship,
      gender: gender,
      dateOfBirth: dateOfBirth,
      abhaId: abhaId,
      healthId: healthId,
      bloodGroup: bloodGroup,
      accessLevel: accessLevel,
      sharedRecordIds: [],
      phone: phone,
      email: email,
      medicalConditions: medicalConditions ?? [],
      allergies: allergies ?? [],
      addedAt: DateTime.now(),
      isVerified: abhaId != null,
      notes: notes,
    );

    _mockFamilyMembers.add(member);
    return member;
  }

  /// Update family member
  Future<bool> updateFamilyMember({
    required String memberId,
    String? name,
    String? abhaId,
    String? healthId,
    String? bloodGroup,
    AccessLevel? accessLevel,
    String? phone,
    String? email,
    List<String>? medicalConditions,
    List<String>? allergies,
    String? notes,
  }) async {
    await _simulateDelay();

    final index = _mockFamilyMembers.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final member = _mockFamilyMembers[index];
      _mockFamilyMembers[index] = FamilyMember(
        id: member.id,
        primaryUserId: member.primaryUserId,
        name: name ?? member.name,
        relationship: member.relationship,
        gender: member.gender,
        dateOfBirth: member.dateOfBirth,
        abhaId: abhaId ?? member.abhaId,
        healthId: healthId ?? member.healthId,
        photoUrl: member.photoUrl,
        bloodGroup: bloodGroup ?? member.bloodGroup,
        accessLevel: accessLevel ?? member.accessLevel,
        hasSharedRecords: member.hasSharedRecords,
        sharedRecordIds: member.sharedRecordIds,
        phone: phone ?? member.phone,
        email: email ?? member.email,
        medicalConditions: medicalConditions ?? member.medicalConditions,
        allergies: allergies ?? member.allergies,
        addedAt: member.addedAt,
        isVerified: (abhaId ?? member.abhaId) != null,
        notes: notes ?? member.notes,
      );
      return true;
    }
    return false;
  }

  /// Delete family member
  Future<bool> deleteFamilyMember(String memberId) async {
    await _simulateDelay();
    final index = _mockFamilyMembers.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _mockFamilyMembers.removeAt(index);
      return true;
    }
    return false;
  }

  /// Share health record with family member
  Future<bool> shareRecord(String memberId, String recordId) async {
    await _simulateDelay();
    final index = _mockFamilyMembers.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final member = _mockFamilyMembers[index];
      if (!member.sharedRecordIds.contains(recordId)) {
        final updatedSharedRecords = List<String>.from(member.sharedRecordIds)..add(recordId);
        _mockFamilyMembers[index] = FamilyMember(
          id: member.id,
          primaryUserId: member.primaryUserId,
          name: member.name,
          relationship: member.relationship,
          gender: member.gender,
          dateOfBirth: member.dateOfBirth,
          abhaId: member.abhaId,
          healthId: member.healthId,
          photoUrl: member.photoUrl,
          bloodGroup: member.bloodGroup,
          accessLevel: member.accessLevel,
          hasSharedRecords: true,
          sharedRecordIds: updatedSharedRecords,
          phone: member.phone,
          email: member.email,
          medicalConditions: member.medicalConditions,
          allergies: member.allergies,
          addedAt: member.addedAt,
          isVerified: member.isVerified,
          notes: member.notes,
        );
      }
      return true;
    }
    return false;
  }

  /// Update access level
  Future<bool> updateAccessLevel(String memberId, AccessLevel newLevel) async {
    await _simulateDelay();
    return updateFamilyMember(memberId: memberId, accessLevel: newLevel);
  }

  /// Mock family members data
  static final List<FamilyMember> _mockFamilyMembers = [
    FamilyMember(
      id: 'fm_001',
      primaryUserId: 'patient_123',
      name: 'Rajesh Kumar',
      relationship: Relationship.spouse,
      gender: Gender.male,
      dateOfBirth: DateTime(1985, 3, 15),
      abhaId: '12-3456-7890-1234',
      healthId: 'rajesh.kumar@abdm',
      bloodGroup: 'B+',
      accessLevel: AccessLevel.full,
      hasSharedRecords: true,
      sharedRecordIds: ['rec_001', 'rec_002'],
      phone: '+91 98765 43210',
      email: 'rajesh.kumar@email.com',
      medicalConditions: ['Hypertension'],
      allergies: ['Penicillin'],
      addedAt: DateTime.now().subtract(const Duration(days: 180)),
      isVerified: true,
      notes: 'Primary family member with full access',
    ),
    FamilyMember(
      id: 'fm_002',
      primaryUserId: 'patient_123',
      name: 'Aarav Kumar',
      relationship: Relationship.child,
      gender: Gender.male,
      dateOfBirth: DateTime(2015, 8, 20),
      healthId: 'aarav.kumar@abdm',
      bloodGroup: 'O+',
      accessLevel: AccessLevel.full,
      hasSharedRecords: false,
      sharedRecordIds: [],
      phone: null,
      email: null,
      medicalConditions: ['Asthma (mild)'],
      allergies: ['Dust', 'Pollen'],
      addedAt: DateTime.now().subtract(const Duration(days: 160)),
      isVerified: false,
      notes: 'Child dependent. Regular pediatric checkups needed.',
    ),
    FamilyMember(
      id: 'fm_003',
      primaryUserId: 'patient_123',
      name: 'Sunita Devi',
      relationship: Relationship.parent,
      gender: Gender.female,
      dateOfBirth: DateTime(1960, 12, 5),
      abhaId: '98-7654-3210-9876',
      healthId: 'sunita.devi@abdm',
      bloodGroup: 'A+',
      accessLevel: AccessLevel.viewOnly,
      hasSharedRecords: true,
      sharedRecordIds: ['rec_005'],
      phone: '+91 98234 56789',
      email: null,
      medicalConditions: ['Type 2 Diabetes', 'Osteoarthritis'],
      allergies: [],
      addedAt: DateTime.now().subtract(const Duration(days: 150)),
      isVerified: true,
      notes: 'Elderly parent. View-only access for health monitoring.',
    ),
    FamilyMember(
      id: 'fm_004',
      primaryUserId: 'patient_123',
      name: 'Priya Kumar',
      relationship: Relationship.child,
      gender: Gender.female,
      dateOfBirth: DateTime(2018, 5, 10),
      healthId: 'priya.kumar@abdm',
      bloodGroup: 'B+',
      accessLevel: AccessLevel.full,
      hasSharedRecords: false,
      sharedRecordIds: [],
      phone: null,
      email: null,
      medicalConditions: [],
      allergies: ['Eggs', 'Shellfish'],
      addedAt: DateTime.now().subtract(const Duration(days: 140)),
      isVerified: false,
      notes: 'Youngest child. Vaccination schedule up to date.',
    ),
  ];
}
