import 'package:flutter/material.dart';
import '../models/lab_results_models.dart';
import 'package:intl/intl.dart';

class LabResultCard extends StatelessWidget {
  final LabResult labResult;
  final VoidCallback onTap;

  const LabResultCard({
    super.key,
    required this.labResult,
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
          border: labResult.isNew
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
                    gradient: LinearGradient(
                      colors: labResult.isCritical
                          ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)]
                          : [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    labResult.isCritical
                        ? Icons.warning_rounded
                        : Icons.science_rounded,
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
                              labResult.testName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          if (labResult.isNew)
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
                        labResult.testType,
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
                        'Tanggal Test',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(labResult.testDate),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  if (labResult.resultDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hasil Tersedia',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(labResult.resultDate!),
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
            if (labResult.isCritical) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.priority_high_rounded,
                      color: Color(0xFFFF6B6B),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Hasil memerlukan perhatian dokter',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class LabResultDetailSheet extends StatelessWidget {
  final LabResult labResult;

  const LabResultDetailSheet({
    super.key,
    required this.labResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                    'Detail Hasil Lab',
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
                  _buildDetailSection('Informasi Test', [
                    _buildDetailRow('Nama Test', labResult.testName),
                    _buildDetailRow('Jenis Test', labResult.testType),
                    if (labResult.category != null)
                      _buildDetailRow('Kategori', labResult.category!),
                    _buildDetailRow('Tanggal Test',
                        DateFormat('dd MMMM yyyy').format(labResult.testDate)),
                    if (labResult.resultDate != null)
                      _buildDetailRow(
                          'Hasil Tersedia',
                          DateFormat('dd MMMM yyyy HH:mm')
                              .format(labResult.resultDate!)),
                  ]),
                  const SizedBox(height: 24),
                  _buildDetailSection('Hasil Test', [
                    ...labResult.results.entries.map((entry) {
                      return _buildResultRow(entry.key, entry.value.toString());
                    }).toList(),
                  ]),
                  if (labResult.normalRange != null) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection('Nilai Normal', [
                      ...labResult.normalRange!.entries.map((entry) {
                        return _buildDetailRow(
                            entry.key, entry.value.toString());
                      }).toList(),
                    ]),
                  ],
                  if (labResult.doctorNotes != null) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection('Catatan Dokter', [
                      Text(
                        labResult.doctorNotes!,
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

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
