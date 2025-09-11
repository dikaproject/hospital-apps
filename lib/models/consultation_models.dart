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

// Update DoctorInfo constructor to make id optional with default
class DoctorInfo {
  final String id;
  final String name;
  final String specialty;
  final String? hospital;
  final double? rating;
  final String? experience;
  final String? photoUrl;

  DoctorInfo({
    this.id = '', // Add default value
    required this.name,
    required this.specialty,
    this.hospital,
    this.rating,
    this.experience,
    this.photoUrl,
  });

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      hospital: json['hospital'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      experience: json['experience'],
      photoUrl: json['photoUrl'],
    );
  }
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

class AIScreeningResult {
  final String consultationId;
  final String severity;
  final String recommendation;
  final String message;
  final bool needsDoctorConsultation;
  final int estimatedFee;
  final double confidence;
  final Map<String, dynamic>? symptomsAnalysis;

  AIScreeningResult({
    required this.consultationId,
    required this.severity,
    required this.recommendation,
    required this.message,
    required this.needsDoctorConsultation,
    required this.estimatedFee,
    required this.confidence,
    this.symptomsAnalysis,
  });

  factory AIScreeningResult.fromJson(Map<String, dynamic> json) {
    return AIScreeningResult(
      consultationId: json['consultationId'] ?? '',
      severity: json['severity'] ?? 'MEDIUM',
      recommendation: json['recommendation'] ?? 'DOCTOR_CONSULTATION',
      message: json['message'] ?? '',
      needsDoctorConsultation: json['needsDoctorConsultation'] ?? true,
      estimatedFee: json['estimatedFee'] ?? 0,
      confidence: (json['confidence'] ?? 0.7).toDouble(),
      symptomsAnalysis: json['symptoms_analysis'],
    );
  }
}

class DoctorConsultationResult {
  final String consultationId;
  final DoctorInfo doctor;
  final int estimatedCallTime;
  final int consultationFee;

  DoctorConsultationResult({
    required this.consultationId,
    required this.doctor,
    required this.estimatedCallTime,
    required this.consultationFee,
  });

  factory DoctorConsultationResult.fromJson(Map<String, dynamic> json) {
    return DoctorConsultationResult(
      consultationId: json['consultationId'] ?? '',
      doctor: DoctorInfo.fromJson(json['doctor'] ?? {}),
      estimatedCallTime: json['estimatedCallTime'] ?? 5,
      consultationFee: json['consultationFee'] ?? 25000,
    );
  }
}

class AppointmentBookingResult {
  final String appointmentId;
  final String queueId;
  final String queueNumber;
  final int position;
  final DateTime appointmentDate;
  final DateTime startTime;
  final int estimatedWaitTime;
  final String qrCode;
  final int totalFee;

  AppointmentBookingResult({
    required this.appointmentId,
    required this.queueId,
    required this.queueNumber,
    required this.position,
    required this.appointmentDate,
    required this.startTime,
    required this.estimatedWaitTime,
    required this.qrCode,
    required this.totalFee,
  });

  factory AppointmentBookingResult.fromJson(Map<String, dynamic> json) {
    return AppointmentBookingResult(
      appointmentId: json['appointmentId'] ?? '',
      queueId: json['queueId'] ?? '',
      queueNumber: json['queueNumber'] ?? '',
      position: json['position'] ?? 1,
      appointmentDate: DateTime.parse(
          json['appointmentDate'] ?? DateTime.now().toIso8601String()),
      startTime:
          DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      estimatedWaitTime: json['estimatedWaitTime'] ?? 15,
      qrCode: json['qrCode'] ?? '',
      totalFee: json['totalFee'] ?? 40000,
    );
  }
}

class ConsultationHistoryItem {
  final String id;
  final String type;
  final String severity;
  final List<String> symptoms;
  final Map<String, dynamic>? aiAnalysis;
  final Map<String, dynamic>? recommendations;
  final bool isCompleted;
  final DateTime createdAt;
  final DoctorInfo? doctor;

  ConsultationHistoryItem({
    required this.id,
    required this.type,
    required this.severity,
    required this.symptoms,
    this.aiAnalysis,
    this.recommendations,
    required this.isCompleted,
    required this.createdAt,
    this.doctor,
  });

  factory ConsultationHistoryItem.fromJson(Map<String, dynamic> json) {
    return ConsultationHistoryItem(
      id: json['id'] ?? '',
      type: json['type'] ?? 'AI',
      severity: json['severity'] ?? 'MEDIUM',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      aiAnalysis: json['aiAnalysis'],
      recommendations: json['recommendations'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      doctor:
          json['doctor'] != null ? DoctorInfo.fromJson(json['doctor']) : null,
    );
  }
}
