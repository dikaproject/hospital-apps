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

  DoctorInfo({
    this.id = '',
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
  final String recommendation;
  final String message;
  final bool needsDoctorConsultation;
  final int estimatedFee;
  final double confidence;
  final Map<String, dynamic>? symptomsAnalysis;
  
  // New fields for progressive consultation
  final String? type; // 'FOLLOW_UP_QUESTION' or 'FINAL_DIAGNOSIS'
  final String? question; // For follow-up questions
  final int? questionNumber;
  final int? totalQuestions;
  final Map<String, dynamic>? progress;
  final String? primaryDiagnosis;
  final List<String>? possibleConditions;
  final String? urgencyLevel;
  final List<String>? recommendedActions;
  final List<String>? redFlags;
  final String? whenToSeekHelp;
  final Map<String, dynamic>? medicalResearch;
  final bool? isComplete;

  AIScreeningResult({
    required this.consultationId,
    required this.severity,
    required this.recommendation,
    required this.message,
    required this.needsDoctorConsultation,
    required this.estimatedFee,
    required this.confidence,
    this.symptomsAnalysis,
    this.type,
    this.question,
    this.questionNumber,
    this.totalQuestions,
    this.progress,
    this.primaryDiagnosis,
    this.possibleConditions,
    this.urgencyLevel,
    this.recommendedActions,
    this.redFlags,
    this.whenToSeekHelp,
    this.medicalResearch,
    this.isComplete,
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
      type: json['type'],
      question: json['question'],
      questionNumber: json['questionNumber'],
      totalQuestions: json['totalQuestions'],
      progress: json['progress'],
      primaryDiagnosis: json['primaryDiagnosis'],
      possibleConditions: json['possibleConditions'] != null 
          ? List<String>.from(json['possibleConditions'])
          : null,
      urgencyLevel: json['urgencyLevel'],
      recommendedActions: json['recommendedActions'] != null
          ? List<String>.from(json['recommendedActions'])
          : null,
      redFlags: json['redFlags'] != null
          ? List<String>.from(json['redFlags'])
          : null,
      whenToSeekHelp: json['whenToSeekHelp'],
      medicalResearch: json['medicalResearch'],
      isComplete: json['isComplete'],
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
