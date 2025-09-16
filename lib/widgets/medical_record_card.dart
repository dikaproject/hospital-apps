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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
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
                        'Rekam Medis',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnosis:',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicalRecord.diagnosis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanggal Kunjungan',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy')
                            .format(medicalRecord.visitDate),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  if (medicalRecord.queueNumber != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'No. Antrean',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                        Text(
                          medicalRecord.queueNumber!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
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
      height: MediaQuery.of(context).size.height * 0.85,
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
                    'Detail Rekam Medis',
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
                  _buildDetailSection('Informasi Kunjungan', [
                    _buildDetailRow(
                        'Tanggal Kunjungan',
                        DateFormat('dd MMMM yyyy')
                            .format(medicalRecord.visitDate)),
                    _buildDetailRow('Dokter', medicalRecord.doctor.name),
                    _buildDetailRow(
                        'Spesialisasi', medicalRecord.doctor.specialty),
                    if (medicalRecord.queueNumber != null)
                      _buildDetailRow(
                          'No. Antrean', medicalRecord.queueNumber!),
                  ]),
                  const SizedBox(height: 24),
                  _buildDetailSection('Diagnosis & Pengobatan', [
                    _buildMultiLineDetailRow(
                        'Diagnosis', medicalRecord.diagnosis),
                    _buildMultiLineDetailRow(
                        'Pengobatan', medicalRecord.treatment),
                  ]),
                  if (medicalRecord.symptoms != null) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection('Gejala', [
                      _buildJsonDataWidget(medicalRecord.symptoms!),
                    ]),
                  ],
                  if (medicalRecord.vitalSigns != null) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection('Tanda Vital', [
                      _buildJsonDataWidget(medicalRecord.vitalSigns!),
                    ]),
                  ],
                  if (medicalRecord.medications != null) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection('Obat yang Diberikan', [
                      _buildJsonDataWidget(medicalRecord.medications!),
                    ]),
                  ],
                  if (medicalRecord.notes != null) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection('Catatan Tambahan', [
                      Text(
                        medicalRecord.notes!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                          height: 1.5,
                        ),
                      ),
                    ]),
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

  Widget _buildMultiLineDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonDataWidget(Map<String, dynamic> data) {
    return Column(
      children: data.entries.map((entry) {
        return _buildDetailRow(entry.key, entry.value.toString());
      }).toList(),
    );
  }
}
