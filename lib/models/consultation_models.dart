import 'package:flutter/material.dart';

// Add enum for consultation status
enum ConsultationStatus { waiting, inProgress, completed, cancelled }

// Add missing enums for schedule compatibility
enum ConsultationType { consultation, followUp, checkUp }

enum ScheduleStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  waitingConfirmation
}

// Add chat-based consultation model
class ChatConsultation {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime scheduledTime;
  final ConsultationStatus status;
  final int queuePosition;
  final int estimatedWaitMinutes;
  final List<ChatConsultationMessage> messages; // RENAMED to avoid conflict
  final bool hasUnreadMessages;
  final DateTime? lastMessageTime;

  ChatConsultation({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.scheduledTime,
    required this.status,
    required this.queuePosition,
    required this.estimatedWaitMinutes,
    required this.messages,
    required this.hasUnreadMessages,
    this.lastMessageTime,
  });

  factory ChatConsultation.fromJson(Map<String, dynamic> json) {
    return ChatConsultation(
      id: json['id'] ?? '',
      doctorName: json['doctorName'] ?? '',
      specialty: json['specialty'] ?? '',
      scheduledTime: DateTime.parse(
          json['scheduledTime'] ?? DateTime.now().toIso8601String()),
      status: _parseConsultationStatus(json['status']),
      queuePosition: json['queuePosition'] ?? 0,
      estimatedWaitMinutes: json['estimatedWaitMinutes'] ?? 0,
      messages: (json['messages'] as List? ?? [])
          .map((msg) => ChatConsultationMessage.fromJson(msg)) // RENAMED
          .toList(),
      hasUnreadMessages: json['hasUnreadMessages'] ?? false,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
    );
  }

  static ConsultationStatus _parseConsultationStatus(dynamic status) {
    if (status == null) return ConsultationStatus.waiting;

    switch (status.toString().toUpperCase()) {
      case 'WAITING':
        return ConsultationStatus.waiting;
      case 'IN_PROGRESS':
        return ConsultationStatus.inProgress;
      case 'COMPLETED':
        return ConsultationStatus.completed;
      case 'CANCELLED':
        return ConsultationStatus.cancelled;
      default:
        return ConsultationStatus.waiting;
    }
  }
}

// Add available time slot model
class TimeSlot {
  final String id;
  final DateTime dateTime;
  final String timeDisplay;
  final bool isAvailable;
  final int currentQueue;
  final int maxQueue;

  TimeSlot({
    required this.id,
    required this.dateTime,
    required this.timeDisplay,
    required this.isAvailable,
    required this.currentQueue,
    required this.maxQueue,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] ?? '',
      dateTime:
          DateTime.parse(json['dateTime'] ?? DateTime.now().toIso8601String()),
      timeDisplay: json['timeDisplay'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      currentQueue: json['currentQueue'] ?? 0,
      maxQueue: json['maxQueue'] ?? 10,
    );
  }
}

// RENAMED ChatMessage to ChatConsultationMessage to avoid conflict with chat_models.dart
class ChatConsultationMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;

  ChatConsultationMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isRead = true,
    this.attachmentUrl,
  });

  factory ChatConsultationMessage.fromJson(Map<String, dynamic> json) {
    return ChatConsultationMessage(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? true,
      attachmentUrl: json['attachmentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
    };
  }
}

// Keep all existing models...
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
  final String id;
  final String name;
  final String specialty;
  final String? hospital;
  final double? rating;
  final String? experience;
  final String? photoUrl;
  final double consultationFee;
  final bool isAvailable;
  final String? description;

  DoctorInfo({
    this.id = '',
    required this.name,
    required this.specialty,
    this.hospital,
    this.rating,
    this.experience,
    this.photoUrl,
    this.consultationFee = 25000.0,
    this.isAvailable = true,
    this.description,
  });

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    // Safe fee parsing
    double parsedFee = 25000.0;

    final feeValue = json['consultationFee'];
    if (feeValue != null) {
      if (feeValue is num) {
        parsedFee = feeValue.toDouble();
      } else if (feeValue is String) {
        try {
          parsedFee = double.parse(feeValue);
        } catch (e) {
          print('⚠️ Error parsing fee string: $feeValue');
        }
      }
    }

    if (parsedFee <= 0) {
      parsedFee = 25000.0;
    }

    return DoctorInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      hospital: json['hospital']?.toString(),
      rating:
          (json['rating'] is num) ? (json['rating'] as num).toDouble() : null,
      experience: json['experience']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      consultationFee: parsedFee,
      isAvailable: json['isAvailable'] == true,
      description: json['description']?.toString(),
    );
  }

  // Fix: Use getter instead of computed property
  String get formattedFee {
    return 'Rp ${consultationFee.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String get specialtyDisplay {
    if (specialty.toLowerCase().contains('umum')) {
      return 'Dokter Umum';
    }
    return specialty;
  }

  bool get isGeneralPractitioner {
    return specialty.toLowerCase().contains('umum') ||
        specialty.toLowerCase() == 'general practitioner';
  }
}

// Add missing ConsultationSchedule class for backward compatibility
class ConsultationSchedule {
  final String id;
  final String doctorName;
  final String specialty;
  final String hospital;
  final DateTime scheduledDate;
  final ConsultationType type;
  final ScheduleStatus status;
  final String? queueNumber;
  final int estimatedDuration;
  final String room;
  final String notes;
  final bool isUrgent;

  ConsultationSchedule({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.scheduledDate,
    required this.type,
    required this.status,
    this.queueNumber,
    required this.estimatedDuration,
    required this.room,
    required this.notes,
    this.isUrgent = false,
  });

  factory ConsultationSchedule.fromJson(Map<String, dynamic> json) {
    return ConsultationSchedule(
      id: json['id'] ?? '',
      doctorName: json['doctorName'] ?? '',
      specialty: json['specialty'] ?? '',
      hospital: json['hospital'] ?? '',
      scheduledDate: DateTime.parse(
          json['scheduledDate'] ?? DateTime.now().toIso8601String()),
      type: _parseConsultationType(json['type']),
      status: _parseScheduleStatus(json['status']),
      queueNumber: json['queueNumber'],
      estimatedDuration: json['estimatedDuration'] ?? 15,
      room: json['room'] ?? '',
      notes: json['notes'] ?? '',
      isUrgent: json['isUrgent'] ?? false,
    );
  }

  static ConsultationType _parseConsultationType(dynamic type) {
    if (type == null) return ConsultationType.consultation;

    switch (type.toString().toUpperCase()) {
      case 'CONSULTATION':
        return ConsultationType.consultation;
      case 'FOLLOW_UP':
        return ConsultationType.followUp;
      case 'CHECK_UP':
        return ConsultationType.checkUp;
      default:
        return ConsultationType.consultation;
    }
  }

  static ScheduleStatus _parseScheduleStatus(dynamic status) {
    if (status == null) return ScheduleStatus.pending;

    switch (status.toString().toUpperCase()) {
      case 'PENDING':
        return ScheduleStatus.pending;
      case 'CONFIRMED':
        return ScheduleStatus.confirmed;
      case 'COMPLETED':
        return ScheduleStatus.completed;
      case 'CANCELLED':
        return ScheduleStatus.cancelled;
      case 'WAITING_CONFIRMATION':
        return ScheduleStatus.waitingConfirmation;
      default:
        return ScheduleStatus.pending;
    }
  }
}

class ScheduleConsultationItem {
  final String id;
  final String type; // 'AI', 'CHAT_DOCTOR', 'GENERAL'
  final String status; // 'WAITING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
  final DateTime scheduledTime;
  final DoctorInfo? doctor;
  final List<String> symptoms;
  final String? queueNumber;
  final int? position;
  final int? estimatedWaitMinutes;
  final bool isUrgent;
  final String? notes;

  ScheduleConsultationItem({
    required this.id,
    required this.type,
    required this.status,
    required this.scheduledTime,
    this.doctor,
    required this.symptoms,
    this.queueNumber,
    this.position,
    this.estimatedWaitMinutes,
    this.isUrgent = false,
    this.notes,
  });

  factory ScheduleConsultationItem.fromJson(Map<String, dynamic> json) {
    return ScheduleConsultationItem(
      id: json['id'] ?? '',
      type: json['type'] ?? 'AI',
      status: json['status'] ?? 'WAITING',
      scheduledTime: DateTime.parse(
          json['scheduledTime'] ?? DateTime.now().toIso8601String()),
      doctor:
          json['doctor'] != null ? DoctorInfo.fromJson(json['doctor']) : null,
      symptoms: List<String>.from(json['symptoms'] ?? []),
      queueNumber: json['queueNumber'],
      position: json['position'],
      estimatedWaitMinutes: json['estimatedWaitMinutes'],
      isUrgent: json['isUrgent'] ?? false,
      notes: json['notes'],
    );
  }

  // Convert to legacy ConsultationSchedule for UI compatibility
  ConsultationSchedule toLegacySchedule() {
    return ConsultationSchedule(
      id: id,
      doctorName: doctor?.name ?? 'AI Assistant',
      specialty: doctor?.specialty ?? 'AI Consultation',
      hospital: doctor?.hospital ?? 'HospitalLink Virtual',
      scheduledDate: scheduledTime,
      type: _getConsultationType(),
      status: _getScheduleStatus(),
      queueNumber: queueNumber,
      estimatedDuration: estimatedWaitMinutes ?? 15,
      room: _getRoomInfo(),
      notes: notes ?? _getDefaultNotes(),
      isUrgent: isUrgent,
    );
  }

  ConsultationType _getConsultationType() {
    switch (type) {
      case 'AI':
        return ConsultationType.consultation;
      case 'CHAT_DOCTOR':
        return ConsultationType.followUp;
      case 'GENERAL':
        return ConsultationType.checkUp;
      default:
        return ConsultationType.consultation;
    }
  }

  ScheduleStatus _getScheduleStatus() {
    switch (status) {
      case 'WAITING':
        return ScheduleStatus.pending;
      case 'IN_PROGRESS':
        return ScheduleStatus.confirmed;
      case 'COMPLETED':
        return ScheduleStatus.completed;
      case 'CANCELLED':
        return ScheduleStatus.cancelled;
      default:
        return ScheduleStatus.pending;
    }
  }

  String _getRoomInfo() {
    if (type == 'AI') return 'Virtual AI Room';
    if (type == 'CHAT_DOCTOR') return 'Chat Room';
    return doctor?.hospital ?? 'Ruang Praktik';
  }

  String _getDefaultNotes() {
    switch (type) {
      case 'AI':
        return 'Konsultasi AI untuk screening gejala: ${symptoms.take(2).join(', ')}';
      case 'CHAT_DOCTOR':
        return 'Chat konsultasi dengan dokter';
      case 'GENERAL':
        return 'Konsultasi umum';
      default:
        return 'Konsultasi medis';
    }
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
  final String? recommendation;
  final String message;
  final bool needsDoctorConsultation;
  final double estimatedFee;
  final double confidence;
  final String type;
  final String? question;
  final int? questionNumber;
  final int? totalQuestions;
  final Map<String, dynamic>? progress;
  final String? primaryDiagnosis;
  final List<String>? possibleConditions;
  final String? urgencyLevel;
  final List<String>? recommendedActions;
  final Map<String, dynamic>? medicalResearch;
  final bool isComplete;

  AIScreeningResult({
    required this.consultationId,
    required this.severity,
    this.recommendation,
    required this.message,
    required this.needsDoctorConsultation,
    required this.estimatedFee,
    required this.confidence,
    required this.type,
    this.question,
    this.questionNumber,
    this.totalQuestions,
    this.progress,
    this.primaryDiagnosis,
    this.possibleConditions,
    this.urgencyLevel,
    this.recommendedActions,
    this.medicalResearch,
    this.isComplete = false,
  });

  // Safer fromJson method
  factory AIScreeningResult.fromJson(Map<String, dynamic> json) {
    try {
      return AIScreeningResult(
        consultationId: json['consultationId']?.toString() ?? '',
        severity: json['severity']?.toString() ?? 'MEDIUM',
        recommendation: json['recommendation']?.toString(),
        message: json['message']?.toString() ?? 'Hasil analisis tersedia',
        needsDoctorConsultation: json['needsDoctorConsultation'] == true,
        estimatedFee: (json['estimatedFee'] is num)
            ? (json['estimatedFee'] as num).toDouble()
            : 0.0,
        confidence: (json['confidence'] is num)
            ? (json['confidence'] as num).toDouble()
            : 0.7,
        type: json['type']?.toString() ?? 'FINAL_DIAGNOSIS',
        question: json['question']?.toString(),
        questionNumber: json['questionNumber'] is num
            ? (json['questionNumber'] as num).toInt()
            : null,
        totalQuestions: json['totalQuestions'] is num
            ? (json['totalQuestions'] as num).toInt()
            : null,
        progress: json['progress'] is Map<String, dynamic>
            ? json['progress'] as Map<String, dynamic>
            : null,
        primaryDiagnosis: json['primaryDiagnosis']?.toString(),
        possibleConditions: json['possibleConditions'] is List
            ? (json['possibleConditions'] as List)
                .map((e) => e.toString())
                .toList()
            : null,
        urgencyLevel: json['urgencyLevel']?.toString(),
        recommendedActions: json['recommendedActions'] is List
            ? (json['recommendedActions'] as List)
                .map((e) => e.toString())
                .toList()
            : null,
        medicalResearch: json['medicalResearch'] is Map<String, dynamic>
            ? json['medicalResearch'] as Map<String, dynamic>
            : null,
        isComplete: json['isComplete'] == true,
      );
    } catch (e) {
      print('Error parsing AIScreeningResult: $e');
      // Return fallback result
      return AIScreeningResult(
        consultationId: json['consultationId']?.toString() ?? '',
        severity: 'MEDIUM',
        recommendation: 'DOCTOR_CONSULTATION',
        message: 'Hasil analisis tersedia, silakan lihat detail.',
        needsDoctorConsultation: true,
        estimatedFee: 25000.0,
        confidence: 0.7,
        type: 'FINAL_DIAGNOSIS',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'consultationId': consultationId,
      'severity': severity,
      'recommendation': recommendation,
      'message': message,
      'needsDoctorConsultation': needsDoctorConsultation,
      'estimatedFee': estimatedFee,
      'confidence': confidence,
      'type': type,
      'question': question,
      'questionNumber': questionNumber,
      'totalQuestions': totalQuestions,
      'progress': progress,
      'primaryDiagnosis': primaryDiagnosis,
      'possibleConditions': possibleConditions,
      'urgencyLevel': urgencyLevel,
      'recommendedActions': recommendedActions,
      'medicalResearch': medicalResearch,
      'isComplete': isComplete,
    };
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

// NEW: Direct consultation result
class DirectConsultationResult {
  final String consultationId;
  final DoctorInfo doctor;
  final double consultationFee;
  final String queueNumber;
  final int position;
  final int estimatedWaitMinutes;
  final String status;
  final DateTime scheduledTime;
  final List<String> nextSteps; // ✅ Add this property

  DirectConsultationResult({
    required this.consultationId,
    required this.doctor,
    required this.consultationFee,
    required this.queueNumber,
    required this.position,
    required this.estimatedWaitMinutes,
    required this.status,
    required this.scheduledTime,
    required this.nextSteps, // ✅ Add this parameter
  });

  factory DirectConsultationResult.fromJson(Map<String, dynamic> json) {
    return DirectConsultationResult(
      consultationId: json['consultation']['id']?.toString() ?? '',
      doctor: DoctorInfo.fromJson(json['doctor'] ?? {}),
      consultationFee: (json['consultation']['consultationFee'] is num)
          ? (json['consultation']['consultationFee'] as num).toDouble()
          : 0.0,
      queueNumber: json['queue']['queueNumber']?.toString() ?? '',
      position: json['queue']['position'] is num
          ? (json['queue']['position'] as num).toInt()
          : 0,
      estimatedWaitMinutes: json['queue']['estimatedWaitTime'] is num
          ? (json['queue']['estimatedWaitTime'] as num).toInt()
          : 15,
      status: json['queue']['status']?.toString() ?? 'WAITING',
      scheduledTime: DateTime.parse(json['consultation']['scheduledTime'] ??
          DateTime.now().toIso8601String()),
      nextSteps: List<String>.from(json['nextSteps'] ?? []), // ✅ Add this line
    );
  }
}
