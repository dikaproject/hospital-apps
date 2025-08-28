import 'package:flutter/material.dart';
import '../../models/family_models.dart';
import '../../models/medical_history_models.dart';

class FamilyMedicalHistoryScreen extends StatefulWidget {
  const FamilyMedicalHistoryScreen({super.key});

  @override
  State<FamilyMedicalHistoryScreen> createState() =>
      _FamilyMedicalHistoryScreenState();
}

class _FamilyMedicalHistoryScreenState
    extends State<FamilyMedicalHistoryScreen> {
  List<FamilyMedicalRecord> _medicalRecords = [];
  bool _isLoading = true;
  String _selectedMemberFilter = 'all';
  String _selectedTypeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMedicalHistory();
  }

  void _loadMedicalHistory() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _medicalRecords = _generateMedicalRecords();
        _isLoading = false;
      });
    });
  }

  List<FamilyMedicalRecord> _generateMedicalRecords() {
    return [
      FamilyMedicalRecord(
        id: 'MED_001',
        memberName: 'Nenek Sari',
        memberRelation: FamilyRelation.grandparent,
        date: DateTime.now().subtract(const Duration(days: 7)),
        type: MedicalRecordType.consultation,
        doctorName: 'Dr. Sarah Wijaya, Sp.PD',
        hospital: 'RS Siloam Hospitals',
        diagnosis: 'Diabetes Mellitus Type 2, Hipertensi',
        treatment: 'Metformin 500mg 2x1, Amlodipine 5mg 1x1',
        notes: 'Pasien dalam kondisi stabil, kontrol gula darah baik',
        nextCheckup: DateTime.now().add(const Duration(days: 30)),
      ),
      FamilyMedicalRecord(
        id: 'MED_002',
        memberName: 'Ahmad Santoso',
        memberRelation: FamilyRelation.child,
        date: DateTime.now().subtract(const Duration(days: 14)),
        type: MedicalRecordType.vaccination,
        doctorName: 'Dr. Michael Chen, Sp.A',
        hospital: 'RS Hermina Kemayoran',
        diagnosis: 'Imunisasi Hepatitis B',
        treatment: 'Vaksin Hepatitis B dosis ke-2',
        notes: 'Tidak ada reaksi alergi, jadwal vaksin berikutnya 6 bulan',
        nextCheckup: DateTime.now().add(const Duration(days: 180)),
      ),
      FamilyMedicalRecord(
        id: 'MED_003',
        memberName: 'Budi Santoso',
        memberRelation: FamilyRelation.self,
        date: DateTime.now().subtract(const Duration(days: 30)),
        type: MedicalRecordType.checkup,
        doctorName: 'Dr. Rahman Abdullah, Sp.JP',
        hospital: 'RS Harapan Kita',
        diagnosis: 'Medical Check Up - Normal',
        treatment: 'Tidak ada pengobatan khusus',
        notes: 'Hasil pemeriksaan dalam batas normal, anjuran olahraga teratur',
        nextCheckup: DateTime.now().add(const Duration(days: 365)),
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
            'Riwayat Medis Keluarga',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Riwayat medis semua anggota keluarga',
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
            'Memuat riwayat medis...',
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
    final filteredRecords = _getFilteredRecords();

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        _loadMedicalHistory();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 20),
            if (filteredRecords.isEmpty) ...[
              _buildEmptyState(),
            ] else ...[
              ...filteredRecords
                  .map((record) => _buildMedicalRecordCard(record)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalRecords = _medicalRecords.length;
    final recentRecords = _medicalRecords.where((record) {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      return record.date.isAfter(thirtyDaysAgo);
    }).length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Riwayat',
            value: totalRecords.toString(),
            icon: Icons.medical_services,
            color: const Color(0xFF3498DB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Bulan Ini',
            value: recentRecords.toString(),
            icon: Icons.calendar_today,
            color: const Color(0xFF2ECC71),
          ),
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

  Widget _buildMedicalRecordCard(FamilyMedicalRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getTypeColor(record.type).withOpacity(0.3),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    _getRelationColor(record.memberRelation).withOpacity(0.1),
                child: Text(
                  record.memberName.split(' ').map((e) => e[0]).take(2).join(),
                  style: TextStyle(
                    color: _getRelationColor(record.memberRelation),
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
                    Text(
                      record.memberName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      getFamilyRelationText(record.memberRelation),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(record.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTypeText(record.type),
                  style: TextStyle(
                    color: _getTypeColor(record.type),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: Colors.grey[600], size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(record.date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.local_hospital,
                        color: Colors.grey[600], size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        record.hospital,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7F8C8D),
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[600], size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        record.doctorName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoSection(
              'Diagnosis', record.diagnosis, Icons.local_hospital),
          const SizedBox(height: 8),
          _buildInfoSection('Pengobatan', record.treatment, Icons.medication),
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoSection('Catatan', record.notes, Icons.note),
          ],
          if (record.nextCheckup != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: Color(0xFF3498DB), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Kontrol berikutnya: ${_formatDate(record.nextCheckup!)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF3498DB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 14),
        const SizedBox(width: 6),
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
          Icon(Icons.medical_services, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat medis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat medis keluarga akan muncul di sini',
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
  List<FamilyMedicalRecord> _getFilteredRecords() {
    var filtered = _medicalRecords;

    if (_selectedMemberFilter != 'all') {
      filtered = filtered
          .where((record) => record.memberName == _selectedMemberFilter)
          .toList();
    }

    if (_selectedTypeFilter != 'all') {
      filtered = filtered
          .where((record) =>
              _getTypeText(record.type).toLowerCase() == _selectedTypeFilter)
          .toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  Color _getTypeColor(MedicalRecordType type) {
    switch (type) {
      case MedicalRecordType.consultation:
        return const Color(0xFF3498DB);
      case MedicalRecordType.checkup:
        return const Color(0xFF2ECC71);
      case MedicalRecordType.vaccination:
        return const Color(0xFF9B59B6);
      case MedicalRecordType.emergency:
        return const Color(0xFFE74C3C);
      case MedicalRecordType.surgery:
        return const Color(0xFFF39C12);
    }
  }

  String _getTypeText(MedicalRecordType type) {
    switch (type) {
      case MedicalRecordType.consultation:
        return 'Konsultasi';
      case MedicalRecordType.checkup:
        return 'Pemeriksaan';
      case MedicalRecordType.vaccination:
        return 'Vaksinasi';
      case MedicalRecordType.emergency:
        return 'Darurat';
      case MedicalRecordType.surgery:
        return 'Operasi';
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Riwayat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Anggota Keluarga:'),
            DropdownButton<String>(
              value: _selectedMemberFilter,
              isExpanded: true,
              items:
                  ['all', ..._medicalRecords.map((r) => r.memberName).toSet()]
                      .map((name) => DropdownMenuItem(
                            value: name,
                            child: Text(name == 'all' ? 'Semua' : name),
                          ))
                      .toList(),
              onChanged: (value) {
                setState(() => _selectedMemberFilter = value!);
              },
            ),
            const SizedBox(height: 16),
            const Text('Jenis Perawatan:'),
            DropdownButton<String>(
              value: _selectedTypeFilter,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Semua')),
                DropdownMenuItem(
                    value: 'konsultasi', child: Text('Konsultasi')),
                DropdownMenuItem(
                    value: 'pemeriksaan', child: Text('Pemeriksaan')),
                DropdownMenuItem(value: 'vaksinasi', child: Text('Vaksinasi')),
              ],
              onChanged: (value) {
                setState(() => _selectedTypeFilter = value!);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
