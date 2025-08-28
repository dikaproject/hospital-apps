import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/family_models.dart';
import '../../widgets/family_member_card.dart';
import '../../widgets/family_stats_widget.dart';
import '../../widgets/quick_action_widget.dart';
import 'family_qr_scanner_screen.dart'; // Fixed import
import 'family_schedule_screen.dart';
import 'family_medical_history_screen.dart';
import 'family_lab_results_screen.dart';

class FamilyDashboardScreen extends StatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<FamilyMember> _familyMembers = [];
  FamilyStats _familyStats = FamilyStats.empty();
  bool _isLoading = true;
  bool _isHeadOfFamily = true; // Current user status

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadFamilyData();
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

  void _loadFamilyData() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _familyMembers = _generateFamilyMembers();
        _familyStats = _generateFamilyStats();
        _isLoading = false;
      });
      _animationController.forward();
    });
  }

  List<FamilyMember> _generateFamilyMembers() {
    final random = Random();
    return [
      FamilyMember(
        id: 'FAM_001',
        name: 'Budi Santoso',
        relation: FamilyRelation.self,
        age: 45,
        gender: Gender.male,
        profileImage: '',
        isActive: true,
        lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
        upcomingAppointments: 1,
        pendingLabResults: 0,
        activeMedications: 2,
        healthStatus: HealthStatus.good,
        emergencyContact: true,
      ),
      FamilyMember(
        id: 'FAM_002',
        name: 'Siti Santoso',
        relation: FamilyRelation.spouse,
        age: 42,
        gender: Gender.female,
        profileImage: '',
        isActive: true,
        lastActivity: DateTime.now().subtract(const Duration(days: 1)),
        upcomingAppointments: 0,
        pendingLabResults: 1,
        activeMedications: 1,
        healthStatus: HealthStatus.good,
        emergencyContact: true,
      ),
      FamilyMember(
        id: 'FAM_003',
        name: 'Ahmad Santoso',
        relation: FamilyRelation.child,
        age: 16,
        gender: Gender.male,
        profileImage: '',
        isActive: false,
        lastActivity: DateTime.now().subtract(const Duration(days: 7)),
        upcomingAppointments: 1,
        pendingLabResults: 0,
        activeMedications: 0,
        healthStatus: HealthStatus.good,
        emergencyContact: false,
      ),
      FamilyMember(
        id: 'FAM_004',
        name: 'Nenek Sari',
        relation: FamilyRelation.grandparent,
        age: 78,
        gender: Gender.female,
        profileImage: '',
        isActive: true,
        lastActivity: DateTime.now().subtract(const Duration(hours: 6)),
        upcomingAppointments: 2,
        pendingLabResults: 1,
        activeMedications: 5,
        healthStatus: HealthStatus.needsAttention,
        emergencyContact: true,
      ),
    ];
  }

  FamilyStats _generateFamilyStats() {
    return FamilyStats(
      totalMembers: _familyMembers.length,
      activeMembers: _familyMembers.where((m) => m.isActive).length,
      upcomingAppointments:
          _familyMembers.fold(0, (sum, m) => sum + m.upcomingAppointments),
      pendingResults:
          _familyMembers.fold(0, (sum, m) => sum + m.pendingLabResults),
      activeMedications:
          _familyMembers.fold(0, (sum, m) => sum + m.activeMedications),
      emergencyContacts: _familyMembers.where((m) => m.emergencyContact).length,
    );
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
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingView() : _buildDashboardContent(),
      floatingActionButton: _isHeadOfFamily ? _buildAddMemberFAB() : null,
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
            'Family Dashboard',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Pantau kesehatan keluarga',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showFamilySettings,
          icon: const Icon(Icons.settings, color: Color(0xFF2E7D89)),
        ),
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(Icons.refresh, color: Color(0xFF2E7D89)),
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
            'Memuat data keluarga...',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF2E7D89),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              FamilyStatsWidget(stats: _familyStats),
              const SizedBox(height: 24),
              _buildQuickActionsSection(),
              const SizedBox(height: 24),
              _buildFamilyMembersSection(),
              const SizedBox(height: 24),
              _buildRecentActivitiesSection(),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final currentUser = _familyMembers.firstWhere(
      (member) => member.relation == FamilyRelation.self,
      orElse: () => _familyMembers.first,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D89), Color(0xFF1B5E6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D89).withOpacity(0.3),
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
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  currentUser.name.split(' ').map((e) => e[0]).take(2).join(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang, ${currentUser.name.split(' ').first}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isHeadOfFamily
                          ? 'Sebagai kepala keluarga'
                          : 'Anggota keluarga',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
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
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.family_restroom,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_familyMembers.length} anggota keluarga terdaftar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_familyStats.upcomingAppointments > 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF39C12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_familyStats.upcomingAppointments} jadwal',
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
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        QuickActionWidget(
          onAddMember: _addFamilyMember,
          onViewSchedules: _viewFamilySchedules,
          onViewLabResults: _viewFamilyLabResults,
          onEmergencyContact: _showEmergencyContacts,
          isHeadOfFamily: _isHeadOfFamily,
        ),
      ],
    );
  }

  Widget _buildFamilyMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Anggota Keluarga',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _viewAllMembers,
              icon:
                  const Icon(Icons.people, size: 16, color: Color(0xFF2E7D89)),
              label: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Color(0xFF2E7D89),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_familyMembers.isEmpty) ...[
          _buildEmptyFamilyState(),
        ] else ...[
          ...List.generate(
            _familyMembers.take(3).length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FamilyMemberCard(
                member: _familyMembers[index],
                onTap: () => _viewMemberDetail(_familyMembers[index]),
                isHeadOfFamily: _isHeadOfFamily,
              ),
            ),
          ),
          if (_familyMembers.length > 3) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+${_familyMembers.length - 3} anggota lainnya',
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward,
                      color: Color(0xFF7F8C8D), size: 16),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildEmptyFamilyState() {
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.family_restroom,
              color: Colors.grey[400],
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada anggota keluarga',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan anggota keluarga untuk memantau kesehatan mereka',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addFamilyMember,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambah Anggota'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D89),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    final recentActivities = _getRecentActivities();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terbaru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        if (recentActivities.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.timeline, color: Colors.grey[400], size: 32),
                const SizedBox(height: 12),
                Text(
                  'Belum ada aktivitas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...recentActivities
              .take(5)
              .map((activity) => _buildActivityItem(activity)),
        ],
      ],
    );
  }

  Widget _buildActivityItem(FamilyActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: _getActivityColor(activity.type),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTimeAgo(activity.timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF95A5A6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberFAB() {
    return FloatingActionButton.extended(
      onPressed: _addFamilyMember,
      backgroundColor: const Color(0xFF2E7D89),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Tambah Anggota'),
    );
  }

  // Action Methods
  void _addFamilyMember() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
            const SizedBox(height: 20),
            const Text(
              'Tambah Anggota Keluarga',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildAddMemberOption(
                    icon: Icons.qr_code_scanner,
                    title: 'Scan QR Keluarga',
                    subtitle: 'Scan kode QR dari anggota keluarga',
                    onTap: _scanFamilyQR,
                  ),
                  const SizedBox(height: 16),
                  _buildAddMemberOption(
                    icon: Icons.qr_code,
                    title: 'Tampilkan QR Saya',
                    subtitle: 'Biarkan anggota keluarga scan QR Anda',
                    onTap: _showMyQR,
                  ),
                  const SizedBox(height: 16),
                  _buildAddMemberOption(
                    icon: Icons.person_add,
                    title: 'Undang Manual',
                    subtitle: 'Undang menggunakan nomor HP atau email',
                    onTap: _inviteManually,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMemberOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D89).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D89), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF7F8C8D)),
          ],
        ),
      ),
    );
  }

  void _scanFamilyQR() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyQRScannerScreen(
          onFamilyQRScanned: _handleFamilyQRScanned,
        ),
      ),
    );
  }

  void _showMyQR() {
    Navigator.pop(context);
    _showSnackBar('Fitur tampilkan QR akan segera hadir!');
  }

  void _inviteManually() {
    Navigator.pop(context);
    _showSnackBar('Fitur undang manual akan segera hadir!');
  }

  void _handleFamilyQRScanned(String qrData) {
    // Process scanned QR and show confirmation dialog
    _showConfirmationDialog(qrData);
  }

  void _showConfirmationDialog(String qrData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Konfirmasi Penambahan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Masukkan kode konfirmasi yang ditampilkan di perangkat mereka:'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Kode konfirmasi (6 digit)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addMemberToFamily();
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  void _addMemberToFamily() {
    _showSnackBar('Anggota keluarga berhasil ditambahkan!');
    _refreshData();
  }

  void _viewMemberDetail(FamilyMember member) {
    _showSnackBar('Detail ${member.name} akan segera hadir!');
  }

  void _viewAllMembers() {
    _showSnackBar('Lihat semua anggota akan segera hadir!');
  }

  void _viewFamilySchedules() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FamilyScheduleScreen(),
      ),
    );
  }

  void _viewFamilyLabResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FamilyLabResultsScreen(),
      ),
    );
  }

  void _viewFamilyMedicalHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FamilyMedicalHistoryScreen(),
      ),
    );
  }

  void _showEmergencyContacts() {
    _showSnackBar('Kontak darurat akan segera hadir!');
  }

  void _showFamilySettings() {
    _showSnackBar('Pengaturan keluarga akan segera hadir!');
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _familyMembers = _generateFamilyMembers();
      _familyStats = _generateFamilyStats();
      _isLoading = false;
    });
  }

  // Helper methods
  List<FamilyActivity> _getRecentActivities() {
    return [
      FamilyActivity(
        id: 'ACT_001',
        type: ActivityType.appointment,
        title: 'Nenek Sari - Konsultasi Selesai',
        description: 'Pemeriksaan rutin dengan Dr. Sarah Wijaya',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        memberName: 'Nenek Sari',
      ),
      FamilyActivity(
        id: 'ACT_002',
        type: ActivityType.labResult,
        title: 'Siti Santoso - Hasil Lab Tersedia',
        description: 'Hasil pemeriksaan darah lengkap',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        memberName: 'Siti Santoso',
      ),
    ];
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.appointment:
        return const Color(0xFF3498DB);
      case ActivityType.labResult:
        return const Color(0xFF2ECC71);
      case ActivityType.medication:
        return const Color(0xFF9B59B6);
      case ActivityType.emergency:
        return const Color(0xFFE74C3C);
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.appointment:
        return Icons.event;
      case ActivityType.labResult:
        return Icons.science;
      case ActivityType.medication:
        return Icons.medication;
      case ActivityType.emergency:
        return Icons.emergency;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}h lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m lalu';
    } else {
      return 'Baru saja';
    }
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
