import 'family_models.dart';
import 'dart:convert';

enum LabTestType {
  bloodTest,
  bloodSugar,
  lipidProfile,
  immunology,
  urine,
  other,
}

enum LabResultStatus {
  pending,
  ready,
  reviewed,
}

enum LabItemStatus {
  normal,
  high,
  low,
  critical,
}

class FamilyLabResult {
  final String id;
  final String memberName;
  final FamilyRelation memberRelation;
  final DateTime testDate;
  final DateTime resultDate;
  final String hospital;
  final String doctorName;
  final LabTestType testType;
  final String testName;
  final LabResultStatus status;
  bool isNew;
  final List<LabTestItem> results;
  final String notes;

  FamilyLabResult({
    required this.id,
    required this.memberName,
    required this.memberRelation,
    required this.testDate,
    required this.resultDate,
    required this.hospital,
    required this.doctorName,
    required this.testType,
    required this.testName,
    required this.status,
    this.isNew = false,
    required this.results,
    this.notes = '',
  });
}

class LabTestItem {
  final String name;
  final String value;
  final String unit;
  final String normalRange;
  final LabItemStatus status;

  LabTestItem({
    required this.name,
    required this.value,
    required this.unit,
    required this.normalRange,
    required this.status,
  });
}

class LabResult {
  final String id;
  final String userId;
  final String? medicalRecordId;
  final String testName;
  final String testType;
  final String? category;
  final Map<String, dynamic> results;
  final Map<String, dynamic>? normalRange;
  final bool? isNormal;
  final bool isCritical;
  final String? doctorNotes;
  final DateTime testDate;
  final DateTime? resultDate;
  final bool isNew;
  final String? reportUrl;
  final DateTime createdAt;

  LabResult({
    required this.id,
    required this.userId,
    this.medicalRecordId,
    required this.testName,
    required this.testType,
    this.category,
    required this.results,
    this.normalRange,
    this.isNormal,
    required this.isCritical,
    this.doctorNotes,
    required this.testDate,
    this.resultDate,
    required this.isNew,
    this.reportUrl,
    required this.createdAt,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      id: json['id'],
      userId: json['userId'],
      medicalRecordId: json['medicalRecordId'],
      testName: json['testName'],
      testType: json['testType'],
      category: json['category'],
      results: json['results'] is String
          ? jsonDecode(json['results'])
          : json['results'],
      normalRange: json['normalRange'] != null
          ? (json['normalRange'] is String
              ? jsonDecode(json['normalRange'])
              : json['normalRange'])
          : null,
      isNormal: json['isNormal'],
      isCritical: json['isCritical'] ?? false,
      doctorNotes: json['doctorNotes'],
      testDate: DateTime.parse(json['testDate']),
      resultDate: json['resultDate'] != null
          ? DateTime.parse(json['resultDate'])
          : null,
      isNew: json['isNew'] ?? false,
      reportUrl: json['reportUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MedicalRecord {
  final String id;
  final String userId;
  final String doctorId;
  final String? consultationId;
  final DateTime visitDate;
  final String? queueNumber;
  final String diagnosis;
  final String treatment;
  final Map<String, dynamic>? symptoms;
  final Map<String, dynamic>? vitalSigns;
  final Map<String, dynamic>? medications;
  final DateTime? followUpDate;
  final double? totalCost;
  final String paymentStatus;
  final String paymentMethod;
  final String? notes;
  final DoctorInfo doctor;

  MedicalRecord({
    required this.id,
    required this.userId,
    required this.doctorId,
    this.consultationId,
    required this.visitDate,
    this.queueNumber,
    required this.diagnosis,
    required this.treatment,
    this.symptoms,
    this.vitalSigns,
    this.medications,
    this.followUpDate,
    this.totalCost,
    required this.paymentStatus,
    required this.paymentMethod,
    this.notes,
    required this.doctor,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      userId: json['userId'],
      doctorId: json['doctorId'],
      consultationId: json['consultationId'],
      visitDate: DateTime.parse(json['visitDate']),
      queueNumber: json['queueNumber'],
      diagnosis: json['diagnosis'],
      treatment: json['treatment'],
      symptoms: json['symptoms'] is String
          ? jsonDecode(json['symptoms'])
          : json['symptoms'],
      vitalSigns: json['vitalSigns'] is String
          ? jsonDecode(json['vitalSigns'])
          : json['vitalSigns'],
      medications: json['medications'] is String
          ? jsonDecode(json['medications'])
          : json['medications'],
      followUpDate: json['followUpDate'] != null
          ? DateTime.parse(json['followUpDate'])
          : null,
      totalCost: json['totalCost']?.toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      notes: json['notes'],
      doctor: DoctorInfo.fromJson(json['doctor']),
    );
  }
}

class DoctorInfo {
  final String id;
  final String name;
  final String specialty;

  DoctorInfo({
    required this.id,
    required this.name,
    required this.specialty,
  });

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
    );
  }
}
