import 'family_models.dart';

enum PaymentMethod {
  cash,
  bpjs,
  insurance,
  creditCard,
}

enum PaymentStatus {
  paid,
  pending,
  failed,
}

enum DocumentType {
  medicalCertificate,
  labResult,
  prescription,
  referralLetter,
  xrayResult,
}

class MedicalDocument {
  final String id;
  final String name;
  final DocumentType type;
  final String url;

  MedicalDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
  });
}

class MedicalRecord {
  final String id;
  final DateTime visitDate;
  final String doctorName;
  final String specialty;
  final String hospital;
  final String diagnosis;
  final String treatment;
  final List<String> prescription;
  final int totalCost;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String notes;
  final List<MedicalDocument> documents;
  final String queueNumber;

  MedicalRecord({
    required this.id,
    required this.visitDate,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.diagnosis,
    required this.treatment,
    required this.prescription,
    required this.totalCost,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.notes,
    required this.documents,
    required this.queueNumber,
  });
}

enum MedicalRecordType {
  consultation,
  checkup,
  vaccination,
  emergency,
  surgery,
}

class FamilyMedicalRecord {
  final String id;
  final String memberName;
  final FamilyRelation memberRelation;
  final DateTime date;
  final MedicalRecordType type;
  final String doctorName;
  final String hospital;
  final String diagnosis;
  final String treatment;
  final String notes;
  final DateTime? nextCheckup;

  FamilyMedicalRecord({
    required this.id,
    required this.memberName,
    required this.memberRelation,
    required this.date,
    required this.type,
    required this.doctorName,
    required this.hospital,
    required this.diagnosis,
    required this.treatment,
    this.notes = '',
    this.nextCheckup,
  });
}
