import 'dart:convert';

enum PaymentStatus {
  PENDING,
  PAID,
  FAILED,
  CANCELLED,
}

enum PaymentMethod {
  CASH,
  CREDIT_CARD,
  DEBIT_CARD,
  BANK_TRANSFER,
  E_WALLET,
  BPJS,
  INSURANCE,
}

class DigitalPrescription {
  final String id;
  final String userId;
  final String doctorId;
  final String? consultationId;
  final String? queueId;
  final String prescriptionCode;
  final String diagnosis;
  final List<PrescriptionMedication> medications;
  final String instructions;
  final double? totalAmount;
  final bool isPaid;
  final DateTime? paidAt;
  final PaymentStatus paymentStatus;
  final PaymentMethod? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PrescriptionDoctor doctor;
  final PaymentInfo? paymentInfo;
  final bool isDispensed; // ✅ ADD: Missing property
  final DateTime? dispensedAt;

  DigitalPrescription({
    required this.id,
    required this.userId,
    required this.doctorId,
    this.consultationId,
    this.queueId,
    required this.prescriptionCode,
    required this.diagnosis,
    required this.medications,
    required this.instructions,
    this.totalAmount,
    required this.isPaid,
    this.paidAt,
    required this.paymentStatus,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.doctor,
    this.paymentInfo,
    this.isDispensed = false, // ✅ ADD: Default value
    this.dispensedAt,
  });

  // ✅ ADD: Missing computed property
  bool get isNew {
    final now = DateTime.now();
    final daysDifference = now.difference(createdAt).inDays;
    return daysDifference <= 3 &&
        !isPaid; // New if created within 3 days and not paid
  }

  // ✅ ENHANCED: Ultra-safe JSON parsing with detailed error handling
  factory DigitalPrescription.fromJson(Map<String, dynamic> json) {
    print('🔍 === PARSING PRESCRIPTION ===');
    print('📊 Prescription ID: ${json['id']}');
    print('📊 JSON keys: ${json.keys.toList()}');

    try {
      // ✅ SAFE: Parse doctor info
      PrescriptionDoctor doctor;
      try {
        final doctorData = json['doctor'];
        if (doctorData is Map<String, dynamic>) {
          doctor = PrescriptionDoctor.fromJson(doctorData);
        } else {
          doctor = PrescriptionDoctor(
            id: json['doctorId']?.toString() ?? 'unknown',
            name: 'Dokter Tidak Diketahui',
            specialty: 'Umum',
          );
        }
      } catch (e) {
        print('❌ Error parsing doctor: $e');
        doctor = PrescriptionDoctor(
          id: json['doctorId']?.toString() ?? 'unknown',
          name: 'Dokter Tidak Diketahui',
          specialty: 'Umum',
        );
      }

      // ✅ FIXED: Parse REAL medications WITHOUT fallback
      List<PrescriptionMedication> medications = [];
      try {
        final medicationsData = json['medications'];
        print('🔍 Medications data type: ${medicationsData.runtimeType}');
        print('🔍 Medications data: $medicationsData');

        if (medicationsData != null) {
          if (medicationsData is String) {
            final parsed = jsonDecode(medicationsData);
            if (parsed is List) {
              medications = _parseMedicationsList(parsed);
            }
          } else if (medicationsData is List) {
            medications = _parseMedicationsList(medicationsData);
          }
        }

        print('✅ Parsed ${medications.length} medications');

        // Log each medication for debugging
        for (int i = 0; i < medications.length; i++) {
          print(
              '  Medication ${i + 1}: ${medications[i].genericName} - ${medications[i].dosage}');
        }
      } catch (e) {
        print('❌ Error parsing medications: $e');
        // ✅ REMOVED: No fallback medications - leave empty if error
        medications = [];
      }

      // ✅ SAFE: Parse total amount
      double? totalAmount;
      try {
        final amountData = json['totalAmount'];
        if (amountData != null) {
          if (amountData is double) {
            totalAmount = amountData;
          } else if (amountData is int) {
            totalAmount = amountData.toDouble();
          } else if (amountData is String) {
            totalAmount = double.tryParse(amountData);
          }
        }
      } catch (e) {
        print('❌ Error parsing total amount: $e');
        totalAmount = null;
      }

      // ✅ SAFE: Parse payment info
      PaymentInfo? paymentInfo;
      try {
        final paymentData = json['paymentInfo'] ?? json['transaction'];
        if (paymentData is Map<String, dynamic>) {
          paymentInfo = PaymentInfo.fromJson(paymentData);
        }
      } catch (e) {
        print('❌ Error parsing payment info: $e');
        paymentInfo = null;
      }

      final prescription = DigitalPrescription(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        doctorId: json['doctorId']?.toString() ?? '',
        consultationId: json['consultationId']?.toString(),
        queueId: json['queueId']?.toString(),
        prescriptionCode: json['prescriptionCode']?.toString() ?? 'N/A',
        diagnosis: json['diagnosis']?.toString() ?? '',
        medications: medications, // ✅ REAL medications from DB
        instructions: json['instructions']?.toString() ?? '',
        totalAmount: totalAmount,
        isPaid: json['isPaid'] == true,
        paidAt: json['paidAt'] != null
            ? DateTime.tryParse(json['paidAt'].toString())
            : null,
        paymentStatus: _parsePaymentStatus(json['paymentStatus']),
        paymentMethod: _parsePaymentMethod(json['paymentMethod']),
        notes: json['notes']?.toString(),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
        doctor: doctor,
        paymentInfo: paymentInfo,
        isDispensed: json['isDispensed'] == true || json['isCollected'] == true,
        dispensedAt: json['dispensedAt'] != null
            ? DateTime.tryParse(json['dispensedAt'].toString())
            : null,
      );

      print(
          '✅ Prescription parsed successfully: ${prescription.prescriptionCode} with ${prescription.medications.length} medications');
      return prescription;
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR parsing prescription: $e');
      print('📥 Stack trace: $stackTrace');

      // ✅ MINIMAL fallback - but with empty medications
      return DigitalPrescription(
        id: json['id']?.toString() ??
            'error-${DateTime.now().millisecondsSinceEpoch}',
        userId: json['userId']?.toString() ?? '',
        doctorId: json['doctorId']?.toString() ?? '',
        prescriptionCode: json['prescriptionCode']?.toString() ?? 'ERROR',
        diagnosis: 'Error parsing prescription',
        medications: [], // ✅ Empty, not fallback
        instructions: 'Hubungi rumah sakit untuk informasi lebih lanjut',
        totalAmount: 0.0,
        isPaid: false,
        paymentStatus: PaymentStatus.PENDING,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        doctor: PrescriptionDoctor(
          id: 'unknown',
          name: 'Error',
          specialty: 'Error',
        ),
      );
    }
  }

  // ✅ ENHANCED: Parse medications list with better error handling
  static List<PrescriptionMedication> _parseMedicationsList(
      List<dynamic> medicationsData) {
    final List<PrescriptionMedication> medications = [];

    print('🔍 Parsing ${medicationsData.length} medications from list');

    for (int i = 0; i < medicationsData.length; i++) {
      try {
        final medData = medicationsData[i];
        print('🔍 Processing medication $i: ${medData.runtimeType}');

        if (medData is Map<String, dynamic>) {
          final medication = PrescriptionMedication.fromJson(medData);
          medications.add(medication);
          print('✅ Added medication: ${medication.genericName}');
        } else if (medData is Map) {
          final medication = PrescriptionMedication.fromJson(
              Map<String, dynamic>.from(medData));
          medications.add(medication);
          print('✅ Added medication: ${medication.genericName}');
        } else {
          print(
              '⚠️ Invalid medication data at index $i: ${medData.runtimeType}');
        }
      } catch (e) {
        print('❌ Error parsing medication at index $i: $e');
        // ✅ SKIP invalid medication instead of adding fallback
      }
    }

    print('✅ Successfully parsed ${medications.length} medications');
    return medications;
  }

  static PaymentStatus _parsePaymentStatus(dynamic status) {
    if (status == null) return PaymentStatus.PENDING;

    switch (status.toString().toUpperCase()) {
      case 'PAID':
        return PaymentStatus.PAID;
      case 'PENDING':
        return PaymentStatus.PENDING;
      case 'FAILED':
        return PaymentStatus.FAILED;
      case 'CANCELLED':
        return PaymentStatus.CANCELLED;
      default:
        return PaymentStatus.PENDING;
    }
  }

  static PaymentMethod? _parsePaymentMethod(dynamic method) {
    if (method == null) return null;

    switch (method.toString().toUpperCase()) {
      case 'CASH':
        return PaymentMethod.CASH;
      case 'CREDIT_CARD':
        return PaymentMethod.CREDIT_CARD;
      case 'DEBIT_CARD':
        return PaymentMethod.DEBIT_CARD;
      case 'BANK_TRANSFER':
        return PaymentMethod.BANK_TRANSFER;
      case 'E_WALLET':
        return PaymentMethod.E_WALLET;
      case 'BPJS':
        return PaymentMethod.BPJS;
      case 'INSURANCE':
        return PaymentMethod.INSURANCE;
      default:
        return PaymentMethod.CASH;
    }
  }

  String get formattedTotalAmount {
    if (totalAmount == null || totalAmount == 0) return 'Gratis';
    return 'Rp ${totalAmount!.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String get statusText {
    if (isPaid) return 'Sudah Dibayar';

    switch (paymentStatus) {
      case PaymentStatus.PENDING:
        return 'Menunggu Pembayaran';
      case PaymentStatus.PAID:
        return 'Sudah Dibayar';
      case PaymentStatus.FAILED:
        return 'Pembayaran Gagal';
      case PaymentStatus.CANCELLED:
        return 'Dibatalkan';
    }
  }
}

class PrescriptionMedication {
  final String medicationId;
  final String genericName;
  final String? brandName;
  final String dosage;
  final String frequency;
  final int duration;
  final String instructions;
  final int quantity;
  final double? price;
  final String? notes;
  final String unit; // ✅ ADD: Missing property
  final double? totalPrice; // ✅ ADD: Missing property

  PrescriptionMedication({
    required this.medicationId,
    required this.genericName,
    this.brandName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
    required this.quantity,
    this.price,
    this.notes,
    this.unit = 'tablet', // ✅ ADD: Default unit
    this.totalPrice,
  });

  // ✅ ADD: Missing computed property
  int get durationDays => duration;

  factory PrescriptionMedication.fromJson(Map<String, dynamic> json) {
    try {
      final quantity = int.tryParse(json['quantity']?.toString() ?? '1') ?? 1;
      final price = json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null;
      final totalPrice = price != null ? price * quantity : null;

      return PrescriptionMedication(
        medicationId: json['medicationId']?.toString() ??
            json['id']?.toString() ??
            'unknown',
        genericName: json['genericName']?.toString() ??
            json['name']?.toString() ??
            'Obat tidak diketahui',
        brandName: json['brandName']?.toString(),
        dosage: json['dosage']?.toString() ?? 'Sesuai instruksi',
        frequency: json['frequency']?.toString() ?? '1x sehari',
        duration: int.tryParse(json['duration']?.toString() ?? '7') ?? 7,
        instructions:
            json['instructions']?.toString() ?? 'Ikuti petunjuk dokter',
        quantity: quantity,
        price: price,
        notes: json['notes']?.toString(),
        unit: json['unit']?.toString() ?? 'tablet', // ✅ ADD: Parse unit
        totalPrice: totalPrice, // ✅ ADD: Calculate total price
      );
    } catch (e) {
      print('❌ Error parsing medication: $e');
      return PrescriptionMedication(
        medicationId: 'error',
        genericName: 'Error parsing medication',
        dosage: 'N/A',
        frequency: 'N/A',
        duration: 0,
        instructions: 'Hubungi dokter',
        quantity: 0,
        unit: 'tablet',
        totalPrice: 0.0,
      );
    }
  }
}

class PrescriptionDoctor {
  final String id;
  final String name;
  final String specialty;

  PrescriptionDoctor({
    required this.id,
    required this.name,
    required this.specialty,
  });

  factory PrescriptionDoctor.fromJson(Map<String, dynamic> json) {
    return PrescriptionDoctor(
      id: json['id']?.toString() ?? 'unknown',
      name: json['name']?.toString() ?? 'Dokter Tidak Diketahui',
      specialty: json['specialty']?.toString() ?? 'Umum',
    );
  }
}

class PaymentInfo {
  final String transactionId;
  final String status;
  final double paidAmount;
  final String paymentMethod;
  final DateTime paidAt;

  PaymentInfo({
    required this.transactionId,
    required this.status,
    required this.paidAmount,
    required this.paymentMethod,
    required this.paidAt,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      transactionId:
          json['transactionId']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      paidAmount: double.tryParse(json['paidAmount']?.toString() ??
              json['amount']?.toString() ??
              '0') ??
          0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'UNKNOWN',
      paidAt:
          DateTime.tryParse(json['paidAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
