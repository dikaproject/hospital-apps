import 'package:flutter/material.dart';
import '../models/lab_results_models.dart';
import 'package:intl/intl.dart';

class MedicalRecordCard extends StatelessWidget {
  final MedicalRecord medicalRecord;
  final VoidCallback onTap;

  const MedicalRecordCard({
    super.key,
    required this.medicalRecord,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_information_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicalRecord.diagnosis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medicalRecord.doctor.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(medicalRecord.visitDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ ENHANCED: Treatment Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Treatment',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicalRecord.treatment,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2C3E50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ✅ ENHANCED: Quick Info Row
            Row(
              children: [
                // Payment Status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(medicalRecord.paymentStatus),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getPaymentStatusText(medicalRecord.paymentStatus),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return const Color(0xFF27AE60);
      case 'PENDING':
        return const Color(0xFFFFB74D);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return 'Lunas';
      case 'PENDING':
        return 'Pending';
      default:
        return status;
    }
  }
}

class MedicalRecordDetailSheet extends StatelessWidget {
  final MedicalRecord medicalRecord;

  const MedicalRecordDetailSheet({
    super.key,
    required this.medicalRecord,
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
          // ✅ ENHANCED: Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_information_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rekam Medis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMMM yyyy')
                                .format(medicalRecord.visitDate),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
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

          // ✅ ENHANCED: Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information
                  _buildDetailSection(
                      '📋 Informasi Dasar',
                      [
                        _buildDetailRow('Dokter', medicalRecord.doctor.name),
                        _buildDetailRow(
                            'Spesialisasi', medicalRecord.doctor.specialty),
                        _buildDetailRow(
                            'Tanggal Kunjungan',
                            DateFormat('dd MMMM yyyy, HH:mm')
                                .format(medicalRecord.visitDate)),
                        if (medicalRecord.queueNumber != null)
                          _buildDetailRow(
                              'No. Antrean', medicalRecord.queueNumber!),
                      ],
                      true),

                  const SizedBox(height: 24),

                  // Diagnosis & Treatment
                  _buildDetailSection(
                      '🔬 Diagnosis & Pengobatan',
                      [
                        _buildRichDetailCard(
                            'Diagnosis', medicalRecord.diagnosis),
                        _buildRichDetailCard(
                            'Pengobatan', medicalRecord.treatment),
                      ],
                      true),

                  const SizedBox(height: 24),

                  // Clinical Data
                  if (medicalRecord.symptoms != null ||
                      medicalRecord.vitalSigns != null)
                    _buildClinicalDataSection(),

                  // Medications
                  if (medicalRecord.medications != null)
                    _buildMedicationsSection(),

                  // Payment Information
                  _buildPaymentSection(),

                  // Notes
                  if (medicalRecord.notes != null &&
                      medicalRecord.notes!.isNotEmpty)
                    _buildNotesSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children,
      [bool isBasicInfo = false]) {
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
          if (isBasicInfo) const Divider(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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

  Widget _buildClinicalDataSection() {
    return Column(
      children: [
        _buildDetailSection('🩺 Data Klinis', [
          if (medicalRecord.symptoms != null)
            _buildJsonDataCard('Gejala', medicalRecord.symptoms!),
          if (medicalRecord.vitalSigns != null)
            _buildJsonDataCard('Tanda Vital', medicalRecord.vitalSigns!),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMedicationsSection() {
    return Column(
      children: [
        _buildDetailSection('💊 Obat-obatan', [
          _buildJsonDataCard('Daftar Obat', medicalRecord.medications!),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      children: [
        _buildDetailSection('💳 Informasi Pembayaran', [
          _buildDetailRow('Status Pembayaran',
              _getPaymentStatusText(medicalRecord.paymentStatus)),
          _buildDetailRow('Metode Pembayaran',
              _getPaymentMethodText(medicalRecord.paymentMethod)),
          if (medicalRecord.totalCost != null)
            _buildDetailRow('Total Biaya',
                'Rp ${NumberFormat('#,###').format(medicalRecord.totalCost)}'),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      children: [
        _buildDetailSection('📝 Catatan', [
          _buildRichDetailCard('Catatan Tambahan', medicalRecord.notes!),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildJsonDataCard(String title, Map<String, dynamic> data) {
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
          const SizedBox(height: 12),
          ...data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      entry.key,
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
                      entry.value.toString(),
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
          }).toList(),
        ],
      ),
    );
  }

  String _getPaymentStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return 'Sudah Dibayar ✅';
      case 'PENDING':
        return 'Menunggu Pembayaran ⏳';
      default:
        return status;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method.toUpperCase()) {
      case 'CASH':
        return 'Tunai';
      case 'BPJS':
        return 'BPJS Kesehatan';
      case 'INSURANCE':
        return 'Asuransi Kesehatan';
      default:
        return method;
    }
  }
}
