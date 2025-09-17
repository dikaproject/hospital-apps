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
                      const Text(
                        'Tanggal Resep',
                        style: TextStyle(
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
                      const Text(
                        'Jumlah Obat',
                        style: TextStyle(
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
                  if (prescription.totalAmount != null &&
                      prescription.totalAmount! > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Biaya',
                          style: TextStyle(
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
                if (onPayTap != null && !prescription.isPaid)
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
                const Icon(
                  Icons.remove_red_eye_rounded,
                  color: Color(0xFF667EEA),
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
      case PaymentStatus.CANCELLED: // ✅ FIX: Add missing case
        return const LinearGradient(
          colors: [Color(0xFF95A5A6), Color(0xFFBDC3C7)],
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
      case PaymentStatus.CANCELLED: // ✅ FIX: Add missing case
        return Icons.cancel_rounded;
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
      case PaymentStatus.CANCELLED: // ✅ FIX: Add missing case
        return const Color(0xFF95A5A6);
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
      case PaymentStatus.CANCELLED: // ✅ FIX: Add missing case
        return 'Dibatalkan';
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
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ✅ ENHANCED: Modern Header with Prescription Status
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: prescription.isPaid
                    ? [const Color(0xFF43E97B), const Color(0xFF38F9D7)]
                    : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Header content
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medication_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resep ${prescription.prescriptionCode}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                prescription.isPaid
                                    ? Icons.check_circle_outline
                                    : Icons.access_time,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                prescription.statusText,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ ENHANCED: Scrollable Content with Detailed Information
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ ENHANCED: Prescription Overview
                  _buildDetailSection('📋 Informasi Resep', [
                    _buildDetailRow(
                        'Kode Resep', prescription.prescriptionCode),
                    _buildDetailRow('Dokter', prescription.doctor.name),
                    _buildDetailRow(
                        'Spesialisasi', prescription.doctor.specialty),
                    _buildDetailRow(
                        'Tanggal Resep',
                        DateFormat('dd MMMM yyyy, HH:mm')
                            .format(prescription.createdAt)),
                    _buildDetailRow('Diagnosis', prescription.diagnosis),
                    if (prescription.totalAmount != null &&
                        prescription.totalAmount! > 0)
                      _buildDetailRow(
                          'Total Biaya', prescription.formattedTotalAmount),
                    if (prescription.paidAt != null)
                      _buildDetailRow(
                          'Tanggal Bayar',
                          DateFormat('dd MMMM yyyy, HH:mm')
                              .format(prescription.paidAt!)),
                  ]),

                  const SizedBox(height: 24),

                  // ✅ ENHANCED: Clinical Information
                  if (prescription.diagnosis.isNotEmpty)
                    _buildExpandableSection('🔬 Informasi Klinis', [
                      _buildRichDetailCard(
                          'Diagnosis Utama', prescription.diagnosis),
                      if (prescription.notes != null &&
                          prescription.notes!.isNotEmpty)
                        _buildRichDetailCard(
                            'Catatan Klinis', prescription.notes!),
                    ]),

                  const SizedBox(height: 24),

                  // ✅ ENHANCED: Medications List with Rich Details
                  _buildDetailSection(
                    '💊 Daftar Obat (${prescription.medications.length} item)',
                    [
                      ...prescription.medications.asMap().entries.map((entry) {
                        final index = entry.key;
                        final medication = entry.value;
                        return _buildEnhancedMedicationCard(
                            medication, index + 1);
                      }).toList(),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ✅ ENHANCED: Doctor Instructions
                  if (prescription.instructions.isNotEmpty)
                    _buildExpandableSection('👨‍⚕️ Instruksi Dokter', [
                      _buildRichDetailCard(
                          'Petunjuk Umum', prescription.instructions),
                    ]),

                  const SizedBox(height: 24),

                  // ✅ ENHANCED: Payment Information
                  if (prescription.paymentInfo != null || prescription.isPaid)
                    _buildPaymentInfoSection(),

                  const SizedBox(height: 24),

                  // ✅ ENHANCED: Important Notes
                  _buildImportantNotesSection(),

                  // ✅ ENHANCED: Action Button
                  if (onPayTap != null && !prescription.isPaid) ...[
                    const SizedBox(height: 32),
                    _buildPaymentButton(),
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E5E9), width: 1),
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildExpandableSection(String title, List<Widget> children) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
      ),
      initiallyExpanded: true,
      backgroundColor: const Color(0xFFF8FAFC),
      collapsedBackgroundColor: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE1E5E9), width: 1),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE1E5E9), width: 1),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF7F8C8D))),
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

  Widget _buildRichDetailCard(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMedicationCard(
      PrescriptionMedication medication, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E5E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
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
                  if (medication.brandName != null &&
                      medication.brandName!.isNotEmpty)
                    Text(
                      'Merek: ${medication.brandName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 52, top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${medication.dosage} • ${medication.frequency}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (medication.totalPrice != null && medication.totalPrice! > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Rp ${NumberFormat('#,###').format(medication.totalPrice)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF27AE60),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Basic Info
                _buildMedicationDetailRow('💊 Dosis', medication.dosage),
                _buildMedicationDetailRow('⏰ Frekuensi', medication.frequency),
                _buildMedicationDetailRow(
                    '📅 Durasi', '${medication.duration} hari'),
                _buildMedicationDetailRow(
                    '🔢 Jumlah', '${medication.quantity} ${medication.unit}'),
                if (medication.price != null)
                  _buildMedicationDetailRow('💰 Harga/unit',
                      'Rp ${NumberFormat('#,###').format(medication.price)}'),

                const Divider(height: 24),

                // Instructions
                _buildMedicationInfoCard(
                    '📝 Cara Penggunaan', medication.instructions),

                // Additional info if available
                if (medication.notes != null && medication.notes!.isNotEmpty)
                  _buildMedicationInfoCard(
                      'ℹ️ Catatan Tambahan', medication.notes!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF7F8C8D))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E5E9), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2C3E50),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoSection() {
    return _buildDetailSection('💳 Informasi Pembayaran', [
      if (prescription.isPaid) ...[
        _buildDetailRow('Status', 'Sudah Dibayar ✅'),
        if (prescription.paidAt != null)
          _buildDetailRow('Tanggal Bayar',
              DateFormat('dd MMMM yyyy, HH:mm').format(prescription.paidAt!)),
        if (prescription.paymentInfo != null) ...[
          _buildDetailRow(
              'Metode Bayar', prescription.paymentInfo!.paymentMethod),
          _buildDetailRow(
              'ID Transaksi', prescription.paymentInfo!.transactionId),
        ],
      ] else ...[
        _buildDetailRow('Status', 'Belum Dibayar ❌'),
        if (prescription.totalAmount != null && prescription.totalAmount! > 0)
          _buildDetailRow(
              'Total yang Harus Dibayar', prescription.formattedTotalAmount),
      ],
    ]);
  }

  Widget _buildImportantNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE08A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF856404), size: 20),
              SizedBox(width: 8),
              Text(
                'Informasi Penting',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF856404),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Konsumsi obat sesuai dengan petunjuk dokter\n'
            '• Jangan menghentikan pengobatan tanpa berkonsultasi\n'
            '• Simpan obat di tempat sejuk dan kering\n'
            '• Segera hubungi dokter jika mengalami efek samping\n'
            '• Obat yang sudah dibayar dapat diambil di farmasi',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF856404),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPayTap,
        icon: const Icon(Icons.payment_rounded, color: Colors.white),
        label: Text(
          prescription.totalAmount != null && prescription.totalAmount! > 0
              ? 'Bayar Sekarang - ${prescription.formattedTotalAmount}'
              : 'Konfirmasi Resep',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
