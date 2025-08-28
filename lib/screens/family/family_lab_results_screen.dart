import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/family_models.dart';
import '../../models/lab_results_models.dart';

class FamilyLabResultsScreen extends StatefulWidget {
  const FamilyLabResultsScreen({super.key});

  @override
  State<FamilyLabResultsScreen> createState() => _FamilyLabResultsScreenState();
}

class _FamilyLabResultsScreenState extends State<FamilyLabResultsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<FamilyLabResult> _allLabResults = [];
  List<FamilyLabResult> _newResults = [];
  List<FamilyLabResult> _allResults = [];
  bool _isLoading = true;
  String _selectedMemberFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLabResults();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLabResults() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _allLabResults = _generateLabResults();
        _newResults = _allLabResults.where((result) => result.isNew).toList();
        _allResults = _allLabResults;
        _isLoading = false;
      });
    });
  }

  List<FamilyLabResult> _generateLabResults() {
    return [
      FamilyLabResult(
        id: 'LAB_001',
        memberName: 'Siti Santoso',
        memberRelation: FamilyRelation.spouse,
        testDate: DateTime.now().subtract(const Duration(days: 1)),
        resultDate: DateTime.now().subtract(const Duration(hours: 6)),
        hospital: 'RS Siloam Hospitals',
        doctorName: 'Dr. Lisa Andriani, Sp.OG',
        testType: LabTestType.bloodTest,
        testName: 'Pemeriksaan Darah Lengkap',
        status: LabResultStatus.ready,
        isNew: true,
        results: [
          LabTestItem(
            name: 'Hemoglobin',
            value: '12.5',
            unit: 'g/dL',
            normalRange: '11.5-15.5',
            status: LabItemStatus.normal,
          ),
          LabTestItem(
            name: 'Leukosit',
            value: '8200',
            unit: '/μL',
            normalRange: '4000-11000',
            status: LabItemStatus.normal,
          ),
          LabTestItem(
            name: 'Trombosit',
            value: '320000',
            unit: '/μL',
            normalRange: '150000-450000',
            status: LabItemStatus.normal,
          ),
        ],
        notes: 'Hasil dalam batas normal. Kondisi kesehatan baik.',
      ),
      FamilyLabResult(
        id: 'LAB_002',
        memberName: 'Nenek Sari',
        memberRelation: FamilyRelation.grandparent,
        testDate: DateTime.now().subtract(const Duration(days: 3)),
        resultDate: DateTime.now().subtract(const Duration(days: 2)),
        hospital: 'RS Siloam Hospitals',
        doctorName: 'Dr. Sarah Wijaya, Sp.PD',
        testType: LabTestType.bloodSugar,
        testName: 'Gula Darah Puasa & 2 Jam PP',
        status: LabResultStatus.ready,
        isNew: false,
        results: [
          LabTestItem(
            name: 'Gula Darah Puasa',
            value: '145',
            unit: 'mg/dL',
            normalRange: '70-100',
            status: LabItemStatus.high,
          ),
          LabTestItem(
            name: 'Gula Darah 2 Jam PP',
            value: '185',
            unit: 'mg/dL',
            normalRange: '<140',
            status: LabItemStatus.high,
          ),
          LabTestItem(
            name: 'HbA1c',
            value: '7.2',
            unit: '%',
            normalRange: '<7.0',
            status: LabItemStatus.high,
          ),
        ],
        notes:
            'Kontrol gula darah masih perlu diperbaiki. Disarankan konsultasi dengan dokter.',
      ),
      FamilyLabResult(
        id: 'LAB_003',
        memberName: 'Ahmad Santoso',
        memberRelation: FamilyRelation.child,
        testDate: DateTime.now().subtract(const Duration(days: 7)),
        resultDate: DateTime.now().subtract(const Duration(days: 6)),
        hospital: 'RS Hermina Kemayoran',
        doctorName: 'Dr. Michael Chen, Sp.A',
        testType: LabTestType.immunology,
        testName: 'Pemeriksaan Hepatitis B Surface Antigen',
        status: LabResultStatus.ready,
        isNew: false,
        results: [
          LabTestItem(
            name: 'HBsAg',
            value: 'Non-Reaktif',
            unit: '',
            normalRange: 'Non-Reaktif',
            status: LabItemStatus.normal,
          ),
          LabTestItem(
            name: 'Anti-HBs',
            value: '125',
            unit: 'mIU/mL',
            normalRange: '>10',
            status: LabItemStatus.normal,
          ),
        ],
        notes:
            'Hasil negatif Hepatitis B. Antibodi protektif terbentuk dengan baik.',
      ),
      FamilyLabResult(
        id: 'LAB_004',
        memberName: 'Budi Santoso',
        memberRelation: FamilyRelation.self,
        testDate: DateTime.now().subtract(const Duration(days: 14)),
        resultDate: DateTime.now().subtract(const Duration(days: 13)),
        hospital: 'RS Harapan Kita',
        doctorName: 'Dr. Rahman Abdullah, Sp.JP',
        testType: LabTestType.lipidProfile,
        testName: 'Profil Lipid Lengkap',
        status: LabResultStatus.ready,
        isNew: false,
        results: [
          LabTestItem(
            name: 'Kolesterol Total',
            value: '185',
            unit: 'mg/dL',
            normalRange: '<200',
            status: LabItemStatus.normal,
          ),
          LabTestItem(
            name: 'LDL',
            value: '105',
            unit: 'mg/dL',
            normalRange: '<100',
            status: LabItemStatus.high,
          ),
          LabTestItem(
            name: 'HDL',
            value: '55',
            unit: 'mg/dL',
            normalRange: '>40',
            status: LabItemStatus.normal,
          ),
          LabTestItem(
            name: 'Trigliserida',
            value: '125',
            unit: 'mg/dL',
            normalRange: '<150',
            status: LabItemStatus.normal,
          ),
        ],
        notes:
            'LDL sedikit tinggi. Disarankan diet rendah lemak dan olahraga teratur.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingView() : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D89)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hasil Lab Keluarga',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Hasil pemeriksaan lab semua anggota keluarga',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showFilterDialog,
          icon: const Icon(Icons.filter_list, color: Color(0xFF2E7D89)),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF2E7D89),
        labelColor: const Color(0xFF2E7D89),
        unselectedLabelColor: const Color(0xFF7F8C8D),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Hasil Baru'),
                if (_newResults.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE74C3C),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _newResults.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'Semua Hasil'),
        ],
      ),
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
            'Memuat hasil lab...',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildNewResultsTab(),
        _buildAllResultsTab(),
      ],
    );
  }

  Widget _buildNewResultsTab() {
    final filteredResults = _getFilteredResults(_newResults);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        _loadLabResults();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (filteredResults.isEmpty) ...[
              _buildEmptyState(
                icon: Icons.science,
                title: 'Tidak ada hasil baru',
                subtitle: 'Semua hasil lab sudah dilihat',
              ),
            ] else ...[
              _buildNewResultsAlert(),
              const SizedBox(height: 20),
              ...filteredResults.map((result) => _buildLabResultCard(result)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllResultsTab() {
    final filteredResults = _getFilteredResults(_allResults);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        _loadLabResults();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 20),
            if (filteredResults.isEmpty) ...[
              _buildEmptyState(
                icon: Icons.science,
                title: 'Belum ada hasil lab',
                subtitle: 'Hasil lab keluarga akan muncul di sini',
              ),
            ] else ...[
              ...filteredResults.map((result) => _buildLabResultCard(result)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNewResultsAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.new_releases, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hasil Lab Baru Tersedia!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_newResults.length} hasil lab baru menunggu untuk dilihat',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _markAllAsRead,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2ECC71),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Tandai Sudah Dibaca',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalResults = _allResults.length;
    final newResultsCount = _newResults.length;
    final normalResults = _allResults
        .where((result) =>
            result.results.every((item) => item.status == LabItemStatus.normal))
        .length;
    final abnormalResults = totalResults - normalResults;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Hasil',
                value: totalResults.toString(),
                icon: Icons.science,
                color: const Color(0xFF3498DB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Hasil Baru',
                value: newResultsCount.toString(),
                icon: Icons.fiber_new,
                color: const Color(0xFF2ECC71),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Normal',
                value: normalResults.toString(),
                icon: Icons.check_circle,
                color: const Color(0xFF2ECC71),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Perlu Perhatian',
                value: abnormalResults.toString(),
                icon: Icons.warning,
                color: abnormalResults > 0
                    ? const Color(0xFFF39C12)
                    : const Color(0xFF95A5A6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResultCard(FamilyLabResult result) {
    final hasAbnormalValues =
        result.results.any((item) => item.status != LabItemStatus.normal);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isNew
              ? const Color(0xFF2ECC71)
              : hasAbnormalValues
                  ? const Color(0xFFF39C12).withOpacity(0.3)
                  : Colors.grey[200]!,
          width: result.isNew ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _getRelationColor(result.memberRelation)
                          .withOpacity(0.1),
                      child: Text(
                        result.memberName
                            .split(' ')
                            .map((e) => e[0])
                            .take(2)
                            .join(),
                        style: TextStyle(
                          color: _getRelationColor(result.memberRelation),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  result.memberName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                              if (result.isNew)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2ECC71),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'BARU',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            getFamilyRelationText(result.memberRelation),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            _getTestTypeColor(result.testType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTestTypeText(result.testType),
                        style: TextStyle(
                          color: _getTestTypeColor(result.testType),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result.testName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: Colors.grey[600], size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Diambil: ${_formatDate(result.testDate)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.assignment_turned_in,
                        color: Colors.grey[600], size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Hasil: ${_formatDate(result.resultDate)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.local_hospital,
                        color: Colors.grey[600], size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${result.hospital} • ${result.doctorName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Test Results Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.science, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Hasil Pemeriksaan:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const Spacer(),
                    _buildOverallStatus(result.results),
                  ],
                ),
                const SizedBox(height: 12),
                ...result.results
                    .take(3)
                    .map((item) => _buildTestItemPreview(item)),
                if (result.results.length > 3) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+${result.results.length - 3} parameter lainnya',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7F8C8D),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _viewMemberLabHistory(result.memberName),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3498DB)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Riwayat Lab',
                          style: TextStyle(
                            color: Color(0xFF3498DB),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _viewDetailLabResult(result),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D89),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Lihat Detail',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestItemPreview(LabTestItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${item.value} ${item.unit}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(item.status),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(item.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(item.status),
              color: _getStatusColor(item.status),
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatus(List<LabTestItem> results) {
    final hasAbnormal =
        results.any((item) => item.status != LabItemStatus.normal);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasAbnormal
            ? const Color(0xFFF39C12).withOpacity(0.1)
            : const Color(0xFF2ECC71).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasAbnormal ? Icons.warning : Icons.check_circle,
            color:
                hasAbnormal ? const Color(0xFFF39C12) : const Color(0xFF2ECC71),
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            hasAbnormal ? 'Perlu Perhatian' : 'Normal',
            style: TextStyle(
              color: hasAbnormal
                  ? const Color(0xFFF39C12)
                  : const Color(0xFF2ECC71),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
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

  // Helper methods
  List<FamilyLabResult> _getFilteredResults(List<FamilyLabResult> results) {
    if (_selectedMemberFilter == 'all') return results;
    return results
        .where((result) => result.memberName == _selectedMemberFilter)
        .toList();
  }

  Color _getTestTypeColor(LabTestType type) {
    switch (type) {
      case LabTestType.bloodTest:
        return const Color(0xFFE74C3C);
      case LabTestType.bloodSugar:
        return const Color(0xFF9B59B6);
      case LabTestType.lipidProfile:
        return const Color(0xFF3498DB);
      case LabTestType.immunology:
        return const Color(0xFF2ECC71);
      case LabTestType.urine:
        return const Color(0xFFF39C12);
      case LabTestType.other:
        return const Color(0xFF95A5A6);
    }
  }

  String _getTestTypeText(LabTestType type) {
    switch (type) {
      case LabTestType.bloodTest:
        return 'Darah';
      case LabTestType.bloodSugar:
        return 'Gula Darah';
      case LabTestType.lipidProfile:
        return 'Lipid';
      case LabTestType.immunology:
        return 'Imunologi';
      case LabTestType.urine:
        return 'Urine';
      case LabTestType.other:
        return 'Lainnya';
    }
  }

  Color _getStatusColor(LabItemStatus status) {
    switch (status) {
      case LabItemStatus.normal:
        return const Color(0xFF2ECC71);
      case LabItemStatus.high:
        return const Color(0xFFE74C3C);
      case LabItemStatus.low:
        return const Color(0xFF3498DB);
      case LabItemStatus.critical:
        return const Color(0xFF8E44AD);
    }
  }

  IconData _getStatusIcon(LabItemStatus status) {
    switch (status) {
      case LabItemStatus.normal:
        return Icons.check_circle;
      case LabItemStatus.high:
        return Icons.arrow_upward;
      case LabItemStatus.low:
        return Icons.arrow_downward;
      case LabItemStatus.critical:
        return Icons.warning;
    }
  }

  Color _getRelationColor(FamilyRelation relation) {
    switch (relation) {
      case FamilyRelation.self:
        return const Color(0xFF3498DB);
      case FamilyRelation.spouse:
        return const Color(0xFF9B59B6);
      case FamilyRelation.child:
        return const Color(0xFF2ECC71);
      case FamilyRelation.parent:
        return const Color(0xFF34495E);
      case FamilyRelation.grandparent:
        return const Color(0xFFE67E22);
      case FamilyRelation.sibling:
        return const Color(0xFF1ABC9C);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showFilterDialog() {
    final memberNames = [
      'all',
      ..._allResults.map((r) => r.memberName).toSet()
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Anggota Keluarga'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: memberNames
              .map(
                (name) => RadioListTile<String>(
                  title: Text(name == 'all' ? 'Semua Anggota' : name),
                  value: name,
                  groupValue: _selectedMemberFilter,
                  onChanged: (value) {
                    setState(() => _selectedMemberFilter = value!);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var result in _newResults) {
        result.isNew = false;
      }
      _newResults.clear();
    });
    _showSnackBar('Semua hasil lab ditandai sudah dibaca');
  }

  void _viewMemberLabHistory(String memberName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberLabHistoryScreen(memberName: memberName),
      ),
    );
  }

  void _viewDetailLabResult(FamilyLabResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LabResultDetailScreen(labResult: result),
      ),
    );
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

// Placeholder screens for member-specific views
class MemberLabHistoryScreen extends StatelessWidget {
  final String memberName;

  const MemberLabHistoryScreen({super.key, required this.memberName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Lab - $memberName'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D89),
      ),
      body: Center(
        child: Text('Riwayat lab untuk $memberName akan ditampilkan di sini'),
      ),
    );
  }
}

class LabResultDetailScreen extends StatelessWidget {
  final FamilyLabResult labResult;

  const LabResultDetailScreen({super.key, required this.labResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Lab - ${labResult.memberName}'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D89),
      ),
      body: Center(
        child: Text(
            'Detail hasil lab ${labResult.testName} akan ditampilkan di sini'),
      ),
    );
  }
}
