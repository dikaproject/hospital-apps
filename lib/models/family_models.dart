enum FamilyRelation {
  self,
  spouse,
  child,
  parent,
  grandparent,
  sibling,
  other,
}

enum Gender {
  male,
  female,
}

enum HealthStatus {
  good,
  needsAttention,
  critical,
}

enum ActivityType {
  appointment,
  labResult,
  medication,
  emergency,
}

class FamilyMember {
  final String id;
  final String name;
  final FamilyRelation relation;
  final int age;
  final Gender gender;
  final String profileImage;
  final bool isActive;
  final DateTime lastActivity;
  final int upcomingAppointments;
  final int pendingLabResults;
  final int activeMedications;
  final HealthStatus healthStatus;
  final bool emergencyContact;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.age,
    required this.gender,
    this.profileImage = '',
    this.isActive = true,
    required this.lastActivity,
    this.upcomingAppointments = 0,
    this.pendingLabResults = 0,
    this.activeMedications = 0,
    this.healthStatus = HealthStatus.good,
    this.emergencyContact = false,
  });
}

class FamilyStats {
  final int totalMembers;
  final int activeMembers;
  final int upcomingAppointments;
  final int pendingResults;
  final int activeMedications;
  final int emergencyContacts;

  FamilyStats({
    required this.totalMembers,
    required this.activeMembers,
    required this.upcomingAppointments,
    required this.pendingResults,
    required this.activeMedications,
    required this.emergencyContacts,
  });

  factory FamilyStats.empty() {
    return FamilyStats(
      totalMembers: 0,
      activeMembers: 0,
      upcomingAppointments: 0,
      pendingResults: 0,
      activeMedications: 0,
      emergencyContacts: 0,
    );
  }
}

class FamilyActivity {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String memberName;

  FamilyActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.memberName,
  });
}

String getFamilyRelationText(FamilyRelation relation) {
  switch (relation) {
    case FamilyRelation.self:
      return 'Saya';
    case FamilyRelation.spouse:
      return 'Pasangan';
    case FamilyRelation.child:
      return 'Anak';
    case FamilyRelation.parent:
      return 'Orang Tua';
    case FamilyRelation.grandparent:
      return 'Kakek/Nenek';
    case FamilyRelation.sibling:
      return 'Saudara';
    case FamilyRelation.other:
      return 'Lainnya';
  }
}
