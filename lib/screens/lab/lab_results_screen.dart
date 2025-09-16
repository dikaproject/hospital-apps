import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/lab_results_models.dart';
import '../../models/prescription_models.dart' as prescription_models;
import '../../services/lab_results_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/lab_result_card.dart';
import '../../widgets/prescription_card.dart';
import '../../widgets/payment_dialog.dart';
import 'package:intl/intl.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<LabResult> _labResults = [];
  List<MedicalRecord> _medicalRecords = [];
  List<prescription_models.DigitalPrescription> _prescriptions = [];
  bool _isLoading = true;
  String _selectedTab = 'Hasil Lab';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAllData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  Future<void> _loadAllData() async {
    try {
      setState(() => _isLoading = true);

      final results = await Future.wait([
        LabResultsService.getLabResults(),
        LabResultsService.getMedicalRecords(),
        LabResultsService.getPrescriptions(),
      ]);

      setState(() {
        _labResults = results[0] as List<LabResult>;
        _medicalRecords = results[1] as List<MedicalRecord>;
        _prescriptions =
            results[2] as List<prescription_models.DigitalPrescription>;
        _isLoading = false;
      });

      _animationController.forward();

      // Mark new items as read after viewing
      _markNewItemsAsRead();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data: ${e.toString()}');
    }
  }

  void _markNewItemsAsRead() {
    // Mark new lab results as read
    for (var labResult in _labResults.where((lab) => lab.isNew)) {
      LabResultsService.markLabResultAsRead(labResult.id);
    }
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
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF667EEA)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hasil Lab & Resep',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF667EEA)),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildMainContent(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Memuat hasil lab dan resep...',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildModernTabBar(),
          Expanded(child: _buildSelectedTabContent()),
        ],
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('Hasil Lab', Icons.science_rounded)),
          Expanded(
              child: _buildTabButton(
                  'Rekam Medis', Icons.medical_information_rounded)),
          Expanded(
              child: _buildTabButton('Resep Obat', Icons.medication_rounded)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, IconData icon) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedTab = title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667EEA) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_selectedTab) {
      case 'Hasil Lab':
        return _buildLabResultsView();
      case 'Rekam Medis':
        return _buildMedicalRecordsView();
      case 'Resep Obat':
        return _buildPrescriptionsView();
      default:
        return _buildLabResultsView();
    }
  }

  Widget _buildLabResultsView() {
    if (_labResults.isEmpty) {
      return _buildEmptyState(
        'Belum Ada Hasil Lab',
        'Hasil pemeriksaan lab akan muncul di sini',
        Icons.science_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF667EEA),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _labResults.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LabResultCard(
              labResult: _labResults[index],
              onTap: () => _showLabResultDetail(_labResults[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicalRecordsView() {
    if (_medicalRecords.isEmpty) {
      return _buildEmptyState(
        'Belum Ada Rekam Medis',
        'Rekam medis dari konsultasi akan muncul di sini',
        Icons.medical_information_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF667EEA),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _medicalRecords.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMedicalRecordCard(_medicalRecords[index]),
          );
        },
      ),
    );
  }

  Widget _buildMedicalRecordCard(MedicalRecord medicalRecord) {
    return Container(
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
          Text(
            'Treatment: ${medicalRecord.treatment}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsView() {
    if (_prescriptions.isEmpty) {
      return _buildEmptyState(
        'Belum Ada Resep',
        'Resep obat dari dokter akan muncul di sini',
        Icons.medication_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF667EEA),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _prescriptions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PrescriptionCard(
              prescription: _prescriptions[index],
              onTap: () => _showPrescriptionDetail(_prescriptions[index]),
              onPayTap: _prescriptions[index].paymentStatus ==
                      prescription_models.PaymentStatus.PENDING
                  ? () => _showPaymentDialog(_prescriptions[index])
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.1),
                  const Color(0xFF764BA2).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF667EEA),
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showLabResultDetail(LabResult labResult) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildLabResultDetailSheet(labResult),
    );
  }

  Widget _buildLabResultDetailSheet(LabResult labResult) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.science_rounded,
                    color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    labResult.testName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hasil Pemeriksaan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display lab results
                  ...labResult.results.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              '${entry.key}:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (labResult.doctorNotes != null) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Catatan Dokter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labResult.doctorNotes!,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrescriptionDetail(
      prescription_models.DigitalPrescription prescription) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildPrescriptionDetailSheet(prescription),
    );
  }

  Widget _buildPrescriptionDetailSheet(
      prescription_models.DigitalPrescription prescription) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: prescription.isPaid
                    ? [const Color(0xFF43E97B), const Color(0xFF38F9D7)]
                    : [const Color(0xFFFFB74D), const Color(0xFFFF8A65)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.medication_rounded,
                    color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prescription.prescriptionCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        prescription.doctor.name,
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
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Obat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: prescription.medications.length,
                      itemBuilder: (context, index) {
                        final medication = prescription.medications[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE1E5E9),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medication.genericName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${medication.dosage} - ${medication.frequency}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7F8C8D),
                                ),
                              ),
                              Text(
                                medication.instructions,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7F8C8D),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (!prescription.isPaid) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showPaymentDialog(prescription);
                        },
                        icon: const Icon(Icons.payment_rounded),
                        label: Text(
                            'Bayar - Rp ${prescription.totalAmount?.toStringAsFixed(0) ?? '0'}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(
      prescription_models.DigitalPrescription prescription) {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        prescription: prescription,
        onPaymentSuccess: () {
          _refreshData();
          _showSnackBar('Pembayaran berhasil! Resep sedang diproses');

          // Setup notification reminder
          _setupMedicationReminders(prescription);
        },
      ),
    );
  }

  void _setupMedicationReminders(
      prescription_models.DigitalPrescription prescription) {
    for (var medication in prescription.medications) {
      NotificationService.scheduleNotification(
        id: medication.medicationId.hashCode,
        title: 'Pengingat Minum Obat',
        body: '${medication.genericName} - ${medication.dosage}',
        scheduledDate: DateTime.now().add(const Duration(hours: 8)),
      );
    }
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    await _loadAllData();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF667EEA),
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
