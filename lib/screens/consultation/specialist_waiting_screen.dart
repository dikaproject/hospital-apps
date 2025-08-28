import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../models/consultation_models.dart';
import 'doctor_call_screen.dart';

class SpecialistWaitingScreen extends StatefulWidget {
  final ConsultationResult consultationResult;
  final GeneralDoctorRecommendation generalDoctorRecommendation;

  const SpecialistWaitingScreen({
    super.key,
    required this.consultationResult,
    required this.generalDoctorRecommendation,
  });

  @override
  State<SpecialistWaitingScreen> createState() =>
      _SpecialistWaitingScreenState();
}

class _SpecialistWaitingScreenState extends State<SpecialistWaitingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  bool _isWaiting = true;
  int _queuePosition = 0;
  int _estimatedWaitTime = 0;
  Timer? _waitingTimer;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeWaiting();
    _startWaitingSimulation();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  void _initializeWaiting() {
    // Set initial queue position based on urgency
    if (widget.generalDoctorRecommendation.urgencyLevel == 'Tinggi') {
      _queuePosition = Random().nextInt(3) + 1; // 1-3 position
      _estimatedWaitTime = _queuePosition * 2; // 2-6 minutes
    } else {
      _queuePosition = Random().nextInt(8) + 3; // 3-10 position
      _estimatedWaitTime = _queuePosition * 3; // 9-30 minutes
    }
  }

  void _startWaitingSimulation() {
    // Update queue position every 30 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _queuePosition > 1) {
        setState(() {
          _queuePosition = max(1, _queuePosition - 1);
          _estimatedWaitTime = max(2, _estimatedWaitTime - 2);
        });
      }
    });

    // Simulate specialist becomes available
    int waitDuration =
        widget.generalDoctorRecommendation.urgencyLevel == 'Tinggi'
            ? Random().nextInt(60) + 30 // 30-90 seconds for urgent
            : Random().nextInt(120) + 60; // 60-180 seconds for normal

    _waitingTimer = Timer(Duration(seconds: waitDuration), () {
      if (mounted) {
        _connectToSpecialist();
      }
    });
  }

  void _connectToSpecialist() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorCallScreen(
          consultationResult: widget.consultationResult,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _waitingTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: _buildWaitingContent(),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.generalDoctorRecommendation.urgencyLevel == 'Tinggi'
                  ? Colors.red
                  : const Color(0xFF9B59B6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.generalDoctorRecommendation.urgencyLevel == 'Tinggi'
                  ? 'PRIORITAS TINGGI'
                  : 'MENUNGGU ANTREAN',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.generalDoctorRecommendation.urgencyLevel ==
                              'Tinggi'
                          ? [const Color(0xFFE74C3C), const Color(0xFFC0392B)]
                          : [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (widget.generalDoctorRecommendation.urgencyLevel ==
                                        'Tinggi'
                                    ? const Color(0xFFE74C3C)
                                    : const Color(0xFF9B59B6))
                                .withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Menunggu Dokter Spesialis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            widget.generalDoctorRecommendation.recommendedSpecialist,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Posisi Antrean',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#$_queuePosition',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Estimasi Waktu',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '~$_estimatedWaitTime menit',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rujukan dari:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.generalDoctorRecommendation.generalDoctorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.generalDoctorRecommendation.notes,
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
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.generalDoctorRecommendation.urgencyLevel == 'Tinggi'
                  ? Colors.red.withOpacity(0.2)
                  : const Color(0xFF3498DB).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    widget.generalDoctorRecommendation.urgencyLevel == 'Tinggi'
                        ? Colors.red
                        : const Color(0xFF3498DB),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.generalDoctorRecommendation.urgencyLevel == 'Tinggi'
                      ? Icons.priority_high
                      : Icons.info_outline,
                  color: widget.generalDoctorRecommendation.urgencyLevel ==
                          'Tinggi'
                      ? Colors.red
                      : const Color(0xFF3498DB),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.generalDoctorRecommendation.urgencyLevel == 'Tinggi'
                        ? 'Anda mendapat prioritas tinggi karena kondisi yang memerlukan penanganan segera'
                        : 'Dokter spesialis sedang menangani pasien lain. Mohon tunggu sebentar.',
                    style: TextStyle(
                      color: widget.generalDoctorRecommendation.urgencyLevel ==
                              'Tinggi'
                          ? Colors.red
                          : const Color(0xFF3498DB),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Batalkan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _showNotificationSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B59B6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Notifikasi',
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
          const SizedBox(height: 12),
          const Text(
            'Anda akan otomatis terhubung saat dokter tersedia',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pengaturan Notifikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading:
                  const Icon(Icons.notifications, color: Color(0xFF3498DB)),
              title: const Text('Notifikasi Push'),
              subtitle: const Text('Dapatkan notifikasi saat dokter tersedia'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF3498DB),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.vibration, color: Color(0xFF3498DB)),
              title: const Text('Getar'),
              subtitle: const Text('Getaran saat dokter memanggil'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF3498DB),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up, color: Color(0xFF3498DB)),
              title: const Text('Suara'),
              subtitle: const Text('Nada dering saat dokter memanggil'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF3498DB),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan',
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
    );
  }
}
