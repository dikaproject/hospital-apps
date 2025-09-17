import 'dart:convert';
import 'http_service.dart';
import 'auth_service.dart';
import '../models/transaction_models.dart';

class TransactionService {
  static const String _baseUrl = '/api/mobile/transactions';

  static Map<String, dynamic> _parseResponse(dynamic response) {
    try {
      if (response.body != null && response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Empty response'};
    } catch (e) {
      print('❌ Error parsing response: $e');
      return {'success': false, 'message': 'Invalid JSON response'};
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
        print('⚠️ Error parsing amount: $value');
        return 0.0;
      }
    }
    print('⚠️ Unexpected amount type: ${value.runtimeType} = $value');
    return 0.0;
  }

  // Fix: Add missing prescription payment method
  static Future<TransactionResult?> payPrescription({
    required String prescriptionId,
    required String paymentMethod,
    double? amount,
  }) async {
    try {
      print('💳 Processing prescription payment...');

      final response = await HttpService.post(
        '$_baseUrl/pay-prescription/$prescriptionId',
        {
          'useSnapPayment': false,
          'paymentMethod': paymentMethod,
          if (amount != null) 'amount': amount,
        },
        token: AuthService.getCurrentToken(),
      );

      final data = _parseResponse(response);

      if (data['success'] == true) {
        print('✅ Prescription payment successful');
        return TransactionResult.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Payment failed');
      }
    } catch (e) {
      print('❌ Error processing prescription payment: $e');
      return null;
    }
  }

  // Fix: Add missing midtrans prescription payment method
  static Future<MidtransPaymentResult?> createMidtransPayment({
    required String prescriptionId,
  }) async {
    try {
      print('🏦 Creating Midtrans payment for prescription: $prescriptionId');

      final response = await HttpService.post(
        '$_baseUrl/pay-prescription/$prescriptionId',
        {'useSnapPayment': true},
        token: AuthService.getCurrentToken(),
      );

      final data = _parseResponse(response);

      if (data['success'] == true) {
        print('✅ Midtrans payment created successfully');
        return MidtransPaymentResult.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create Midtrans payment');
      }
    } catch (e) {
      print('❌ Error creating Midtrans payment: $e');
      return null;
    }
  }

  // Fix: Add missing midtrans consultation payment method
  static Future<MidtransPaymentResult?> createMidtransConsultationPayment({
    required String consultationId,
  }) async {
    try {
      print('🏦 Creating Midtrans payment for consultation: $consultationId');

      final response = await HttpService.post(
        '/api/transactions/pay-consultation/$consultationId',
        {'useSnapPayment': true},
        token: AuthService.getCurrentToken(),
      );

      final data = _parseResponse(response);

      if (data['success'] == true) {
        print('✅ Midtrans consultation payment created successfully');
        return MidtransPaymentResult.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create Midtrans payment');
      }
    } catch (e) {
      print('❌ Error creating Midtrans consultation payment: $e');
      return null;
    }
  }

  // Fix: Add missing direct consultation payment method
  static Future<UserTransaction?> payConsultationDirect({
    required String consultationId,
    required String paymentMethod,
  }) async {
    try {
      print('💳 Processing direct consultation payment...');

      final response = await HttpService.post(
        '/api/transactions/pay-consultation/$consultationId',
        {
          'useSnapPayment': false,
          'paymentMethod': paymentMethod,
        },
        token: AuthService.getCurrentToken(),
      );

      final data = _parseResponse(response);

      if (data['success'] == true) {
        print('✅ Direct consultation payment successful');
        return UserTransaction.fromJson(data['data']['transaction']);
      } else {
        throw Exception(data['message'] ?? 'Failed to process payment');
      }
    } catch (e) {
      print('❌ Error processing direct consultation payment: $e');
      return null;
    }
  }

  // Existing methods...
  static Future<List<UserTransaction>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
  }) async {
    try {
      print('💰 Getting transaction history...');

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;

      final uri =
          Uri.parse('${HttpService.getCurrentBaseUrl()}$_baseUrl/history')
              .replace(queryParameters: queryParams);

      final response = await HttpService.get(
        uri.toString().replaceFirst(HttpService.getCurrentBaseUrl(), ''),
        token: AuthService.getCurrentToken(),
      );

      final data = _parseResponse(response);

      if (data['success'] == true) {
        final List<dynamic> transactionData = data['data'] ?? [];
        return transactionData
            .map((item) => UserTransaction.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('❌ Error fetching transaction history: $e');
      return [];
    }
  }

  static Future<PendingPayments> getPendingPayments() async {
    try {
      print('⏳ Getting pending payments...');

      final response = await HttpService.get(
        '$_baseUrl/pending',
        token: AuthService.getCurrentToken(),
      );

      final data = _parseResponse(response);

      if (data['success'] == true) {
        return PendingPayments.fromJson(data['data']);
      }

      return PendingPayments.empty();
    } catch (e) {
      print('❌ Error fetching pending payments: $e');
      return PendingPayments.empty();
    }
  }

  static Future<FinancialSummary> getFinancialSummary() async {
    try {
      print('📊 Getting financial summary...');

      final results = await Future.wait([
        getPendingPayments(),
        getTransactionHistory(limit: 5),
      ]);

      final pendingPayments = results[0] as PendingPayments;
      final recentTransactions = results[1] as List<UserTransaction>;

      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      final monthlyTransactions = recentTransactions.where((tx) {
        return tx.createdAt.isAfter(monthStart) &&
            tx.status == TransactionStatus.PAID;
      }).toList();

      final monthlySpent =
          monthlyTransactions.fold<double>(0.0, (sum, tx) => sum + tx.amount);

      return FinancialSummary(
        recentTransactions: recentTransactions,
        pendingPayments: pendingPayments,
        monthlySpent: monthlySpent,
      );
    } catch (e) {
      print('❌ Error getting financial summary: $e');
      return FinancialSummary.empty();
    }
  }
}

// Add missing TransactionResult class
class TransactionResult {
  final String transactionId;
  final String status;
  final double amount;
  final String? message;

  TransactionResult({
    required this.transactionId,
    required this.status,
    required this.amount,
    this.message,
  });

  factory TransactionResult.fromJson(Map<String, dynamic> json) {
    return TransactionResult(
      transactionId:
          json['transactionId']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      amount: TransactionService._parseDouble(json['amount']),
      message: json['message']?.toString(),
    );
  }
}

// Updated MidtransPaymentResult class with better parsing
class MidtransPaymentResult {
  final String transactionId;
  final String prescriptionId;
  final String? snapToken;
  final String? redirectUrl;
  final String? orderId;
  final double amount;

  MidtransPaymentResult({
    required this.transactionId,
    required this.prescriptionId,
    this.snapToken,
    this.redirectUrl,
    this.orderId,
    required this.amount,
  });

  factory MidtransPaymentResult.fromJson(Map<String, dynamic> json) {
    return MidtransPaymentResult(
      transactionId: json['transactionId']?.toString() ?? '',
      prescriptionId: json['prescriptionId']?.toString() ??
          json['consultationId']?.toString() ??
          '',
      snapToken: json['snapToken']?.toString(),
      redirectUrl: json['redirectUrl']?.toString(),
      orderId: json['orderId']?.toString(),
      amount: TransactionService._parseDouble(json['amount']),
    );
  }
}
