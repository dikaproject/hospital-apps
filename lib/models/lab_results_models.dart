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

  // ✅ ENHANCED: Ultra-safe JSON parsing
  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    print('🔍 === PARSING MEDICAL RECORD ===');
    print('📊 JSON keys: ${json.keys.toList()}');

    try {
      // ✅ SAFE: Parse doctor info
      DoctorInfo doctor;
      try {
        final doctorData = json['doctor'];
        print('🔍 Doctor data type: ${doctorData.runtimeType}');
        print('🔍 Doctor data: $doctorData');

        if (doctorData is Map<String, dynamic>) {
          doctor = DoctorInfo.fromJson(doctorData);
        } else {
          print('⚠️ Doctor data is not a map, using fallback');
          doctor = DoctorInfo(
            id: json['doctorId']?.toString() ?? 'unknown',
            name: 'Dokter Tidak Diketahui',
            specialty: 'Umum',
          );
        }
      } catch (e) {
        print('❌ Error parsing doctor: $e');
        doctor = DoctorInfo(
          id: json['doctorId']?.toString() ?? 'unknown',
          name: 'Dokter Tidak Diketahui',
          specialty: 'Umum',
        );
      }

      // ✅ SAFE: Parse JSON strings or objects
      Map<String, dynamic>? symptoms;
      try {
        final symptomsData = json['symptoms'];
        if (symptomsData != null) {
          if (symptomsData is String) {
            symptoms = jsonDecode(symptomsData);
          } else if (symptomsData is Map<String, dynamic>) {
            symptoms = symptomsData;
          } else if (symptomsData is Map) {
            symptoms = Map<String, dynamic>.from(symptomsData);
          }
        }
      } catch (e) {
        print('❌ Error parsing symptoms: $e');
        symptoms = null;
      }

      Map<String, dynamic>? vitalSigns;
      try {
        final vitalData = json['vitalSigns'];
        if (vitalData != null) {
          if (vitalData is String) {
            vitalSigns = jsonDecode(vitalData);
          } else if (vitalData is Map<String, dynamic>) {
            vitalSigns = vitalData;
          } else if (vitalData is Map) {
            vitalSigns = Map<String, dynamic>.from(vitalData);
          }
        }
      } catch (e) {
        print('❌ Error parsing vital signs: $e');
        vitalSigns = null;
      }

      Map<String, dynamic>? medications;
      try {
        final medicationsData = json['medications'];
        if (medicationsData != null) {
          if (medicationsData is String) {
            medications = jsonDecode(medicationsData);
          } else if (medicationsData is Map<String, dynamic>) {
            medications = medicationsData;
          } else if (medicationsData is Map) {
            medications = Map<String, dynamic>.from(medicationsData);
          } else if (medicationsData is List) {
            // ✅ FIX: Handle List as medications
            medications = {'medications': medicationsData};
          }
        }
      } catch (e) {
        print('❌ Error parsing medications: $e');
        medications = null;
      }

      final record = MedicalRecord(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        doctorId: json['doctorId']?.toString() ?? '',
        consultationId: json['consultationId']?.toString(),
        visitDate: DateTime.tryParse(json['visitDate']?.toString() ?? '') ??
            DateTime.now(),
        queueNumber: json['queueNumber']?.toString(),
        diagnosis: json['diagnosis']?.toString() ?? 'Tidak ada diagnosis',
        treatment: json['treatment']?.toString() ?? 'Tidak ada treatment',
        symptoms: symptoms,
        vitalSigns: vitalSigns,
        medications: medications,
        followUpDate: json['followUpDate'] != null
            ? DateTime.tryParse(json['followUpDate'].toString())
            : null,
        totalCost: json['totalCost'] != null
            ? double.tryParse(json['totalCost'].toString())
            : null,
        paymentStatus: json['paymentStatus']?.toString() ?? 'PENDING',
        paymentMethod: json['paymentMethod']?.toString() ?? 'CASH',
        notes: json['notes']?.toString(),
        doctor: doctor,
      );

      print('✅ Medical record parsed successfully: ${record.diagnosis}');
      return record;
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR parsing medical record: $e');
      print('📥 Stack trace: $stackTrace');
      print('📥 JSON data: ${json.toString()}');

      // ✅ FALLBACK: Return minimal valid record
      return MedicalRecord(
        id: json['id']?.toString() ??
            'error-${DateTime.now().millisecondsSinceEpoch}',
        userId: json['userId']?.toString() ?? '',
        doctorId: json['doctorId']?.toString() ?? '',
        visitDate: DateTime.now(),
        diagnosis: 'Error parsing medical record',
        treatment: 'Hubungi rumah sakit untuk informasi lebih lanjut',
        paymentStatus: 'UNKNOWN',
        paymentMethod: 'UNKNOWN',
        doctor: DoctorInfo(
          id: 'unknown',
          name: 'Dokter Tidak Diketahui',
          specialty: 'Umum',
        ),
      );
    }
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
      id: json['id']?.toString() ?? 'unknown',
      name: json['name']?.toString() ?? 'Dokter Tidak Diketahui',
      specialty: json['specialty']?.toString() ?? 'Umum',
    );
  }
}
