enum TransactionType {
  PRESCRIPTION_PAYMENT,
  CONSULTATION_PAYMENT,
  APPOINTMENT_FEE,
}

enum TransactionStatus {
  PENDING,
  PAID,
  FAILED,
  CANCELLED,
  REFUNDED,
}

enum PaymentMethod {
  CASH,
  BPJS,
  INSURANCE,
  CREDIT_CARD,
  DEBIT_CARD,
  BANK_TRANSFER,
  E_WALLET,
}

class UserTransaction {
  final String id;
  final String userId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final PaymentMethod? paymentMethod;
  final String? description;
  final String? prescriptionId;
  final String? consultationId;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final Map<String, dynamic>? prescriptionData;
  final Map<String, dynamic>? consultationData;

  UserTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    this.paymentMethod,
    this.description,
    this.prescriptionId,
    this.consultationId,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
    this.prescriptionData,
    this.consultationData,
  });

  // Fix: Safe parsing with better error handling
  factory UserTransaction.fromJson(Map<String, dynamic> json) {
    return UserTransaction(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: _parseTransactionType(json['type']),
      status: _parseTransactionStatus(json['status']),
      amount: _parseDouble(json['amount']),
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      description: json['description']?.toString(),
      prescriptionId: json['prescriptionId']?.toString(),
      consultationId: json['consultationId']?.toString(),
      paidAt: _parseDateTime(json['paidAt']),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      prescriptionData: json['prescription'] as Map<String, dynamic>?,
      consultationData: json['consultation'] as Map<String, dynamic>?,
    );
  }

  static TransactionType _parseTransactionType(dynamic value) {
    if (value == null) return TransactionType.CONSULTATION_PAYMENT;
    try {
      return TransactionType.values.firstWhere(
        (e) => e.name == value.toString(),
        orElse: () => TransactionType.CONSULTATION_PAYMENT,
      );
    } catch (e) {
      return TransactionType.CONSULTATION_PAYMENT;
    }
  }

  static TransactionStatus _parseTransactionStatus(dynamic value) {
    if (value == null) return TransactionStatus.PENDING;
    try {
      return TransactionStatus.values.firstWhere(
        (e) => e.name == value.toString(),
        orElse: () => TransactionStatus.PENDING,
      );
    } catch (e) {
      return TransactionStatus.PENDING;
    }
  }

  static PaymentMethod? _parsePaymentMethod(dynamic value) {
    if (value == null) return null;
    try {
      return PaymentMethod.values.firstWhere(
        (e) => e.name == value.toString(),
        orElse: () => PaymentMethod.CASH,
      );
    } catch (e) {
      return PaymentMethod.CASH;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('Error parsing amount: $value');
        return 0.0;
      }
    }
    print('Unexpected amount type: ${value.runtimeType} = $value');
    return 0.0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date: $value');
        return null;
      }
    }
    return null;
  }

  String get typeDisplayName {
    switch (type) {
      case TransactionType.PRESCRIPTION_PAYMENT:
        return 'Pembayaran Resep';
      case TransactionType.CONSULTATION_PAYMENT:
        return 'Pembayaran Konsultasi';
      case TransactionType.APPOINTMENT_FEE:
        return 'Biaya Appointment';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TransactionStatus.PENDING:
        return 'Menunggu';
      case TransactionStatus.PAID:
        return 'Lunas';
      case TransactionStatus.FAILED:
        return 'Gagal';
      case TransactionStatus.CANCELLED:
        return 'Dibatalkan';
      case TransactionStatus.REFUNDED:
        return 'Dikembalikan';
    }
  }

  String get paymentMethodDisplayName {
    if (paymentMethod == null) return 'Belum Dibayar';

    switch (paymentMethod!) {
      case PaymentMethod.CASH:
        return 'Tunai';
      case PaymentMethod.BPJS:
        return 'BPJS';
      case PaymentMethod.INSURANCE:
        return 'Asuransi';
      case PaymentMethod.CREDIT_CARD:
        return 'Kartu Kredit';
      case PaymentMethod.DEBIT_CARD:
        return 'Kartu Debit';
      case PaymentMethod.BANK_TRANSFER:
        return 'Transfer Bank';
      case PaymentMethod.E_WALLET:
        return 'E-Wallet';
    }
  }

  String get formattedAmount {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String get relatedItemName {
    if (prescriptionData != null) {
      return 'Resep ${prescriptionData!['prescriptionCode'] ?? 'Unknown'}';
    } else if (consultationData != null) {
      final doctorName = consultationData!['doctor']?['name'] ?? 'Unknown';
      return 'Konsultasi dengan Dr. $doctorName';
    }
    return description ?? 'Pembayaran';
  }
}

class PendingPrescription {
  final String id;
  final String prescriptionCode;
  final double totalAmount;
  final String doctorName;
  final String specialty;
  final DateTime createdAt;

  PendingPrescription({
    required this.id,
    required this.prescriptionCode,
    required this.totalAmount,
    required this.doctorName,
    required this.specialty,
    required this.createdAt,
  });

  factory PendingPrescription.fromJson(Map<String, dynamic> json) {
    // Safe amount parsing
    double amount = 0.0;
    final amountValue = json['totalAmount'];
    if (amountValue is num) {
      amount = amountValue.toDouble();
    } else if (amountValue is String) {
      try {
        amount = double.parse(amountValue);
      } catch (e) {
        print('Error parsing prescription amount: $amountValue');
      }
    }

    return PendingPrescription(
      id: json['id']?.toString() ?? '',
      prescriptionCode: json['prescriptionCode']?.toString() ?? '',
      totalAmount: amount,
      doctorName: json['doctor']?['name']?.toString() ?? 'Unknown Doctor',
      specialty: json['doctor']?['specialty']?.toString() ?? 'General',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class PendingPayments {
  final List<PendingPrescription> prescriptions;
  final double totalAmount;

  PendingPayments({
    required this.prescriptions,
    required this.totalAmount,
  });

  factory PendingPayments.fromJson(Map<String, dynamic> json) {
    try {
      final prescriptionsList = json['prescriptions'] as List? ?? [];
      final prescriptions = prescriptionsList
          .map((item) => PendingPrescription.fromJson(item))
          .toList();

      // Safe total amount parsing
      double totalAmount = 0.0;
      final totalValue = json['totalAmount'];
      if (totalValue is num) {
        totalAmount = totalValue.toDouble();
      } else if (totalValue is String) {
        try {
          totalAmount = double.parse(totalValue);
        } catch (e) {
          print('Error parsing totalAmount: $totalValue');
        }
      }

      return PendingPayments(
        prescriptions: prescriptions,
        totalAmount: totalAmount,
      );
    } catch (e) {
      print('Error parsing PendingPayments: $e');
      return PendingPayments.empty();
    }
  }

  factory PendingPayments.empty() {
    return PendingPayments(
      prescriptions: [],
      totalAmount: 0.0,
    );
  }
}

class TransactionResult {
  final String transactionId;
  final String prescriptionId;
  final String status;
  final String paymentMethod;
  final double amount;
  final DateTime paidAt;

  TransactionResult({
    required this.transactionId,
    required this.prescriptionId,
    required this.status,
    required this.paymentMethod,
    required this.amount,
    required this.paidAt,
  });

  // ✅ FIX: Safe parsing for all numeric fields
  factory TransactionResult.fromJson(Map<String, dynamic> json) {
    return TransactionResult(
      transactionId: json['transactionId']?.toString() ?? '',
      prescriptionId: json['prescriptionId']?.toString() ??
          json['consultationId']?.toString() ??
          '',
      status: json['paymentStatus']?.toString() ??
          json['status']?.toString() ??
          'PAID',
      paymentMethod: json['paymentMethod']?.toString() ?? 'UNKNOWN',
      amount: _parseDouble(json['amount']),
      paidAt: _parseDateTime(json['paidAt']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('⚠️ Error parsing amount: $value');
        return 0.0;
      }
    }
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('⚠️ Error parsing date: $value');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  String get formattedAmount {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}

class FinancialSummary {
  final List<UserTransaction> recentTransactions;
  final PendingPayments pendingPayments;
  final double monthlySpent;

  FinancialSummary({
    required this.recentTransactions,
    required this.pendingPayments,
    required this.monthlySpent,
  });

  // Add missing fromJson method
  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    try {
      final recentList = json['recentTransactions'] as List? ?? [];
      final recentTransactions =
          recentList.map((item) => UserTransaction.fromJson(item)).toList();

      final pendingData =
          json['pendingPayments'] as Map<String, dynamic>? ?? {};
      final pendingPayments = PendingPayments.fromJson(pendingData);

      final monthlySpent = _parseDouble(json['monthlySpent']);

      return FinancialSummary(
        recentTransactions: recentTransactions,
        pendingPayments: pendingPayments,
        monthlySpent: monthlySpent,
      );
    } catch (e) {
      print('Error parsing FinancialSummary: $e');
      return FinancialSummary.empty();
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  factory FinancialSummary.empty() {
    return FinancialSummary(
      recentTransactions: [],
      pendingPayments: PendingPayments.empty(),
      monthlySpent: 0.0,
    );
  }
}
