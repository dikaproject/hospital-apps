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
    this.reminderTimes = const [],
  }) {
    // Ensure reminderTimes is mutable
    if (reminderTimes is! List<String>) {
      this.reminderTimes = List<String>.from(reminderTimes);
    }
  }

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
}
