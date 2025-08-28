import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/lab_models.dart';
import '../../widgets/lab_card_widget.dart';
import '../../widgets/medication_card_widget.dart';
import '../../widgets/notification_setup_widget.dart';

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
  bool _isLoading = true;
  String _selectedTab = 'Hasil Lab';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadLabResults();
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

  void _loadLabResults() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _labResults = _generateLabResults();
        _isLoading = false;
      });
      _animationController.forward();
    });
  }

  List<LabResult> _generateLabResults() {
    return [
      LabResult(
        id: 'LAB_001',
        testDate: DateTime.now().subtract(const Duration(days: 3)),
        doctorName: 'Dr. Lisa Sari, Sp.M',
        specialty: 'Spesialis Mata',
        hospital: 'RS Mitra Keluarga',
        testType: 'Pemeriksaan Refraksi Mata',
        results: [
          TestResult(
            testName: 'Mata Kanan (OD)',
            value: '-2.50',
            unit: 'Dioptri',
            normalRange: '0.00',
            status: TestStatus.abnormal,
            description: 'Miopia (Rabun Jauh)',
          ),
          TestResult(
            testName: 'Mata Kiri (OS)',
            value: '-2.25',
            unit: 'Dioptri', 
            normalRange: '0.00',
            status: TestStatus.abnormal,
            description: 'Miopia (Rabun Jauh)',
          ),
          TestResult(
            testName: 'Astigmatisme OD',
            value: '-0.75',
            unit: 'Dioptri',
            normalRange: '0.00',
            status: TestStatus.abnormal,
            description: 'Astigmatisme Ringan',
          ),
        ],
        medications: [
          Medication(
            id: 'MED_001',
            name: 'Systane Ultra Eye Drops',
            dosage: '1-2 tetes',
            frequency: '3x sehari',
            duration: 14,
            instructions: 'Teteskan pada mata yang kering, gunakan sebelum beraktivitas',
            sideEffects: 'Mata berair sementara',
            isActive: true,
            reminderEnabled: true,
            reminderTimes: ['08:00', '13:00', '19:00'],
          ),
        ],
        doctorNotes: 'Pasien mengalami miopia dengan astigmatisme ringan. Disarankan menggunakan kacamata koreksi dan eye drops untuk mengurangi mata kering akibat penggunaan gadget.',
        nextCheckup: DateTime.now().add(const Duration(days: 90)),
      ),
    ];
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
            icon: const Icon(Icons.refresh, color: Color(0xFF2E7D89)),
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D89)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat hasil lab dan resep...',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
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
          _buildTabBar(),
          Expanded(
            child: _selectedTab == 'Hasil Lab' 
                ? _buildLabResultsView()
                : _buildMedicationsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('Hasil Lab', Icons.science),
          ),
          Expanded(
            child: _buildTabButton('Obat & Resep', Icons.medication),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, IconData icon) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D89) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabResultsView() {
    if (_labResults.isEmpty) {
      return _buildEmptyState('Belum ada hasil lab', 'Hasil pemeriksaan lab akan muncul di sini');
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF2E7D89),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _labResults.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LabCardWidget(
              labResult: _labResults[index],
              onTap: () => _showLabDetail(_labResults[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicationsView() {
    final medications = _labResults
        .expand((lab) => lab.medications)
        .where((med) => med.isActive)
        .toList();

    if (medications.isEmpty) {
      return _buildEmptyState('Tidak ada obat aktif', 'Resep obat aktif akan muncul di sini');
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF2E7D89),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MedicationCardWidget(
              medication: medications[index],
              onTap: () => _showMedicationDetail(medications[index]),
              onToggleReminder: (enabled) => _toggleMedicationReminder(medications[index], enabled),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
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
              _selectedTab == 'Hasil Lab' ? Icons.science : Icons.medication,
              color: Colors.grey[400],
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showLabDetail(LabResult labResult) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
                      'Detail Hasil Lab',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabDetailSection(labResult),
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

  Widget _buildLabDetailSection(LabResult labResult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Jenis Pemeriksaan', labResult.testType),
              _buildDetailRow('Dokter', labResult.doctorName),
              _buildDetailRow('Spesialisasi', labResult.specialty),
              _buildDetailRow('Tanggal Tes', _formatDate(labResult.testDate)),
              if (labResult.nextCheckup != null)
                _buildDetailRow('Kontrol Berikutnya', _formatDate(labResult.nextCheckup!)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Test Results
        const Text(
          'Hasil Pemeriksaan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        ...labResult.results.map((result) => _buildTestResultCard(result)),
        
        const SizedBox(height: 20),
        
        // Doctor Notes
        if (labResult.doctorNotes.isNotEmpty) ...[
          const Text(
            'Catatan Dokter',
            style: TextStyle(
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
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
            ),
            child: Text(
              labResult.doctorNotes,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTestResultCard(TestResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(result.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.testName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(result.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(result.status),
                  style: TextStyle(
                    color: _getStatusColor(result.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Hasil: ',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              Text(
                '${result.value} ${result.unit}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(result.status),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Normal: ${result.normalRange}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
          if (result.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              result.description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2C3E50),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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

  void _showMedicationDetail(Medication medication) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotificationSetupWidget(
        medication: medication,
        onSave: (updatedMedication) => _updateMedication(updatedMedication),
      ),
    );
  }

  void _toggleMedicationReminder(Medication medication, bool enabled) {
    setState(() {
      final index = _labResults
          .expand((lab) => lab.medications)
          .toList()
          .indexOf(medication);
      if (index != -1) {
        medication.reminderEnabled = enabled;
      }
    });
    
    _showSnackBar(enabled 
        ? 'Pengingat obat diaktifkan' 
        : 'Pengingat obat dinonaktifkan');
  }

  void _updateMedication(Medication updatedMedication) {
    // Update medication in the list
    _showSnackBar('Pengaturan pengingat berhasil disimpan');
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _labResults = _generateLabResults();
      _isLoading = false;
    });
  }

  Color _getStatusColor(TestStatus status) {
    switch (status) {
      case TestStatus.normal:
        return const Color(0xFF2ECC71);
      case TestStatus.abnormal:
        return const Color(0xFFE74C3C);
      case TestStatus.borderline:
        return const Color(0xFFF39C12);
    }
  }

  String _getStatusText(TestStatus status) {
    switch (status) {
      case TestStatus.normal:
        return 'Normal';
      case TestStatus.abnormal:
        return 'Abnormal';
      case TestStatus.borderline:
        return 'Batas';
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    final day = days[date.weekday % 7];
    final dayNum = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    return '$day, $dayNum $month $year';
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