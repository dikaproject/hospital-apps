import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/consultation_models.dart';
import '../services/transaction_service.dart';
import '../models/transaction_models.dart';
import 'dart:convert';

class ConsultationPaymentDialog extends StatefulWidget {
  final DirectConsultationResult consultation;
  final VoidCallback onPaymentSuccess;

  const ConsultationPaymentDialog({
    super.key,
    required this.consultation,
    required this.onPaymentSuccess,
  });

  @override
  State<ConsultationPaymentDialog> createState() =>
      _ConsultationPaymentDialogState();
}

class _ConsultationPaymentDialogState extends State<ConsultationPaymentDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.CREDIT_CARD;
  bool _isProcessing = false;
  bool _useOnlinePayment = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Bayar Konsultasi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Consultation Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D89), Color(0xFF1ABC9C)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_services,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konsultasi ${widget.consultation.doctor.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Biaya: ${widget.consultation.doctor.formattedFee}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment Type Selection
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Pembayaran Online',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _useOnlinePayment
                          ? 'Kartu Kredit, VA Bank, E-Wallet'
                          : 'Bayar di rumah sakit',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _useOnlinePayment,
                    activeColor: const Color(0xFF2E7D89),
                    onChanged: (value) {
                      setState(() {
                        _useOnlinePayment = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (!_useOnlinePayment)
              _buildManualPaymentOptions()
            else
              _buildOnlinePaymentInfo(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text(
            'Batal',
            style: TextStyle(color: Color(0xFF7F8C8D)),
          ),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D89),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _useOnlinePayment ? 'Bayar Online' : 'Konfirmasi Pembayaran',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildManualPaymentOptions() {
    return Column(
      children: [
        ...PaymentMethod.values
            .where((method) =>
                method == PaymentMethod.CASH ||
                method == PaymentMethod.BPJS ||
                method == PaymentMethod.INSURANCE)
            .map((method) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedMethod == method
                    ? const Color(0xFF2E7D89)
                    : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RadioListTile<PaymentMethod>(
              title: Row(
                children: [
                  Icon(
                    _getMethodIcon(method),
                    color: _selectedMethod == method
                        ? const Color(0xFF2E7D89)
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getMethodName(method),
                    style: TextStyle(
                      fontWeight: _selectedMethod == method
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedMethod == method
                          ? const Color(0xFF2C3E50)
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              value: method,
              groupValue: _selectedMethod,
              activeColor: const Color(0xFF2E7D89),
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildOnlinePaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.payment_rounded,
            color: Color(0xFF2E7D89),
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Pembayaran Online',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anda akan diarahkan ke halaman pembayaran yang aman:',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPaymentChip('💳 Kartu Kredit'),
              _buildPaymentChip('🏦 VA Bank'),
              _buildPaymentChip('📱 GoPay'),
              _buildPaymentChip('🛒 ShopeePay'),
              _buildPaymentChip('📊 QRIS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D89).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2E7D89),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      if (_useOnlinePayment) {
        final result =
            await TransactionService.createMidtransConsultationPayment(
          consultationId: widget.consultation.consultationId,
        );

        if (result != null && result.snapToken != null) {
          Navigator.pop(context);
          _showMidtransWebView(result.snapToken!, result.orderId!);
        } else {
          _showError('Gagal membuat pembayaran online');
        }
      } else {
        // Fix: Use the renamed method
        final success = await TransactionService.payConsultationDirect(
          consultationId: widget.consultation.consultationId,
          paymentMethod: _selectedMethod.name,
        );

        if (success != null) {
          Navigator.pop(context);
          widget.onPaymentSuccess();
          _showSuccessMessage();
        } else {
          _showError('Pembayaran gagal, silakan coba lagi');
        }
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Create custom Midtrans WebView for consultation
  void _showMidtransWebView(String snapToken, String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationMidtransPaymentScreen(
          snapToken: snapToken,
          orderId: orderId,
          onPaymentSuccess: () {
            widget.onPaymentSuccess();
            _showSuccessMessage();
          },
          onPaymentFailure: (error) {
            _showError('Pembayaran gagal: $error');
          },
        ),
      ),
    );
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.CASH:
        return Icons.money_rounded;
      case PaymentMethod.BPJS:
        return Icons.health_and_safety_rounded;
      case PaymentMethod.INSURANCE:
        return Icons.shield_rounded;
      default:
        return Icons.payment;
    }
  }

  String _getMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.CASH:
        return 'Tunai di Rumah Sakit';
      case PaymentMethod.BPJS:
        return 'BPJS Kesehatan';
      case PaymentMethod.INSURANCE:
        return 'Asuransi Kesehatan';
      default:
        return 'Unknown';
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pembayaran Berhasil!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Konsultasi dengan ${widget.consultation.doctor.name} siap dimulai',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF43E97B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Custom Midtrans Payment Screen for Consultation
class ConsultationMidtransPaymentScreen extends StatefulWidget {
  final String snapToken;
  final String orderId;
  final VoidCallback onPaymentSuccess;
  final Function(String) onPaymentFailure;

  const ConsultationMidtransPaymentScreen({
    super.key,
    required this.snapToken,
    required this.orderId,
    required this.onPaymentSuccess,
    required this.onPaymentFailure,
  });

  @override
  State<ConsultationMidtransPaymentScreen> createState() =>
      _ConsultationMidtransPaymentScreenState();
}

class _ConsultationMidtransPaymentScreenState
    extends State<ConsultationMidtransPaymentScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Check for payment completion URLs
            if (url.contains('finish') || url.contains('success')) {
              widget.onPaymentSuccess();
              Navigator.pop(context);
            } else if (url.contains('error') || url.contains('cancel')) {
              widget.onPaymentFailure('Payment cancelled or failed');
              Navigator.pop(context);
            }
          },
          onWebResourceError: (WebResourceError error) {
            widget.onPaymentFailure('Network error: ${error.description}');
            Navigator.pop(context);
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D89)),
          onPressed: () {
            Navigator.pop(context);
            widget.onPaymentFailure('Payment cancelled by user');
          },
        ),
        title: const Text(
          'Pembayaran Konsultasi',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2E7D89)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Memuat halaman pembayaran...',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
