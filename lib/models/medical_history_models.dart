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

enum HistoryType {
  medicalRecord,
  consultation,
  queue,
  prescription,
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

  factory MedicalDocument.fromJson(Map<String, dynamic> json) {
    return MedicalDocument(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: _parseDocumentType(json['type']),
      url: json['url'] ?? '',
    );
  }

  static DocumentType _parseDocumentType(String? type) {
    switch (type?.toLowerCase()) {
      case 'medical_certificate':
        return DocumentType.medicalCertificate;
      case 'lab_result':
        return DocumentType.labResult;
      case 'prescription':
        return DocumentType.prescription;
      case 'referral_letter':
        return DocumentType.referralLetter;
      case 'xray_result':
        return DocumentType.xrayResult;
      default:
        return DocumentType.medicalCertificate;
    }
  }
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

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] ?? '',
      visitDate: DateTime.parse(json['visitDate'] ?? json['createdAt']),
      doctorName: json['doctor']?['name'] ??
          json['doctorName'] ??
          'Dr. Tidak Diketahui',
      specialty: json['doctor']?['specialty'] ?? json['specialty'] ?? 'Umum',
      hospital: 'RS Mitra Keluarga', // Static for now
      diagnosis: json['diagnosis'] ?? '',
      treatment: json['treatment'] ?? '',
      prescription: _parsePrescription(json['medications']),
      totalCost: (json['totalCost'] ?? 0).toInt(),
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      notes: json['notes'] ?? '',
      documents: _parseDocuments(json['documents']),
      queueNumber: json['queueNumber'] ?? '',
    );
  }

  static List<String> _parsePrescription(dynamic medications) {
    if (medications == null) return [];
    if (medications is List) {
      return medications.map((med) => med.toString()).toList();
    }
    if (medications is Map) {
      return [medications.toString()];
    }
    return [];
  }

  static PaymentMethod _parsePaymentMethod(String? method) {
    switch (method?.toUpperCase()) {
      case 'CASH':
        return PaymentMethod.cash;
      case 'BPJS':
        return PaymentMethod.bpjs;
      case 'INSURANCE':
        return PaymentMethod.insurance;
      case 'CREDIT_CARD':
        return PaymentMethod.creditCard;
      default:
        return PaymentMethod.cash;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PAID':
        return PaymentStatus.paid;
      case 'PENDING':
        return PaymentStatus.pending;
      case 'FAILED':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }

  static List<MedicalDocument> _parseDocuments(dynamic documents) {
    if (documents == null || documents is! List) return [];
    return documents
        .map((doc) => MedicalDocument.fromJson(doc as Map<String, dynamic>))
        .toList();
  }
}

// New models for different types of history
class ConsultationHistory {
  final String id;
  final DateTime date;
  final String type; // 'AI' or 'DOCTOR'
  final String doctorName;
  final String status;
  final String summary;
  final double? fee;
  final PaymentStatus paymentStatus;

  ConsultationHistory({
    required this.id,
    required this.date,
    required this.type,
    required this.doctorName,
    required this.status,
    required this.summary,
    this.fee,
    required this.paymentStatus,
  });

  factory ConsultationHistory.fromJson(Map<String, dynamic> json) {
    try {
      return ConsultationHistory(
        id: json['id']?.toString() ?? '',
        date: _parseDate(json['createdAt']) ?? DateTime.now(),
        type: json['type']?.toString() ?? 'AI',
        doctorName: _parseDoctorName(json),
        status: _parseStatus(json['isCompleted']),
        summary: _generateSummary(json),
        fee: _parseFee(json['consultationFee']),
        paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      );
    } catch (e) {
      print('❌ Error parsing ConsultationHistory: $e');
      // Return default object if parsing fails
      return ConsultationHistory(
        id: json['id']?.toString() ?? 'unknown',
        date: DateTime.now(),
        type: 'AI',
        doctorName: 'AI Assistant',
        status: 'Tidak Diketahui',
        summary: 'Konsultasi AI',
        fee: null,
        paymentStatus: PaymentStatus.pending,
      );
    }
  }

  static DateTime? _parseDate(dynamic dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      print('❌ Error parsing date: $e');
      return DateTime.now();
    }
  }

  static String _parseDoctorName(Map<String, dynamic> json) {
    // Try multiple sources for doctor name
    if (json['doctor'] != null && json['doctor']['name'] != null) {
      return json['doctor']['name'].toString();
    }
    if (json['doctorName'] != null) {
      return json['doctorName'].toString();
    }
    if (json['type'] == 'AI') {
      return 'AI Assistant';
    }
    return 'Dokter Tidak Diketahui';
  }

  static String _parseStatus(dynamic isCompleted) {
    if (isCompleted == true || isCompleted == 'true') {
      return 'Selesai';
    }
    return 'Berlangsung';
  }

  static double? _parseFee(dynamic fee) {
    if (fee == null) return null;
    try {
      return double.parse(fee.toString());
    } catch (e) {
      return null;
    }
  }

  static PaymentStatus _parsePaymentStatus(dynamic status) {
    if (status == null) return PaymentStatus.pending;

    switch (status.toString().toUpperCase()) {
      case 'PAID':
        return PaymentStatus.paid;
      case 'PENDING':
        return PaymentStatus.pending;
      case 'FAILED':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }

  static String _generateSummary(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'AI') {
        final aiAnalysis = json['aiAnalysis'];
        if (aiAnalysis != null && aiAnalysis['primaryDiagnosis'] != null) {
          return aiAnalysis['primaryDiagnosis'].toString();
        }
        final symptoms = json['symptoms'];
        if (symptoms is List && symptoms.isNotEmpty) {
          return 'Konsultasi AI - ${symptoms.join(', ')}';
        }
        return 'Konsultasi AI';
      } else {
        return json['doctorNotes']?.toString() ?? 'Konsultasi dengan dokter';
      }
    } catch (e) {
      print('❌ Error generating summary: $e');
      return 'Konsultasi';
    }
  }
}

class QueueHistory {
  final String id;
  final DateTime date;
  final String queueNumber;
  final String doctorName;
  final String specialty;
  final String status;
  final DateTime? checkInTime;
  final DateTime? completedTime;
  final int? waitTime; // in minutes

  QueueHistory({
    required this.id,
    required this.date,
    required this.queueNumber,
    required this.doctorName,
    required this.specialty,
    required this.status,
    this.checkInTime,
    this.completedTime,
    this.waitTime,
  });

  factory QueueHistory.fromJson(Map<String, dynamic> json) {
    try {
      final checkIn = _parseDateTime(json['checkInTime']);
      final completed = _parseDateTime(json['completedTime']);

      int? calculatedWaitTime;
      if (checkIn != null && completed != null) {
        calculatedWaitTime = completed.difference(checkIn).inMinutes;
      }

      return QueueHistory(
        id: json['id']?.toString() ?? '',
        date: _parseDateTime(json['queueDate']) ??
            _parseDateTime(json['createdAt']) ??
            DateTime.now(),
        queueNumber: json['queueNumber']?.toString() ?? 'N/A',
        doctorName: _parseDoctorName(json),
        specialty: _parseSpecialty(json),
        status: _parseQueueStatus(json['status']),
        checkInTime: checkIn,
        completedTime: completed,
        waitTime: calculatedWaitTime,
      );
    } catch (e) {
      print('❌ Error parsing QueueHistory: $e');
      return QueueHistory(
        id: json['id']?.toString() ?? 'unknown',
        date: DateTime.now(),
        queueNumber: 'N/A',
        doctorName: 'Dokter Tidak Diketahui',
        specialty: 'Umum',
        status: 'Tidak Diketahui',
      );
    }
  }

  static DateTime? _parseDateTime(dynamic dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return null;
    }
  }

  static String _parseDoctorName(Map<String, dynamic> json) {
    if (json['doctor'] != null && json['doctor']['name'] != null) {
      return json['doctor']['name'].toString();
    }
    return 'Dokter Tidak Diketahui';
  }

  static String _parseSpecialty(Map<String, dynamic> json) {
    if (json['doctor'] != null && json['doctor']['specialty'] != null) {
      return json['doctor']['specialty'].toString();
    }
    return 'Umum';
  }

  static String _parseQueueStatus(dynamic status) {
    if (status == null) return 'Tidak Diketahui';

    switch (status.toString().toUpperCase()) {
      case 'WAITING':
        return 'Menunggu';
      case 'CALLED':
        return 'Dipanggil';
      case 'IN_PROGRESS':
        return 'Berlangsung';
      case 'COMPLETED':
        return 'Selesai';
      case 'CANCELLED':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }
}

class PrescriptionHistory {
  final String id;
  final DateTime date;
  final String prescriptionCode;
  final String doctorName;
  final List<String> medications;
  final double totalAmount;
  final PaymentStatus paymentStatus;
  final bool isDispensed;
  final DateTime? dispensedAt;

  PrescriptionHistory({
    required this.id,
    required this.date,
    required this.prescriptionCode,
    required this.doctorName,
    required this.medications,
    required this.totalAmount,
    required this.paymentStatus,
    required this.isDispensed,
    this.dispensedAt,
  });

  factory PrescriptionHistory.fromJson(Map<String, dynamic> json) {
    try {
      return PrescriptionHistory(
        id: json['id']?.toString() ?? '',
        date: _parseDateTime(json['createdAt']) ?? DateTime.now(),
        prescriptionCode: json['prescriptionCode']?.toString() ?? 'N/A',
        doctorName: _parseDoctorName(json),
        medications: _parseMedications(json['medications']),
        totalAmount: _parseAmount(json['totalAmount']),
        paymentStatus: _parsePaymentStatus(json['paymentStatus']),
        isDispensed: json['isDispensed'] == true,
        dispensedAt: _parseDateTime(json['dispensedAt']),
      );
    } catch (e) {
      print('❌ Error parsing PrescriptionHistory: $e');
      return PrescriptionHistory(
        id: json['id']?.toString() ?? 'unknown',
        date: DateTime.now(),
        prescriptionCode: 'N/A',
        doctorName: 'Dokter Tidak Diketahui',
        medications: ['Obat tidak diketahui'],
        totalAmount: 0.0,
        paymentStatus: PaymentStatus.pending,
        isDispensed: false,
      );
    }
  }

  static DateTime? _parseDateTime(dynamic dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return null;
    }
  }

  static String _parseDoctorName(Map<String, dynamic> json) {
    if (json['doctor'] != null && json['doctor']['name'] != null) {
      return json['doctor']['name'].toString();
    }
    return 'Dokter Tidak Diketahui';
  }

  static double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0;
    try {
      return double.parse(amount.toString());
    } catch (e) {
      return 0.0;
    }
  }

  static PaymentStatus _parsePaymentStatus(dynamic status) {
    if (status == null) return PaymentStatus.pending;

    switch (status.toString().toUpperCase()) {
      case 'PAID':
        return PaymentStatus.paid;
      case 'PENDING':
        return PaymentStatus.pending;
      case 'FAILED':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }

  static List<String> _parseMedications(dynamic medications) {
    if (medications == null) return ['Obat tidak diketahui'];

    try {
      if (medications is List) {
        return medications.map((med) {
          if (med is Map) {
            final name = med['name']?.toString() ?? 'Obat';
            final dosage = med['dosage']?.toString() ?? '';
            return dosage.isNotEmpty ? '$name - $dosage' : name;
          }
          return med.toString();
        }).toList();
      }
      return [medications.toString()];
    } catch (e) {
      print('❌ Error parsing medications: $e');
      return ['Obat tidak diketahui'];
    }
  }
}

// Combined history item for unified display
class MedicalHistoryItem {
  final String id;
  final DateTime date;
  final HistoryType type;
  final String title;
  final String subtitle;
  final String status;
  final Map<String, dynamic> data;

  MedicalHistoryItem({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.data,
  });

  // Factory constructors for different types
  factory MedicalHistoryItem.fromMedicalRecord(MedicalRecord record) {
    return MedicalHistoryItem(
      id: record.id,
      date: record.visitDate,
      type: HistoryType.medicalRecord,
      title: record.diagnosis,
      subtitle: '${record.doctorName} • ${record.specialty}',
      status:
          record.paymentStatus == PaymentStatus.paid ? 'Lunas' : 'Belum Lunas',
      data: {
        'medicalRecord': record,
      },
    );
  }

  factory MedicalHistoryItem.fromConsultation(
      ConsultationHistory consultation) {
    return MedicalHistoryItem(
      id: consultation.id,
      date: consultation.date,
      type: HistoryType.consultation,
      title: consultation.summary,
      subtitle:
          '${consultation.doctorName} • ${consultation.type} Consultation',
      status: consultation.status,
      data: {
        'consultation': consultation,
      },
    );
  }

  factory MedicalHistoryItem.fromQueue(QueueHistory queue) {
    return MedicalHistoryItem(
      id: queue.id,
      date: queue.date,
      type: HistoryType.queue,
      title: 'Antrean ${queue.queueNumber}',
      subtitle: '${queue.doctorName} • ${queue.specialty}',
      status: queue.status,
      data: {
        'queue': queue,
        'waitTime': queue.waitTime,
      },
    );
  }

  factory MedicalHistoryItem.fromPrescription(
      PrescriptionHistory prescription) {
    return MedicalHistoryItem(
      id: prescription.id,
      date: prescription.date,
      type: HistoryType.prescription,
      title: 'Resep ${prescription.prescriptionCode}',
      subtitle:
          '${prescription.doctorName} • ${prescription.medications.length} obat',
      status: prescription.isDispensed ? 'Sudah Diambil' : 'Belum Diambil',
      data: {
        'prescription': prescription,
      },
    );
  }
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
