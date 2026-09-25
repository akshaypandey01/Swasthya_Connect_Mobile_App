/// Family member data model for managing dependent family members

enum Relationship {
  spouse,
  child,
  parent,
  sibling,
  grandparent,
  grandchild,
  other
}

enum Gender {
  male,
  female,
  other
}

enum AccessLevel {
  full,      // Can view and book appointments
  viewOnly,  // Can only view health records
}

class FamilyMember {
  final String id;
  final String primaryUserId;
  final String name;
  final Relationship relationship;
  final Gender gender;
  final DateTime dateOfBirth;
  final String? abhaId;
  final String? healthId;
  final String? photoUrl;
  final String? bloodGroup;
  final AccessLevel accessLevel;
  final bool hasSharedRecords;
  final List<String> sharedRecordIds;
  final String? phone;
  final String? email;
  final List<String> medicalConditions;
  final List<String> allergies;
  final DateTime addedAt;
  final bool isVerified;
  final String? notes;

  FamilyMember({
    required this.id,
    required this.primaryUserId,
    required this.name,
    required this.relationship,
    required this.gender,
    required this.dateOfBirth,
    this.abhaId,
    this.healthId,
    this.photoUrl,
    this.bloodGroup,
    required this.accessLevel,
    this.hasSharedRecords = false,
    required this.sharedRecordIds,
    this.phone,
    this.email,
    required this.medicalConditions,
    required this.allergies,
    required this.addedAt,
    this.isVerified = false,
    this.notes,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  bool get isMinor => age < 18;

  String get relationshipDisplay {
    switch (relationship) {
      case Relationship.spouse:
        return gender == Gender.male ? 'Husband' : 'Wife';
      case Relationship.child:
        return gender == Gender.male ? 'Son' : 'Daughter';
      case Relationship.parent:
        return gender == Gender.male ? 'Father' : 'Mother';
      case Relationship.sibling:
        return gender == Gender.male ? 'Brother' : 'Sister';
      case Relationship.grandparent:
        return gender == Gender.male ? 'Grandfather' : 'Grandmother';
      case Relationship.grandchild:
        return gender == Gender.male ? 'Grandson' : 'Granddaughter';
      case Relationship.other:
        return 'Other';
    }
  }
}
