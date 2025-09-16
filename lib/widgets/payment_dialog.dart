import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prescription_models.dart';
import '../services/lab_results_service.dart';

class PaymentDialog extends StatefulWidget {
  final DigitalPrescription prescription;
  final VoidCallback onPaymentSuccess;

  const PaymentDialog({
    super.key,
    required this.prescription,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.CREDIT_CARD;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Pilih Metode Pembayaran',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_rounded,
                    color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.prescription.prescriptionCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total: Rp ${widget.prescription.totalAmount?.toStringAsFixed(0) ?? '0'}',
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
          ...PaymentMethod.values.map((method) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedMethod == method
                      ? const Color(0xFF667EEA)
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
                          ? const Color(0xFF667EEA)
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
                activeColor: const Color(0xFF667EEA),
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value!;
                  });
                },
              ),
            );
          }).toList(),
        ],
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
            backgroundColor: const Color(0xFF667EEA),
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
              : const Text(
                  'Bayar Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
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
      case PaymentMethod.CREDIT_CARD:
        return Icons.credit_card_rounded;
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
      case PaymentMethod.CREDIT_CARD:
        return 'Kartu Kredit/Debit';
    }
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Add some delay for better UX
      await Future.delayed(const Duration(seconds: 1));

      final success = await LabResultsService.payPrescription(
        widget.prescription.id,
        _selectedMethod,
      );

      if (success) {
        Navigator.pop(context);
        widget.onPaymentSuccess();
        _showSuccessMessage();
      } else {
        _showError('Pembayaran gagal, silakan coba lagi');
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
                    'Resep ${widget.prescription.prescriptionCode} sedang diproses',
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
