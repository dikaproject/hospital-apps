import 'package:flutter/material.dart';
import '../../models/medical_history_models.dart';
import '../../services/medical_history_service.dart';
import '../../services/auth_service.dart';
import '../../models/consultation_models.dart'; 

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<MedicalHistoryItem> _allHistory = [];
  List<ConsultationHistory> _consultations = [];
  List<QueueHistory> _queues = [];
  List<PrescriptionHistory> _prescriptions = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  String? _error;

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

  Future<void> _loadMedicalHistory() async {
  try {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    print('🏥 Loading medical history from backend...');

    // Load combined medical history from backend
    final combinedData = await MedicalHistoryService.getCombinedMedicalHistory();
    
    print('📊 Received combined data: ${combinedData.keys}');
    
    // Clear existing data
    _consultations.clear();
    _queues.clear();
    _prescriptions.clear();
    
    // Parse consultations with error handling
    if (combinedData['consultations'] != null) {
      final consultationsData = combinedData['consultations'] as List;
      for (final consultationJson in consultationsData) {
        try {
          final consultation = ConsultationHistory.fromJson(
            consultationJson is Map<String, dynamic> 
                ? consultationJson 
                : Map<String, dynamic>.from(consultationJson as Map)
          );
          _consultations.add(consultation);
        } catch (e) {
          print('❌ Error parsing consultation: $e');
        }
      }
      print('💬 Loaded ${_consultations.length} consultations');
    }

    // Parse queues with error handling
    if (combinedData['queues'] != null) {
      final queuesData = combinedData['queues'] as List;
      for (final queueJson in queuesData) {
        try {
          final queue = QueueHistory.fromJson(
            queueJson is Map<String, dynamic> 
                ? queueJson 
                : Map<String, dynamic>.from(queueJson as Map)
          );
          _queues.add(queue);
        } catch (e) {
          print('❌ Error parsing queue: $e');
        }
      }
      print('🔢 Loaded ${_queues.length} queues');
    }

    // Parse prescriptions with error handling
    if (combinedData['prescriptions'] != null) {
      final prescriptionsData = combinedData['prescriptions'] as List;
      for (final prescriptionJson in prescriptionsData) {
        try {
          final prescription = PrescriptionHistory.fromJson(
            prescriptionJson is Map<String, dynamic> 
                ? prescriptionJson 
                : Map<String, dynamic>.from(prescriptionJson as Map)
          );
          _prescriptions.add(prescription);
        } catch (e) {
          print('❌ Error parsing prescription: $e');
        }
      }
      print('💊 Loaded ${_prescriptions.length} prescriptions');
    }

    // Combine all history items
    _combineHistoryItems();

    setState(() {
      _isLoading = false;
    });

    _animationController.forward();

  } catch (e) {
    print('❌ Error loading medical history: $e');
    setState(() {
      _isLoading = false;
      _error = 'Gagal memuat riwayat medis. Silakan coba lagi.';
    });
  }
}

  void _combineHistoryItems() {
    final List<MedicalHistoryItem> allItems = [];

    // Add consultations
    for (final consultation in _consultations) {
      allItems.add(MedicalHistoryItem.fromConsultation(consultation));
    }

    // Add queues
    for (final queue in _queues) {
      allItems.add(MedicalHistoryItem.fromQueue(queue));
    }

    // Add prescriptions
    for (final prescription in _prescriptions) {
      allItems.add(MedicalHistoryItem.fromPrescription(prescription));
    }

    // Sort by date (newest first)
    allItems.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _allHistory = allItems;
    });

    print('📋 Combined ${allItems.length} history items');
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
          'Riwayat Medis',
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_error != null) {
      return _buildErrorView();
    }

    return _buildHistoryView();
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

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat riwayat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Terjadi kesalahan',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMedicalHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D89),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
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
            _buildStatsRow(),
            Expanded(
              child: filteredHistory.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildHistoryCard(filteredHistory[index]),
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
    final filters = ['Semua', 'Konsultasi', 'Antrean', 'Resep', 'Bulan Ini'];

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
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildStatChip('Konsultasi', _consultations.length, Icons.chat, const Color(0xFF3498DB)),
          const SizedBox(width: 8),
          _buildStatChip('Antrean', _queues.length, Icons.queue, const Color(0xFF2ECC71)),
          const SizedBox(width: 8),
          _buildStatChip('Resep', _prescriptions.length, Icons.medication, const Color(0xFFF39C12)),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(MedicalHistoryItem item) {
    return GestureDetector(
      onTap: () => _showItemDetail(item),
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
                    color: _getHistoryTypeColor(item.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getHistoryTypeIcon(item.type),
                    color: _getHistoryTypeColor(item.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: _getStatusColor(item.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 14),
                const SizedBox(width: 6),
                Text(
                  _formatDate(item.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const Spacer(),
                Text(
                  _getHistoryTypeLabel(item.type),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getHistoryTypeColor(item.type),
                  ),
                ),
              ],
            ),
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
            'Belum ada riwayat medis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat konsultasi dan kunjungan Anda akan muncul di sini',
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

  void _showItemDetail(MedicalHistoryItem item) {
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
                child: _buildDetailContent(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(MedicalHistoryItem item) {
    switch (item.type) {
      case HistoryType.consultation:
        return _buildConsultationDetail(item.data['consultation'] as ConsultationHistory);
      case HistoryType.queue:
        return _buildQueueDetail(item.data['queue'] as QueueHistory);
      case HistoryType.prescription:
        return _buildPrescriptionDetail(item.data['prescription'] as PrescriptionHistory);
      default:
        return const Text('Detail tidak tersedia');
    }
  }

  Widget _buildConsultationDetail(ConsultationHistory consultation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Konsultasi',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 20),
        _buildDetailSection('Informasi Konsultasi', [
          _buildDetailRow('Tanggal', _formatDate(consultation.date)),
          _buildDetailRow('Jenis', consultation.type == 'AI' ? 'Konsultasi AI' : 'Konsultasi Dokter'),
          _buildDetailRow('Dokter/AI', consultation.doctorName),
          _buildDetailRow('Status', consultation.status),
          if (consultation.fee != null)
            _buildDetailRow('Biaya', _formatCurrency(consultation.fee!.toInt())),
        ]),
        _buildDetailSection('Ringkasan', [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              consultation.summary,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2C3E50),
                height: 1.4,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 24),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildQueueDetail(QueueHistory queue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Antrean',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 20),
        _buildDetailSection('Informasi Antrean', [
          _buildDetailRow('Tanggal', _formatDate(queue.date)),
          _buildDetailRow('Nomor Antrean', queue.queueNumber),
          _buildDetailRow('Dokter', queue.doctorName),
          _buildDetailRow('Spesialisasi', queue.specialty),
          _buildDetailRow('Status', queue.status),
          if (queue.checkInTime != null)
            _buildDetailRow('Waktu Check-in', _formatTime(queue.checkInTime!)),
          if (queue.completedTime != null)
            _buildDetailRow('Waktu Selesai', _formatTime(queue.completedTime!)),
          if (queue.waitTime != null)
            _buildDetailRow('Waktu Tunggu', '${queue.waitTime} menit'),
        ]),
        const SizedBox(height: 24),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildPrescriptionDetail(PrescriptionHistory prescription) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Resep',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 20),
        _buildDetailSection('Informasi Resep', [
          _buildDetailRow('Tanggal', _formatDate(prescription.date)),
          _buildDetailRow('Kode Resep', prescription.prescriptionCode),
          _buildDetailRow('Dokter', prescription.doctorName),
          _buildDetailRow('Total Biaya', _formatCurrency(prescription.totalAmount.toInt())),
          _buildDetailRow('Status Pengambilan', prescription.isDispensed ? 'Sudah Diambil' : 'Belum Diambil'),
          if (prescription.dispensedAt != null)
            _buildDetailRow('Waktu Pengambilan', _formatDate(prescription.dispensedAt!)),
        ]),
        _buildDetailSection('Daftar Obat', prescription.medications.map((med) => 
          Container(
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
                    med,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).toList()),
        const SizedBox(height: 24),
        _buildCloseButton(),
      ],
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

  Widget _buildCloseButton() {
    return SizedBox(
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
            ListTile(
              leading: const Icon(Icons.all_inclusive, color: Color(0xFF7F8C8D)),
              title: const Text('Semua Riwayat'),
              onTap: () {
                setState(() => _selectedFilter = 'Semua');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF3498DB)),
              title: const Text('Konsultasi'),
              onTap: () {
                setState(() => _selectedFilter = 'Konsultasi');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue, color: Color(0xFF2ECC71)),
              title: const Text('Antrean'),
              onTap: () {
                setState(() => _selectedFilter = 'Antrean');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication, color: Color(0xFFF39C12)),
              title: const Text('Resep'),
              onTap: () {
                setState(() => _selectedFilter = 'Resep');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshHistory() async {
    await _loadMedicalHistory();
  }

  List<MedicalHistoryItem> _getFilteredHistory() {
    if (_selectedFilter == 'Semua') return _allHistory;

    return _allHistory.where((item) {
      switch (_selectedFilter) {
        case 'Konsultasi':
          return item.type == HistoryType.consultation;
        case 'Antrean':
          return item.type == HistoryType.queue;
        case 'Resep':
          return item.type == HistoryType.prescription;
        case 'Bulan Ini':
          final now = DateTime.now();
          return item.date.year == now.year && item.date.month == now.month;
        default:
          return true;
      }
    }).toList();
  }

  // Helper methods
  Color _getHistoryTypeColor(HistoryType type) {
    switch (type) {
      case HistoryType.consultation:
        return const Color(0xFF3498DB);
      case HistoryType.queue:
        return const Color(0xFF2ECC71);
      case HistoryType.prescription:
        return const Color(0xFFF39C12);
      case HistoryType.medicalRecord:
        return const Color(0xFF9B59B6);
    }
  }

  IconData _getHistoryTypeIcon(HistoryType type) {
    switch (type) {
      case HistoryType.consultation:
        return Icons.chat;
      case HistoryType.queue:
        return Icons.queue;
      case HistoryType.prescription:
        return Icons.medication;
      case HistoryType.medicalRecord:
        return Icons.medical_services;
    }
  }

  String _getHistoryTypeLabel(HistoryType type) {
    switch (type) {
      case HistoryType.consultation:
        return 'Konsultasi';
      case HistoryType.queue:
        return 'Antrean';
      case HistoryType.prescription:
        return 'Resep';
      case HistoryType.medicalRecord:
        return 'Rekam Medis';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'lunas':
      case 'sudah diambil':
        return const Color(0xFF2ECC71);
      case 'berlangsung':
      case 'menunggu':
      case 'pending':
        return const Color(0xFFF39C12);
      case 'dibatalkan':
      case 'gagal':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

    final day = days[date.weekday % 7];
    final dayNum = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    return '$day, $dayNum $month $year';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}