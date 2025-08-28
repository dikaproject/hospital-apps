import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../models/consultation_models.dart';
import '../queue/queue_detail_screen.dart';

class AutoQueueScreen extends StatefulWidget {
  final ConsultationResult consultationResult;
  final DoctorRecommendation doctorRecommendation;

  const AutoQueueScreen({
    super.key,
    required this.consultationResult,
    required this.doctorRecommendation,
  });

  @override
  State<AutoQueueScreen> createState() => _AutoQueueScreenState();
}

class _AutoQueueScreenState extends State<AutoQueueScreen>
    with TickerProviderStateMixin {
  late AnimationController _processingController;
  late AnimationController _successController;
  late Animation<double> _processingAnimation;
  late Animation<double> _successAnimation;

  bool _isProcessing = true;
  bool _queueCreated = false;
  QueueInfo? _queueInfo;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _processAutoQueue();
  }

  void _setupAnimations() {
    _processingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _processingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _processingController, curve: Curves.easeInOut),
    );
    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _processingController.repeat();
  }

  void _processAutoQueue() {
    // Simulate auto queue creation process
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _processingController.stop();
        setState(() {
          _isProcessing = false;
          _queueCreated = true;
          _queueInfo = _generateQueueInfo();
        });
        _successController.forward();
      }
    });
  }

  QueueInfo _generateQueueInfo() {
    final random = Random();
    final queueNumber = random.nextInt(50) + 1;
    final estimatedTime = random.nextInt(45) + 15; // 15-60 minutes

    return QueueInfo(
      queueNumber: 'A${queueNumber.toString().padLeft(2, '0')}',
      estimatedWaitTime: estimatedTime,
      currentNumber:
          'A${(queueNumber - random.nextInt(5) - 1).toString().padLeft(2, '0')}',
      totalInQueue: random.nextInt(20) + queueNumber,
      doctorName: widget.doctorRecommendation.doctorName,
      specialty: widget.doctorRecommendation.specialty,
      hospital: widget.doctorRecommendation.hospital,
      appointmentTime: DateTime.now().add(Duration(minutes: estimatedTime)),
      consultationId:
          'HLK${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );
  }

  @override
  void dispose() {
    _processingController.dispose();
    _successController.dispose();
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
          'Antrean Otomatis',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isProcessing ? _buildProcessingView() : _buildSuccessView(),
    );
  }

  Widget _buildProcessingView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildProcessingAnimation(),
          const SizedBox(height: 40),
          _buildProcessingSteps(),
          const Spacer(),
          _buildDoctorRecommendationCard(),
        ],
      ),
    );
  }

  Widget _buildProcessingAnimation() {
    return Center(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _processingAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2E7D89).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _processingAnimation.value,
                      strokeWidth: 4,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E7D89)),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2E7D89), Color(0xFF4ECDC4)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Membuat Antrean Otomatis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Berdasarkan rekomendasi dokter',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingSteps() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proses Otomatis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          _buildProcessStep(
            icon: Icons.check_circle,
            title: 'Menganalisis rekomendasi dokter',
            isCompleted: true,
          ),
          _buildProcessStep(
            icon: Icons.schedule,
            title: 'Mencari slot tersedia',
            isCompleted: true,
          ),
          _buildProcessStep(
            icon: Icons.assignment,
            title: 'Membuat antrean prioritas',
            isCompleted: false,
            isActive: true,
          ),
          _buildProcessStep(
            icon: Icons.notifications,
            title: 'Mengirim konfirmasi',
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep({
    required IconData icon,
    required String title,
    required bool isCompleted,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF2ECC71)
                  : isActive
                      ? const Color(0xFF3498DB)
                      : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted || isActive ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isCompleted || isActive
                    ? const Color(0xFF2C3E50)
                    : const Color(0xFF7F8C8D),
              ),
            ),
          ),
          if (isActive) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDoctorRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Rekomendasi Dokter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendationItem(
              'Dokter', widget.doctorRecommendation.doctorName),
          _buildRecommendationItem(
              'Spesialis', widget.doctorRecommendation.specialty),
          _buildRecommendationItem(
              'Rumah Sakit', widget.doctorRecommendation.hospital),
          _buildRecommendationItem(
              'Tingkat Urgensi', widget.doctorRecommendation.urgency),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSuccessAnimation(),
          const SizedBox(height: 30),
          _buildQueueInfoCard(),
          const SizedBox(height: 20),
          _buildQueueDetailsCard(),
          const SizedBox(height: 20),
          _buildImportantNotesCard(),
          const SizedBox(height: 30),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return AnimatedBuilder(
      animation: _successAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _successAnimation.value,
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Antrean Berhasil Dibuat!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Antrean prioritas telah disiapkan',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQueueInfoCard() {
    if (_queueInfo == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
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
                    'Nomor Antrean',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _queueInfo!.queueNumber,
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
                    'Estimasi Tunggu',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '~${_queueInfo!.estimatedWaitTime} menit',
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Perkiraan dipanggil: ${_formatTime(_queueInfo!.appointmentTime)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueDetailsCard() {
    if (_queueInfo == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Antrean',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailItem('ID Konsultasi', _queueInfo!.consultationId),
          _buildDetailItem('Dokter', _queueInfo!.doctorName),
          _buildDetailItem('Spesialis', _queueInfo!.specialty),
          _buildDetailItem('Rumah Sakit', _queueInfo!.hospital),
          _buildDetailItem('Antrean Saat Ini', _queueInfo!.currentNumber),
          _buildDetailItem(
              'Total Antrean', '${_queueInfo!.totalInQueue} pasien'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.priority_high,
                  color: Color(0xFF2ECC71),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Antrean Prioritas - Berdasarkan konsultasi online',
                    style: TextStyle(
                      color: Color(0xFF27AE60),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7F8C8D),
                fontSize: 14,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF9800), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFFFF9800),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Informasi Penting',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNoteItem('Datang 15 menit sebelum jadwal'),
          _buildNoteItem('Bawa identitas dan kartu BPJS (jika ada)'),
          _buildNoteItem(
              'Siapkan riwayat medis dan obat yang sedang dikonsumsi'),
          _buildNoteItem('Antrean dapat berubah sesuai kondisi darurat'),
          _buildNoteItem('Simpan ID konsultasi untuk referensi'),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFFFF9800),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _viewQueueDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D89),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.visibility, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Lihat Detail Antrean',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _shareQueue,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3498DB)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Bagikan',
                  style: TextStyle(
                    color: Color(0xFF3498DB),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF7F8C8D)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _viewQueueDetail() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QueueDetailScreen(
          queueNumber: _queueInfo!.queueNumber,
          isFromAutoQueue: true,
        ),
      ),
    );
  }

  void _saveToCalendar() {
    _showSnackBar('Antrean berhasil disimpan ke kalender!');
  }

  void _shareQueue() {
    _showSnackBar('Fitur bagikan akan segera hadir!');
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
