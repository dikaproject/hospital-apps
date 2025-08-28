class ConsultationResult {
  final ConsultationSeverity severity;
  final String title;
  final String description;
  final List<String> recommendations;
  final List<String>? medication;
  final String followUp;
  final String? doctorSpecialty;
  final bool isUrgent;

  ConsultationResult({
    required this.severity,
    required this.title,
    required this.description,
    required this.recommendations,
    this.medication,
    required this.followUp,
    this.doctorSpecialty,
    this.isUrgent = false,
  });
}

enum ConsultationSeverity { low, medium, high }

class DoctorInfo {
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final String experience;
  final String photoUrl;

  DoctorInfo({
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.experience,
    required this.photoUrl,
  });
}

class DoctorRecommendation {
  final String doctorName;
  final String specialty;
  final String hospital;
  final String urgency;
  final String notes;

  DoctorRecommendation({
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.urgency,
    required this.notes,
  });
}

// Tambahkan model untuk Queue Info (pindahkan dari auto_queue_screen.dart)
class QueueInfo {
  final String queueNumber;
  final int estimatedWaitTime;
  final String currentNumber;
  final int totalInQueue;
  final String doctorName;
  final String specialty;
  final String hospital;
  final DateTime appointmentTime;
  final String consultationId;

  QueueInfo({
    required this.queueNumber,
    required this.estimatedWaitTime,
    required this.currentNumber,
    required this.totalInQueue,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.appointmentTime,
    required this.consultationId,
  });
}

// Tambahkan model untuk General Doctor Recommendation
class GeneralDoctorRecommendation {
  final String recommendedSpecialist;
  final String urgencyLevel;
  final String notes;
  final String generalDoctorName;

  GeneralDoctorRecommendation({
    required this.recommendedSpecialist,
    required this.urgencyLevel,
    required this.notes,
    required this.generalDoctorName,
  });
}
