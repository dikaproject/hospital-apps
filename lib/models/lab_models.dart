enum TestStatus {
  normal,
  abnormal,
  borderline,
}

class TestResult {
  final String testName;
  final String value;
  final String unit;
  final String normalRange;
  final TestStatus status;
  final String description;

  TestResult({
    required this.testName,
    required this.value,
    required this.unit,
    required this.normalRange,
    required this.status,
    this.description = '',
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      testName: json['testName'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'] ?? '',
      normalRange: json['normalRange'] ?? '',
      status: _parseTestStatus(json['status']),
      description: json['description'] ?? '',
    );
  }

  static TestStatus _parseTestStatus(dynamic status) {
    switch (status?.toString().toUpperCase()) {
      case 'NORMAL':
        return TestStatus.normal;
      case 'ABNORMAL':
        return TestStatus.abnormal;
      case 'BORDERLINE':
        return TestStatus.borderline;
      default:
        return TestStatus.normal;
    }
  }
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  int duration; // days - made mutable for notification setup
  final String instructions;
  final String sideEffects;
  bool isActive;
  bool reminderEnabled; // made mutable
  List<String> reminderTimes; // made mutable

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
    this.sideEffects = '',
    this.isActive = true,
    this.reminderEnabled = false,
    List<String>? reminderTimes, // ✅ FIX: Make nullable parameter
  }) : reminderTimes = reminderTimes != null
            ? List<String>.from(reminderTimes)
            : <String>[]; // ✅ FIX: Proper initialization

  // Add copyWith method for easy updates
  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    int? duration,
    String? instructions,
    String? sideEffects,
    bool? isActive,
    bool? reminderEnabled,
    List<String>? reminderTimes,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      sideEffects: sideEffects ?? this.sideEffects,
      isActive: isActive ?? this.isActive,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTimes: reminderTimes ?? List<String>.from(this.reminderTimes),
    );
  }

  // ✅ ADD: fromJson method for proper parsing
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? 7,
      instructions: json['instructions'] ?? '',
      sideEffects: json['sideEffects'] ?? '',
      isActive: json['isActive'] ?? true,
      reminderEnabled: json['reminderEnabled'] ?? false,
      reminderTimes: (json['reminderTimes'] as List?)?.cast<String>() ?? [],
    );
  }

  // ✅ ADD: toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
      'sideEffects': sideEffects,
      'isActive': isActive,
      'reminderEnabled': reminderEnabled,
      'reminderTimes': reminderTimes,
    };
  }
}

class LabResult {
  final String id;
  final DateTime testDate;
  final String doctorName;
  final String specialty;
  final String hospital;
  final String testType;
  final List<TestResult> results;
  final List<Medication> medications;
  final String doctorNotes;
  final DateTime? nextCheckup;

  LabResult({
    required this.id,
    required this.testDate,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.testType,
    required this.results,
    required this.medications,
    this.doctorNotes = '',
    this.nextCheckup,
  });

  // ✅ ADD: fromJson method
  static TestResult fromJson(Map<String, dynamic> json) {
    return TestResult(
      testName: json['testName'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'] ?? '',
      normalRange: json['normalRange'] ?? '',
      status: _parseTestStatus(json['status']),
      description: json['description'] ?? '',
    );
  }

  static TestStatus _parseTestStatus(dynamic status) {
    switch (status?.toString().toUpperCase()) {
      case 'NORMAL':
        return TestStatus.normal;
      case 'ABNORMAL':
        return TestStatus.abnormal;
      case 'BORDERLINE':
        return TestStatus.borderline;
      default:
        return TestStatus.normal;
    }
  }
}
