import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/medical_history_models.dart';
import '../../services/auth_service.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<MedicalRecord> _medicalHistory = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadMedicalHistory();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _loadMedicalHistory() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _medicalHistory = _generateMedicalHistory();
        _isLoading = false;
      });
      _animationController.forward();
    });
  }

  List<MedicalRecord> _generateMedicalHistory() {
    final random = Random();
    final records = <MedicalRecord>[];

    // Generate 8-12 medical records
    final recordCount = random.nextInt(5) + 8;

    for (int i = 0; i < recordCount; i++) {
      final visitDate = DateTime.now().subtract(Duration(
        days: random.nextInt(365) + 1,
      ));

      records.add(MedicalRecord(
        id: 'MR_${random.nextInt(10000)}',
        visitDate: visitDate,
        doctorName: [
          'Dr. Sarah Wijaya, Sp.PD',
          'Dr. Ahmad Budi, Sp.JP',
          'Dr. Lisa Sari, Sp.M',
          'Dr. Andi Pratama',
          'Dr. Maya Sari, Sp.OG',
          'Dr. Budi Santoso, Sp.B',
          'Dr. Sinta Dewi, Sp.A'
        ][random.nextInt(7)],
        specialty: [
          'Spesialis Penyakit Dalam',
          'Spesialis Jantung',
          'Spesialis Mata',
          'Dokter Umum',
          'Spesialis Kandungan',
          'Spesialis Bedah',
          'Spesialis Anak'
        ][random.nextInt(7)],
        hospital: 'RS Mitra Keluarga',
        diagnosis: [
          'Hipertensi Grade 1',
          'Diabetes Mellitus Tipe 2',
          'Gastritis Akut',
          'Rhinitis Alergi',
          'Migrain',
          'Anemia Defisiensi Besi',
          'Pneumonia',
          'Bronkitis Akut'
        ][random.nextInt(8)],
        treatment: [
          'Terapi obat antihipertensi',
          'Diet dan kontrol gula darah',
          'Terapi asam lambung',
          'Antihistamin dan spray hidung',
          'Analgesik dan istirahat',
          'Suplemen zat besi',
          'Antibiotik dan bronkodilator',
          'Ekspektoran dan istirahat'
        ][random.nextInt(8)],
        prescription: _generatePrescription(),
        totalCost: (random.nextInt(500) + 100) * 1000,
        paymentMethod: [
          PaymentMethod.cash,
          PaymentMethod.bpjs,
          PaymentMethod.insurance,
          PaymentMethod.creditCard
        ][random.nextInt(4)],
        paymentStatus: PaymentStatus.paid,
        notes: [
          'Kontrol kembali 2 minggu',
          'Pantau gejala, kembali jika memburuk',
          'Hindari makanan pedas dan asam',
          'Gunakan masker saat keluar rumah',
          'Istirahat cukup dan hindari stress',
          'Konsumsi makanan tinggi zat besi',
          'Habiskan antibiotik sesuai dosis',
          'Minum air putih yang cukup'
        ][random.nextInt(8)],
        documents: _generateDocuments(),
        queueNumber: 'A-${random.nextInt(50) + 1}',
      ));
    }

    records.sort((a, b) => b.visitDate.compareTo(a.visitDate));
    return records;
  }

  List<String> _generatePrescription() {
    final medications = [
      'Amlodipine 5mg - 1x1 pagi',
      'Metformin 500mg - 2x1 sebelum makan',
      'Omeprazole 20mg - 1x1 pagi sebelum makan',
      'Loratadine 10mg - 1x1 malam',
      'Paracetamol 500mg - 3x1 bila perlu',
      'Sangobion 1 tablet - 1x1 setelah makan',
      'Amoxicillin 500mg - 3x1 sesudah makan',
      'Salbutamol inhaler - 2 puff bila sesak'
    ];

    final random = Random();
    final prescriptionCount = random.nextInt(3) + 1;
    final prescription = <String>[];

    for (int i = 0; i < prescriptionCount; i++) {
      prescription.add(medications[random.nextInt(medications.length)]);
    }

    return prescription;
  }

  List<MedicalDocument> _generateDocuments() {
    final random = Random();
    final documents = <MedicalDocument>[];

    // Generate 1-3 documents
    final docCount = random.nextInt(3) + 1;

    for (int i = 0; i < docCount; i++) {
      documents.add(MedicalDocument(
        id: 'DOC_${random.nextInt(1000)}',
        name: [
          'Surat Keterangan Sehat',
          'Hasil Pemeriksaan Lab',
          'Resep Obat',
          'Surat Rujukan',
          'Hasil Rontgen'
        ][random.nextInt(5)],
        type: [
          DocumentType.medicalCertificate,
          DocumentType.labResult,
          DocumentType.prescription,
          DocumentType.referralLetter,
          DocumentType.xrayResult
        ][random.nextInt(5)],
        url: 'https://example.com/document_${random.nextInt(1000)}.pdf',
      ));
    }

    return documents;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Kunjungan',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterOptions,
            icon: const Icon(Icons.filter_list, color: Color(0xFF2E7D89)),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildHistoryView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D89)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat riwayat kunjungan...',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    final filteredHistory = _getFilteredHistory();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _refreshHistory,
        color: const Color(0xFF2E7D89),
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: filteredHistory.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child:
                              _buildMedicalRecordCard(filteredHistory[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', '2024', '2023', 'BPJS', 'Umum'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              selectedColor: const Color(0xFF2E7D89).withOpacity(0.2),
              checkmarkColor: const Color(0xFF2E7D89),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF2E7D89)
                    : const Color(0xFF7F8C8D),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicalRecordCard(MedicalRecord record) {
    return GestureDetector(
      onTap: () => _showRecordDetail(record),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _getSpecialtyColor(record.specialty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSpecialtyIcon(record.specialty),
                    color: _getSpecialtyColor(record.specialty),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.doctorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        record.specialty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentMethodColor(record.paymentMethod)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPaymentMethodText(record.paymentMethod),
                    style: TextStyle(
                      color: _getPaymentMethodColor(record.paymentMethod),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              record.diagnosis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 14),
                const SizedBox(width: 6),
                Text(
                  _formatDate(record.visitDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.payments, color: Colors.grey[600], size: 14),
                const SizedBox(width: 6),
                Text(
                  _formatCurrency(record.totalCost),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF27AE60),
                  ),
                ),
              ],
            ),
            if (record.documents.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.description, color: Colors.grey[600], size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${record.documents.length} dokumen tersedia',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF3498DB),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.history,
              color: Colors.grey[400],
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat kunjungan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat kunjungan Anda akan muncul di sini',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetail(MedicalRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Kunjungan',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailSection('Informasi Umum', [
                      _buildDetailRow(
                          'Tanggal Kunjungan', _formatDate(record.visitDate)),
                      _buildDetailRow('Dokter', record.doctorName),
                      _buildDetailRow('Spesialisasi', record.specialty),
                      _buildDetailRow('Rumah Sakit', record.hospital),
                      _buildDetailRow('Nomor Antrean', record.queueNumber),
                    ]),
                    _buildDetailSection('Diagnosis & Pengobatan', [
                      _buildDetailRow('Diagnosis', record.diagnosis),
                      _buildDetailRow('Pengobatan', record.treatment),
                      _buildDetailRow('Catatan Dokter', record.notes),
                    ]),
                    if (record.prescription.isNotEmpty)
                      _buildDetailSection(
                          'Resep Obat',
                          record.prescription
                              .map((med) => _buildMedicationRow(med))
                              .toList()),
                    _buildDetailSection('Pembayaran', [
                      _buildDetailRow(
                          'Total Biaya', _formatCurrency(record.totalCost)),
                      _buildDetailRow('Metode Pembayaran',
                          _getPaymentMethodText(record.paymentMethod)),
                      _buildDetailRow('Status',
                          _getPaymentStatusText(record.paymentStatus)),
                    ]),
                    if (record.documents.isNotEmpty)
                      _buildDocumentsSection(record.documents),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D89),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7F8C8D),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationRow(String medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.medication, color: Colors.grey[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              medication,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(List<MedicalDocument> documents) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dokumen Medis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          ...documents.map((doc) => _buildDocumentCard(doc)),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(MedicalDocument document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getDocumentIcon(document.type),
              color: const Color(0xFF3498DB),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              document.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _downloadDocument(document),
            icon: const Icon(Icons.download, size: 18),
            color: const Color(0xFF2E7D89),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Filter Riwayat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.date_range, color: Color(0xFF3498DB)),
              title: Text('Filter berdasarkan tanggal'),
            ),
            const ListTile(
              leading: Icon(Icons.local_hospital, color: Color(0xFF2ECC71)),
              title: Text('Filter berdasarkan dokter'),
            ),
            const ListTile(
              leading: Icon(Icons.payment, color: Color(0xFFF39C12)),
              title: Text('Filter berdasarkan pembayaran'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshHistory() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _medicalHistory = _generateMedicalHistory();
      _isLoading = false;
    });
  }

  List<MedicalRecord> _getFilteredHistory() {
    if (_selectedFilter == 'Semua') return _medicalHistory;

    return _medicalHistory.where((record) {
      switch (_selectedFilter) {
        case '2024':
          return record.visitDate.year == 2024;
        case '2023':
          return record.visitDate.year == 2023;
        case 'BPJS':
          return record.paymentMethod == PaymentMethod.bpjs;
        case 'Umum':
          return record.paymentMethod == PaymentMethod.cash;
        default:
          return true;
      }
    }).toList();
  }

  void _downloadDocument(MedicalDocument document) {
    _showSnackBar('Mengunduh ${document.name}...');
  }

  // Helper methods
  Color _getSpecialtyColor(String specialty) {
    switch (specialty) {
      case 'Spesialis Jantung':
        return const Color(0xFFE74C3C);
      case 'Spesialis Mata':
        return const Color(0xFF3498DB);
      case 'Spesialis Penyakit Dalam':
        return const Color(0xFF2ECC71);
      case 'Spesialis Kandungan':
        return const Color(0xFF9B59B6);
      case 'Spesialis Bedah':
        return const Color(0xFFE67E22);
      case 'Spesialis Anak':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  IconData _getSpecialtyIcon(String specialty) {
    switch (specialty) {
      case 'Spesialis Jantung':
        return Icons.favorite;
      case 'Spesialis Mata':
        return Icons.visibility;
      case 'Spesialis Penyakit Dalam':
        return Icons.local_hospital;
      case 'Spesialis Kandungan':
        return Icons.pregnant_woman;
      case 'Spesialis Bedah':
        return Icons.healing;
      case 'Spesialis Anak':
        return Icons.child_care;
      default:
        return Icons.medical_services;
    }
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.bpjs:
        return const Color(0xFF2ECC71);
      case PaymentMethod.insurance:
        return const Color(0xFF3498DB);
      case PaymentMethod.creditCard:
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFFF39C12);
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.bpjs:
        return 'BPJS';
      case PaymentMethod.insurance:
        return 'Asuransi';
      case PaymentMethod.creditCard:
        return 'Kartu Kredit';
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'Lunas';
      case PaymentStatus.pending:
        return 'Menunggu';
      case PaymentStatus.failed:
        return 'Gagal';
    }
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.medicalCertificate:
        return Icons.assignment;
      case DocumentType.labResult:
        return Icons.science;
      case DocumentType.prescription:
        return Icons.medication;
      case DocumentType.referralLetter:
        return Icons.send;
      case DocumentType.xrayResult:
        return Icons.local_hospital;
    }
  }

  String _formatDate(DateTime date) {
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    final day = days[date.weekday % 7];
    final dayNum = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    return '$day, $dayNum $month $year';
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E7D89),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
