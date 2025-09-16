import 'dart:convert';

class DigitalPrescription {
  final String id;
  final String userId;
  final String doctorId;
  final String? consultationId;
  final String? appointmentId;
  final String prescriptionCode;
  final List<PrescriptionMedication> medications;
  final String? instructions;
  final double? totalAmount;
  final String? pharmacyNotes;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final bool isPaid;
  final bool isDispensed;
  final DateTime? dispensedAt;
  final String? dispensedBy;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DoctorInfo doctor;
  final bool isNew;

  DigitalPrescription({
    required this.id,
    required this.userId,
    required this.doctorId,
    this.consultationId,
    this.appointmentId,
    required this.prescriptionCode,
    required this.medications,
    this.instructions,
    this.totalAmount,
    this.pharmacyNotes,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.isPaid,
    required this.isDispensed,
    this.dispensedAt,
    this.dispensedBy,
    this.expiresAt,
    required this.createdAt,
    required this.doctor,
    this.isNew = false,
  });

  factory DigitalPrescription.fromJson(Map<String, dynamic> json) {
    List<PrescriptionMedication> medicationList = [];

    if (json['medications'] != null) {
      var medicationsData = json['medications'];
      if (medicationsData is String) {
        medicationsData = jsonDecode(medicationsData);
      }

      if (medicationsData is List) {
        medicationList = medicationsData
            .map((med) => PrescriptionMedication.fromJson(med))
            .toList();
      }
    }

    return DigitalPrescription(
      id: json['id'],
      userId: json['userId'],
      doctorId: json['doctorId'],
      consultationId: json['consultationId'],
      appointmentId: json['appointmentId'],
      prescriptionCode: json['prescriptionCode'],
      medications: medicationList,
      instructions: json['instructions'],
      totalAmount: json['totalAmount']?.toDouble(),
      pharmacyNotes: json['pharmacyNotes'],
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == json['paymentStatus'].toUpperCase(),
        orElse: () => PaymentStatus.PENDING,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name.toUpperCase() == json['paymentMethod'].toUpperCase(),
        orElse: () => PaymentMethod.CASH,
      ),
      isPaid: json['isPaid'] ?? false,
      isDispensed: json['isDispensed'] ?? false,
      dispensedAt: json['dispensedAt'] != null
          ? DateTime.parse(json['dispensedAt'])
          : null,
      dispensedBy: json['dispensedBy'],
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      doctor: DoctorInfo.fromJson(json['doctor']),
      isNew: _isNewPrescription(json['createdAt']),
    );
  }

  static bool _isNewPrescription(String createdAtString) {
    final createdAt = DateTime.parse(createdAtString);
    final now = DateTime.now();
    final difference = now.difference(createdAt).inHours;
    return difference < 24; // New if less than 24 hours
  }
}

class PrescriptionMedication {
  final String medicationId;
  final String medicationCode;
  final String genericName;
  final String? brandName;
  final String dosageForm;
  final String strength;
  final String unit;
  final int quantity;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String instructions;
  final double pricePerUnit;
  final double totalPrice;
  final String? notes;

  PrescriptionMedication({
    required this.medicationId,
    required this.medicationCode,
    required this.genericName,
    this.brandName,
    required this.dosageForm,
    required this.strength,
    required this.unit,
    required this.quantity,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    required this.instructions,
    required this.pricePerUnit,
    required this.totalPrice,
    this.notes,
  });

  factory PrescriptionMedication.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedication(
      medicationId: json['medicationId'],
      medicationCode: json['medicationCode'],
      genericName: json['genericName'],
      brandName: json['brandName'],
      dosageForm: json['dosageForm'],
      strength: json['strength'],
      unit: json['unit'],
      quantity: json['quantity'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      durationDays: json['durationDays'],
      instructions: json['instructions'],
      pricePerUnit: json['pricePerUnit'].toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
      notes: json['notes'],
    );
  }
}

enum PaymentStatus { PENDING, PAID, FAILED }

enum PaymentMethod { CASH, BPJS, INSURANCE, CREDIT_CARD }

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
