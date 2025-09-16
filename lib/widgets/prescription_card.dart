import 'package:flutter/material.dart';
import '../models/prescription_models.dart';
import 'package:intl/intl.dart';

class PrescriptionCard extends StatelessWidget {
  final DigitalPrescription prescription;
  final VoidCallback onTap;
  final VoidCallback? onPayTap;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    required this.onTap,
    this.onPayTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: prescription.isNew
              ? Border.all(color: const Color(0xFF667EEA), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: _getStatusGradient(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Resep ${prescription.prescriptionCode}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          if (prescription.isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667EEA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'BARU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prescription.doctor.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanggal Resep',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(prescription.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah Obat',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                      Text(
                        '${prescription.medications.length} item',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  if (prescription.totalAmount != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Biaya',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,###').format(prescription.totalAmount)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (onPayTap != null)
                  ElevatedButton(
                    onPressed: onPayTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Bayar',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.remove_red_eye_rounded,
                  color: const Color(0xFF667EEA),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tap untuk melihat detail',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getStatusGradient() {
    switch (prescription.paymentStatus) {
      case PaymentStatus.PAID:
        return const LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        );
      case PaymentStatus.PENDING:
        return const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFFCC33)],
        );
      case PaymentStatus.FAILED:
        return const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
        );
    }
  }

  IconData _getStatusIcon() {
    switch (prescription.paymentStatus) {
      case PaymentStatus.PAID:
        return Icons.check_circle_rounded;
      case PaymentStatus.PENDING:
        return Icons.access_time_rounded;
      case PaymentStatus.FAILED:
        return Icons.error_rounded;
    }
  }

  Color _getStatusColor() {
    switch (prescription.paymentStatus) {
      case PaymentStatus.PAID:
        return const Color(0xFF4FACFE);
      case PaymentStatus.PENDING:
        return const Color(0xFFFFB347);
      case PaymentStatus.FAILED:
        return const Color(0xFFFF6B6B);
    }
  }

  String _getStatusText() {
    switch (prescription.paymentStatus) {
      case PaymentStatus.PAID:
        return prescription.isDispensed ? 'Sudah Diambil' : 'Sudah Dibayar';
      case PaymentStatus.PENDING:
        return 'Menunggu Pembayaran';
      case PaymentStatus.FAILED:
        return 'Pembayaran Gagal';
    }
  }
}

class PrescriptionDetailSheet extends StatelessWidget {
  final DigitalPrescription prescription;
  final VoidCallback? onPayTap;

  const PrescriptionDetailSheet({
    super.key,
    required this.prescription,
    this.onPayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Detail Resep',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('Informasi Resep', [
                    _buildDetailRow(
                        'Kode Resep', prescription.prescriptionCode),
                    _buildDetailRow('Dokter', prescription.doctor.name),
                    _buildDetailRow(
                        'Spesialisasi', prescription.doctor.specialty),
                    _buildDetailRow(
                        'Tanggal',
                        DateFormat('dd MMMM yyyy')
                            .format(prescription.createdAt)),
                    if (prescription.totalAmount != null)
                      _buildDetailRow('Total Biaya',
                          'Rp ${NumberFormat('#,###').format(prescription.totalAmount)}'),
                  ]),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    'Daftar Obat',
                    prescription.medications
                        .map((med) => _buildMedicationCard(med))
                        .toList(),
                  ),
                  if (prescription.instructions != null) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection('Instruksi Dokter', [
                      Text(
                        prescription.instructions!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                          height: 1.5,
                        ),
                      ),
                    ]),
                  ],
                  if (onPayTap != null) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onPayTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Bayar Sekarang - Rp ${NumberFormat('#,###').format(prescription.totalAmount)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(PrescriptionMedication medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medication.genericName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          if (medication.brandName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Merek: ${medication.brandName}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '${medication.dosage} - ${medication.frequency}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            medication.instructions,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7F8C8D),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qty: ${medication.quantity} ${medication.unit}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              Text(
                'Rp ${NumberFormat('#,###').format(medication.totalPrice)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
