import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../models/queue_models.dart';

class QueueDetailScreen extends StatefulWidget {
  final String? queueNumber;
  final bool isFromAutoQueue;

  const QueueDetailScreen({
    super.key,
    this.queueNumber,
    this.isFromAutoQueue = false,
  });

  @override
  State<QueueDetailScreen> createState() => _QueueDetailScreenState();
}

class _QueueDetailScreenState extends State<QueueDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  Timer? _updateTimer;
  QueueDetailInfo? _queueInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadQueueDetails();
    _startRealTimeUpdates();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _loadQueueDetails() {
    // Simulate loading queue details
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _queueInfo = _generateQueueInfo();
          _isLoading = false;
        });
        _progressController.forward();
      }
    });
  }

  void _startRealTimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _queueInfo != null) {
        setState(() {
          // Update queue position and estimated time
          if (_queueInfo!.position > 1) {
            _queueInfo = _queueInfo!.copyWith(
              position: max(1, _queueInfo!.position - Random().nextInt(2)),
              estimatedWaitTime:
                  max(5, _queueInfo!.estimatedWaitTime - Random().nextInt(5)),
              currentNumber: _generateCurrentNumber(),
            );
          }
        });
      }
    });
  }

  QueueDetailInfo _generateQueueInfo() {
    final random = Random();
    final queueNumber = widget.queueNumber ?? 'A${random.nextInt(50) + 1}';
    final position = random.nextInt(15) + 1;
    final totalQueue = position + random.nextInt(20) + 10;

    return QueueDetailInfo(
      queueNumber: queueNumber,
      currentNumber: _generateCurrentNumber(),
      status: QueueStatus.waiting,
      doctorName: 'Dr. Sarah Wijaya, Sp.PD',
      specialty: 'Spesialis Penyakit Dalam',
      hospital: 'RS Mitra Keluarga',
      room: 'Ruang Konsultasi A-1',
      estimatedWaitTime: position * 15 + random.nextInt(10),
      remainingQueue: position,
      appointmentTime: DateTime.now().add(Duration(minutes: position * 15)),
      consultationId: widget.isFromAutoQueue
          ? 'HLK${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
          : null,
      isPriority: widget.isFromAutoQueue,
      // Tambahan field yang dibutuhkan
      position: position,
      totalQueue: totalQueue,
      createdAt: DateTime.now().subtract(Duration(minutes: random.nextInt(30))),
      estimatedCallTime: DateTime.now().add(Duration(minutes: position * 15)),
      isFromOnlineConsultation: widget.isFromAutoQueue,
    );
  }

  String _generateCurrentNumber() {
    final random = Random();
    final currentNum =
        max(1, (_queueInfo?.position ?? 5) - random.nextInt(3) - 1);
    return 'A${currentNum.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _updateTimer?.cancel();
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
          'Detail Antrean',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _shareQueue,
            icon: const Icon(Icons.share, color: Color(0xFF2E7D89)),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildDetailView(),
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
            'Memuat detail antrean...',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    if (_queueInfo == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildQueueStatusCard(),
          const SizedBox(height: 20),
          _buildQueueProgressCard(),
          const SizedBox(height: 20),
          _buildDoctorInfoCard(),
          const SizedBox(height: 20),
          _buildLocationInfoCard(),
          if (_queueInfo!.isFromOnlineConsultation) ...[
            const SizedBox(height: 20),
            _buildConsultationRefCard(),
          ],
          const SizedBox(height: 20),
          _buildEstimatedTimeCard(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildQueueStatusCard() {
    Color statusColor = _getStatusColor(_queueInfo!.status);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _queueInfo!.status == QueueStatus.waiting
              ? _pulseAnimation.value
              : 1.0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
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
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(_queueInfo!.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child:
                          _buildInfoItem('Posisi', '${_queueInfo!.position}'),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                          'Estimasi', '~${_queueInfo!.estimatedWaitTime} mnt'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueProgressCard() {
    double progress = (_queueInfo!.totalQueue - _queueInfo!.position) /
        _queueInfo!.totalQueue;

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
          Row(
            children: [
              const Icon(
                Icons.timeline,
                color: Color(0xFF3498DB),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Progress Antrean',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3498DB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: progress * _progressAnimation.value,
                backgroundColor: Colors.grey[200],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                minHeight: 8,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sekarang dipanggil',
                    style: TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _queueInfo!.currentNumber,
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total antrean',
                    style: TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${_queueInfo!.totalQueue} pasien',
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoCard() {
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
          const Row(
            children: [
              Icon(
                Icons.medical_services,
                color: Color(0xFF2ECC71),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Informasi Dokter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _queueInfo!.doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _queueInfo!.specialty,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber[600],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '(150+ ulasan)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfoCard() {
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
          const Row(
            children: [
              Icon(
                Icons.location_on,
                color: Color(0xFFE74C3C),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Lokasi Konsultasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationItem('Rumah Sakit', _queueInfo!.hospital),
          _buildLocationItem('Ruangan', _queueInfo!.room),
          _buildLocationItem('Lantai', '2 - Gedung Utama'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF1976D2),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Harap datang 15 menit sebelum jadwal konsultasi',
                    style: TextStyle(
                      color: Color(0xFF1976D2),
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

  Widget _buildLocationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
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

  Widget _buildConsultationRefCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
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
                Icons.online_prediction,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Referensi Konsultasi Online',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Konsultasi: ${_queueInfo!.consultationId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Antrean prioritas berdasarkan hasil konsultasi AI dan rekomendasi dokter online',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedTimeCard() {
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
          const Row(
            children: [
              Icon(
                Icons.schedule,
                color: Color(0xFFFF9800),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Perkiraan Waktu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  'Antrean dibuat',
                  _formatTime(_queueInfo!.createdAt),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildTimeInfo(
                  'Perkiraan dipanggil',
                  _formatTime(_queueInfo!.estimatedCallTime),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7F8C8D),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _rescheduleQueue,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3498DB)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reschedule',
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
              child: ElevatedButton(
                onPressed: _cancelQueue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Batalkan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _enableNotifications,
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
                Icon(Icons.notifications_active, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Aktifkan Notifikasi',
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
      ],
    );
  }

  Color _getStatusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
        return const Color(0xFF3498DB);
      case QueueStatus.called:
        return const Color(0xFFFF9800);
      case QueueStatus.inProgress:
        return const Color(0xFF2ECC71);
      case QueueStatus.completed:
        return const Color(0xFF27AE60);
      case QueueStatus.cancelled:
        return const Color(0xFFE74C3C);
    }
  }

  String _getStatusText(QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
        return 'MENUNGGU';
      case QueueStatus.called:
        return 'DIPANGGIL';
      case QueueStatus.inProgress:
        return 'BERLANGSUNG';
      case QueueStatus.completed:
        return 'SELESAI';
      case QueueStatus.cancelled:
        return 'DIBATALKAN';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _shareQueue() {
    _showSnackBar('Berbagi detail antrean...');
  }

  void _rescheduleQueue() {
    _showSnackBar('Fitur reschedule akan segera hadir!');
  }

  void _cancelQueue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Batalkan Antrean'),
        content: const Text('Apakah Anda yakin ingin membatalkan antrean ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              _showSnackBar('Antrean berhasil dibatalkan');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
            ),
            child:
                const Text('Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _enableNotifications() {
    _showSnackBar('Notifikasi antrean telah diaktifkan!');
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
