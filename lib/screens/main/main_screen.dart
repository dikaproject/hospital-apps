import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/queue_service.dart';
import '../auth/auth_screen.dart';
import '../queue/take_queue_screen.dart';
import '../qr/qr_show_screen.dart';
import '../schedule/schedule_screen.dart';
import '../history/medical_history_screen.dart';
import '../lab/lab_results_screen.dart';
import '../notifications/hospital_notifications_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/edit_profile_screen.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Dashboard data
  DashboardData? _dashboardData;
  bool _isLoading = true;
  String? _error;
  
  // Animation initialized flag
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardData();
  }

  void _setupAnimations() {
    try {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
      
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      
      _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
      );
      
      setState(() {
        _animationsInitialized = true;
      });
      
      _animationController.forward();
    } catch (e) {
      print('❌ Animation setup error: $e');
      // Fallback: Set flag to true to prevent errors
      setState(() {
        _animationsInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('🏠 Loading dashboard data...');
      final dashboardData = await DashboardService.getDashboardData();

      if (mounted) {
        setState(() {
          _dashboardData = dashboardData;
          _isLoading = false;
        });
      }

      print('✅ Dashboard data loaded successfully');
    } catch (e) {
      print('❌ Dashboard error: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });

        _showSnackBar('Gagal memuat data dashboard: ${e.toString()}');
      }
    }
  }

  Future<void> _refreshData() async {
    print('🔄 Refreshing dashboard data...');
    HapticFeedback.lightImpact();
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingScreen()
            : _error != null
                ? _buildErrorScreen()
                : _buildMainContent(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF667EEA),
            Color(0xFFF8FAFC),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Memuat dashboard...',
              style: TextStyle(
                color: Color(0xFF667EEA),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Koneksi Bermasalah',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Tidak dapat terhubung ke server',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7F8C8D),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF667EEA),
      backgroundColor: Colors.white,
      child: _animationsInitialized
          ? AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildHeroSection(),
                          _buildQuickActions(),
                          _buildMyQueueStatus(),
                          _buildFeatureGrid(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeroSection(),
                  _buildQuickActions(),
                  _buildMyQueueStatus(),
                  _buildFeatureGrid(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroSection() {
    final user = _dashboardData?.user;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
            Color(0xFF667EEA),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.fullName ?? 'Pasien HospitalLink',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatusPill('Pasien Aktif', Icons.verified_rounded),
                              if (user?.age != null) ...[
                                const SizedBox(width: 12),
                                _buildStatusPill('${user!.age} tahun', Icons.cake_rounded),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _buildModernHeaderButton(
                          icon: Icons.notifications_none_rounded,
                          badge: _dashboardData?.notifications.unreadCount ?? 0,
                          onTap: () => _showNotifications(),
                        ),
                        const SizedBox(height: 12),
                        _buildModernHeaderButton(
                          icon: Icons.person_outline_rounded,
                          onTap: () => _showProfile(),
                        ),
                      ],
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

  Widget _buildStatusPill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          if (badge != null && badge > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  badge > 99 ? '99+' : badge.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildModernActionCard(
              title: 'Ambil Antrean',
              subtitle: 'Buat antrean baru',
              icon: Icons.add_task_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
              ),
              onTap: () => _takeQueue(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildModernActionCard(
              title: 'Show QR',
              subtitle: 'Tampilkan kode QR',
              icon: Icons.qr_code_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _showQR(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyQueueStatus() {
    final queueStatus = _dashboardData?.queueStatus;
    
    if (queueStatus == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF56CCF2).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.spa_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Antrean Kosong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getMotivationalMessage(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _takeQueue,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ambil Antrean'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2F80ED),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }

    Color statusColor;
    switch (queueStatus.status) {
      case 'WAITING':
        statusColor = const Color(0xFFFFB74D);
        break;
      case 'CALLED':
        statusColor = const Color(0xFF81C784);
        break;
      case 'IN_PROGRESS':
        statusColor = const Color(0xFF64B5F6);
        break;
      default:
        statusColor = const Color(0xFFBDBDBD);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
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
              const Icon(
                Icons.schedule_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Status Antrean Saya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  queueStatus.statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nomor Antrean',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    queueStatus.queueNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Estimasi',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    queueStatus.estimatedTimeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  queueStatus.doctor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  queueStatus.doctor.specialty,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (queueStatus.position > 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Posisi: ${queueStatus.position} dari antrean',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewQueueDetails(queueStatus.id),
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: const Text('Detail'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _cancelQueue(queueStatus.id),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Batalkan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final stats = _dashboardData?.stats;
    final notifications = _dashboardData?.notifications;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildModernFeatureCard(
                  title: 'Jadwal Konsultasi',
                  icon: Icons.calendar_today_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
                  ),
                  onTap: () => _viewSchedule(),
                  badge: stats?.upcomingAppointments,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernFeatureCard(
                  title: 'Riwayat Kunjungan',
                  icon: Icons.history_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
                  ),
                  onTap: () => _viewMedicalHistory(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildModernFeatureCard(
                  title: 'Hasil Lab & Resep',
                  icon: Icons.science_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB347), Color(0xFFFFCC33)],
                  ),
                  onTap: () => _viewLabResults(),
                  badge: stats?.pendingLabResults,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernFeatureCard(
                  title: 'Notifikasi RS',
                  icon: Icons.notifications_active_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                  ),
                  onTap: () => _viewHospitalNotifications(),
                  badge: notifications?.unreadCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernFeatureCard({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (badge != null && badge > 0) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B6B).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      badge > 99 ? '99+' : badge.toString(),
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
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getMotivationalMessage() {
    final messages = [
      'Selamat beraktivitas! Jaga kesehatan selalu 💚',
      'Hari ini adalah kesempatan baru untuk hidup sehat!',
      'Kesehatan adalah investasi terbaik untuk masa depan',
      'Semangat! Jangan lupa istirahat yang cukup',
      'Hidup sehat dimulai dari kebiasaan kecil sehari-hari',
      'Stay healthy, stay happy! 😊',
      'Ingat minum air putih dan olahraga teratur ya!',
    ];
    
    final index = DateTime.now().day % messages.length;
    return messages[index];
  }

  // Action methods - keeping all existing functionality
  void _showNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HospitalNotificationsScreen(),
      ),
    );
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_rounded, color: Color(0xFF667EEA)),
              title: const Text('Edit Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded, color: Color(0xFF667EEA)),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Color(0xFFFF6B6B)),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _takeQueue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TakeQueueScreen(),
      ),
    );
  }

  void _showQR() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const QRShowScreen())
    );
  }

  void _viewQueueDetails(String queueId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF667EEA)),
        ),
      );

      final queueDetails = await QueueService.getQueueDetails(queueId);
      
      if (mounted) {
        Navigator.pop(context);

        if (queueDetails != null) {
          _showQueueDetailsDialog(queueDetails);
        } else {
          _showSnackBar('Gagal memuat detail antrean');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Error: ${e.toString()}');
      }
    }
  }

  void _showQueueDetailsDialog(Map<String, dynamic> queueDetails) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_rounded, color: Color(0xFF667EEA)),
            SizedBox(width: 8),
            Text('Detail Antrean'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nomor Antrean', queueDetails['queueNumber']),
              _buildDetailRow('Status', queueDetails['status']),
              _buildDetailRow('Posisi', '${queueDetails['position']} dari ${queueDetails['totalWaiting']}'),
              _buildDetailRow('Estimasi Tunggu', '~${queueDetails['estimatedWaitTime']} menit'),
              _buildDetailRow('Dokter', queueDetails['doctor']['name']),
              _buildDetailRow('Spesialisasi', queueDetails['doctor']['specialty']),
              _buildDetailRow('Tanggal', DateFormat('dd/MM/yyyy').format(DateTime.parse(queueDetails['queueDate']))),
              if (queueDetails['checkInTime'] != null)
                _buildDetailRow('Check-in', DateFormat('HH:mm').format(DateTime.parse(queueDetails['checkInTime']))),
              if (queueDetails['notes'] != null && queueDetails['notes'].isNotEmpty)
                _buildDetailRow('Catatan', queueDetails['notes']),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _cancelQueue(String queueId) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFFF6B6B)),
            SizedBox(width: 8),
            Text('Batalkan Antrean'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan antrean ini? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF667EEA)),
        ),
      );

      final success = await QueueService.cancelQueue(queueId, reason: 'Dibatalkan oleh pasien');
      
      if (mounted) {
        Navigator.pop(context);

        if (success) {
          _showSnackBar('Antrean berhasil dibatalkan');
          _refreshData();
        } else {
          _showSnackBar('Gagal membatalkan antrean');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Error: ${e.toString()}');
      }
    }
  }

  void _viewSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScheduleScreen(),
      ),
    );
  }

  void _viewMedicalHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicalHistoryScreen(),
      ),
    );
  }

  void _viewLabResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LabResultsScreen(),
      ),
    );
  }

  void _viewHospitalNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HospitalNotificationsScreen(),
      ),
    );
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal',
                  style: TextStyle(color: Color(0xFF7F8C8D))),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AuthService.logout();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  _showSnackBar('Gagal logout: ${e.toString()}');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}