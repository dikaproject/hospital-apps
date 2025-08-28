import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../models/chat_models.dart';
import '../../models/consultation_models.dart';
import 'auto_queue_screen.dart';

class DoctorCallScreen extends StatefulWidget {
  final ConsultationResult consultationResult;

  const DoctorCallScreen({
    super.key,
    required this.consultationResult,
  });

  @override
  State<DoctorCallScreen> createState() => _DoctorCallScreenState();
}

class _DoctorCallScreenState extends State<DoctorCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  bool _isConnecting = true;
  bool _isCallActive = false;
  bool _isCallEnded = false;
  bool _isMuted = false;
  bool _isVideoOn = true;
  bool _doctorRecommendedHospital = false;

  Timer? _callTimer;
  Duration _callDuration = Duration.zero;

  final DoctorInfo _doctor = DoctorInfo(
    name: 'Dr. Sarah Wijaya, Sp.PD',
    specialty: 'Spesialis Penyakit Dalam',
    hospital: 'RS Mitra Keluarga',
    rating: 4.8,
    experience: '12 tahun',
    photoUrl: '', // Placeholder
  );

  final List<ChatMessage> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startConnection();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _pulseController.repeat(reverse: true);
  }

  void _startConnection() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isCallActive = true;
        });
        _fadeController.forward();
        _startCallTimer();
        _simulateDoctorMessages();
      }
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = Duration(seconds: timer.tick);
        });
      }
    });
  }

  void _simulateDoctorMessages() {
    // Simulate doctor's initial greeting
    Timer(const Duration(seconds: 2), () {
      _addDoctorMessage(
          "Selamat ${_getGreeting()}! Saya Dr. Sarah. Saya sudah melihat hasil konsultasi AI Anda.");
    });

    Timer(const Duration(seconds: 6), () {
      _addDoctorMessage(
          "Berdasarkan gejala yang Anda sampaikan, saya perlu melakukan pemeriksaan lebih lanjut.");
    });

    // Simulate doctor recommendation after some time
    Timer(const Duration(seconds: 12), () {
      if (widget.consultationResult.severity != ConsultationSeverity.low) {
        setState(() {
          _doctorRecommendedHospital = true;
        });
        _addDoctorMessage(
            "Saya merekomendasikan Anda untuk melakukan pemeriksaan fisik di rumah sakit. Saya akan buatkan antrean otomatis untuk Anda.");
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _callTimer?.cancel();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnecting) {
      return _buildConnectingScreen();
    } else if (_isCallActive && !_isCallEnded) {
      return _buildActiveCallScreen();
    } else {
      return _buildCallEndedScreen();
    }
  }

  // ... semua widget build methods tetap sama (tidak ada perubahan) ...
  // Copy semua method dari _buildConnectingScreen sampai _buildCallActions

  Widget _buildConnectingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E7D89), Color(0xFF4ECDC4)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF2E7D89).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _doctor.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _doctor.specialty,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Menghubungkan...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildCallActions(isConnecting: true),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCallScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildVideoArea(),
                    if (_doctorRecommendedHospital)
                      _buildHospitalRecommendationOverlay(),
                  ],
                ),
              ),
              _buildChatArea(),
              _buildCallActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallEndedScreen() {
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
          'Konsultasi Selesai',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Konsultasi Berhasil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Durasi: ${_formatDuration(_callDuration)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Konsultasi dengan ${_doctor.name} telah selesai.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_doctorRecommendedHospital) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pemeriksaan Lanjutan Diperlukan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Dokter merekomendasikan pemeriksaan fisik di rumah sakit',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _proceedToHospital,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF3498DB),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Ambil Antrean Rumah Sakit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2E7D89)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kembali ke Dashboard',
                  style: TextStyle(
                    color: Color(0xFF2E7D89),
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

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _endCall(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Spacer(),
          if (_isCallActive) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(_callDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  Widget _buildVideoArea() {
    return Stack(
      children: [
        // Doctor's video (main)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2E7D89), Color(0xFF1A535C)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _doctor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _doctor.specialty,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        // User's video (small, top-right)
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              color: _isVideoOn ? const Color(0xFF3498DB) : Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Icon(
                _isVideoOn ? Icons.person : Icons.videocam_off,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalRecommendationOverlay() {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_hospital,
                  color: Color(0xFF3498DB),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rekomendasi Dokter',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Pemeriksaan fisik di rumah sakit diperlukan untuk diagnosis yang lebih akurat.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _doctorRecommendedHospital = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7F8C8D)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Nanti',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _proceedToHospital,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Ambil Antrean',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.isUser ? 'Anda: ' : 'Dr. Sarah: ',
                        style: TextStyle(
                          color: message.isUser
                              ? const Color(0xFF4ECDC4)
                              : const Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _sendChatMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendChatMessage(_chatController.text),
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallActions({bool isConnecting = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            color: _isMuted ? Colors.red : Colors.white.withOpacity(0.3),
            onTap: isConnecting ? null : _toggleMute,
          ),
          _buildActionButton(
            icon: _isVideoOn ? Icons.videocam : Icons.videocam_off,
            color: _isVideoOn ? Colors.white.withOpacity(0.3) : Colors.red,
            onTap: isConnecting ? null : _toggleVideo,
          ),
          _buildActionButton(
            icon: Icons.call_end,
            color: Colors.red,
            onTap: _endCall,
            size: 60,
          ),
          _buildActionButton(
            icon: Icons.chat,
            color: Colors.white.withOpacity(0.3),
            onTap: isConnecting ? null : () {},
          ),
          _buildActionButton(
            icon: Icons.more_vert,
            color: Colors.white.withOpacity(0.3),
            onTap: isConnecting ? null : () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleVideo() {
    setState(() {
      _isVideoOn = !_isVideoOn;
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    setState(() {
      _isCallEnded = true;
    });
  }

  void _addDoctorMessage(String message) {
    if (mounted) {
      setState(() {
        _chatMessages.add(ChatMessage(text: message, isUser: false));
      });
    }
  }

  void _sendChatMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _chatMessages.add(ChatMessage(text: message, isUser: true));
    });
    _chatController.clear();
  }

  void _proceedToHospital() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AutoQueueScreen(
          consultationResult: widget.consultationResult,
          doctorRecommendation: DoctorRecommendation(
            doctorName: _doctor.name,
            specialty: _doctor.specialty,
            hospital: _doctor.hospital,
            urgency: widget.consultationResult.isUrgent ? 'Tinggi' : 'Sedang',
            notes: 'Pemeriksaan fisik diperlukan berdasarkan konsultasi online',
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'pagi';
    if (hour < 15) return 'siang';
    if (hour < 18) return 'sore';
    return 'malam';
  }
}