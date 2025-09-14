import 'package:flutter/material.dart';
import '../../models/schedule_models.dart' as schedule_models;
import '../../models/consultation_models.dart';
import '../../services/schedule_service.dart';
import '../../services/auth_service.dart';
import '../queue/queue_detail_screen.dart';
import '../consultation/chat_consultation_screen.dart';
import '../../widgets/qr_code_widget.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Use the ConsultationSchedule from consultation_models.dart
  List<ConsultationSchedule> _activeSchedules = [];
  List<ConsultationSchedule> _upcomingSchedules = [];
  List<ChatConsultation> _chatConsultations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSchedules();
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

  Future<void> _loadSchedules() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch real data from backend
      final results = await Future.wait([
        ScheduleService.getActiveConsultations(),
        ScheduleService.getUpcomingConsultations(),
        ScheduleService.getChatConsultations(),
      ]);

      final activeConsultations = results[0] as List<ScheduleConsultationItem>;
      final upcomingConsultations =
          results[1] as List<ScheduleConsultationItem>;
      final chatConsultations = results[2] as List<ChatConsultation>;

      setState(() {
        // Convert to legacy format for UI compatibility
        _activeSchedules =
            activeConsultations.map((item) => item.toLegacySchedule()).toList();

        _upcomingSchedules = upcomingConsultations
            .map((item) => item.toLegacySchedule())
            .toList();

        _chatConsultations = chatConsultations;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;

        // Fallback to empty lists
        _activeSchedules = [];
        _upcomingSchedules = [];
        _chatConsultations = [];
      });

      _showSnackBar('Gagal memuat jadwal: $e');
    }
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
          'Jadwal Konsultasi',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshSchedules,
            icon: const Icon(Icons.refresh, color: Color(0xFF2E7D89)),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildScheduleView(),
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
            'Memuat jadwal konsultasi...',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _refreshSchedules,
        color: const Color(0xFF2E7D89),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActiveSchedulesSection(),
              const SizedBox(height: 24),
              _buildChatConsultationsSection(),
              const SizedBox(height: 24),
              _buildUpcomingSchedulesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatConsultationsSection() {
    if (_chatConsultations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Color(0xFF9B59B6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Chat Konsultasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_chatConsultations.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_chatConsultations.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChatConsultationCard(_chatConsultations[index]),
          );
        }),
      ],
    );
  }

  Widget _buildChatConsultationCard(ChatConsultation consultation) {
    Color statusColor;
    switch (consultation.status) {
      case ConsultationStatus.waiting:
        statusColor = const Color(0xFFF39C12);
        break;
      case ConsultationStatus.inProgress:
        statusColor = const Color(0xFF2ECC71);
        break;
      case ConsultationStatus.completed:
        statusColor = const Color(0xFF3498DB);
        break;
      case ConsultationStatus.cancelled:
        statusColor = const Color(0xFFE74C3C);
        break;
    }

    return GestureDetector(
      onTap: () => _openChatConsultation(consultation),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation.doctorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        consultation.specialty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getConsultationStatusText(consultation.status),
                    style: TextStyle(
                      color: statusColor,
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
                  _formatDateTime(consultation.scheduledTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (consultation.hasUnreadMessages) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Pesan baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (consultation.queuePosition > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.queue, color: Colors.grey[600], size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Posisi ${consultation.queuePosition} - Estimasi ${consultation.estimatedWaitMinutes} menit',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getConsultationStatusText(ConsultationStatus status) {
    switch (status) {
      case ConsultationStatus.waiting:
        return 'Menunggu';
      case ConsultationStatus.inProgress:
        return 'Berlangsung';
      case ConsultationStatus.completed:
        return 'Selesai';
      case ConsultationStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  void _openChatConsultation(ChatConsultation consultation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatConsultationScreen(consultation: consultation),
      ),
    );
  }

  Widget _buildActiveSchedulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.access_time,
                color: Color(0xFF2ECC71),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Jadwal Aktif',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const Spacer(),
            if (_activeSchedules.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_activeSchedules.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_activeSchedules.isEmpty) ...[
          _buildEmptyActiveSchedule(),
        ] else ...[
          ...List.generate(_activeSchedules.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildActiveScheduleCard(_activeSchedules[index]),
            );
          }),
        ],
      ],
    );
  }

  // Add action methods
  void _cancelConsultation(String consultationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Konsultasi'),
        content:
            const Text('Apakah Anda yakin ingin membatalkan konsultasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ScheduleService.cancelConsultation(consultationId);
        _showSnackBar('Konsultasi berhasil dibatalkan');
        _refreshSchedules();
      } catch (e) {
        _showSnackBar('Gagal membatalkan konsultasi: $e');
      }
    }
  }

  Widget _buildEmptyActiveSchedule() {
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
              Icons.event_available,
              color: Colors.grey[400],
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada jadwal konsultasi aktif',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Jadwal konsultasi yang perlu segera dilakukan akan muncul di sini',
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

  Future<void> _refreshSchedules() async {
    await _loadSchedules();
  }

  String _formatDateTime(DateTime dateTime) {
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    final day = days[dateTime.weekday % 7];
    final date = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day, $date $month $year • $hour:$minute';
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

  Widget _buildActiveScheduleCard(ConsultationSchedule schedule) {
    return GestureDetector(
      onTap: () => _showScheduleDetail(schedule),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: schedule.isUrgent
                ? [const Color(0xFFE74C3C), const Color(0xFFC0392B)]
                : [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (schedule.isUrgent
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFF2ECC71))
                  .withOpacity(0.3),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.doctorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.specialty,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    schedule.isUrgent ? 'URGENT' : 'AKTIF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(schedule.scheduledDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${schedule.hospital} - ${schedule.room}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (schedule.queueNumber != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.confirmation_number,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Nomor Antrean: ${schedule.queueNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _viewQueueDetail(schedule),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Detail',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSchedulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.event,
                color: Color(0xFF3498DB),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Jadwal Mendatang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_upcomingSchedules.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_upcomingSchedules.isEmpty) ...[
          Container(
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
                    Icons.event_note,
                    color: Colors.grey[400],
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada jadwal mendatang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Jadwal konsultasi yang akan datang akan muncul di sini',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else ...[
          ...List.generate(_upcomingSchedules.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildUpcomingScheduleCard(_upcomingSchedules[index]),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildUpcomingScheduleCard(ConsultationSchedule schedule) {
    return GestureDetector(
      onTap: () => _showScheduleDetail(schedule),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _getStatusColor(schedule.status).withOpacity(0.3)),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.doctorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        schedule.specialty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(schedule.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(schedule.status),
                    style: TextStyle(
                      color: _getStatusColor(schedule.status),
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
                  _formatDateTime(schedule.scheduledDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timelapse, color: Colors.grey[600], size: 14),
                const SizedBox(width: 6),
                Text(
                  '~${schedule.estimatedDuration} mnt',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${schedule.hospital} - ${schedule.room}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ),
              ],
            ),
            if (schedule.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.note, color: Colors.grey[600], size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      schedule.notes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8C8D),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showScheduleDetail(ConsultationSchedule schedule) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                    const Text(
                      'Detail Jadwal Konsultasi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('Dokter', schedule.doctorName),
                    _buildDetailRow('Spesialisasi', schedule.specialty),
                    _buildDetailRow('Rumah Sakit', schedule.hospital),
                    _buildDetailRow('Ruangan', schedule.room),
                    _buildDetailRow('Tanggal & Waktu',
                        _formatDateTime(schedule.scheduledDate)),
                    _buildDetailRow(
                        'Durasi', '~${schedule.estimatedDuration} menit'),
                    _buildDetailRow(
                        'Tipe Konsultasi', _getTypeText(schedule.type)),
                    _buildDetailRow('Status', _getStatusText(schedule.status)),
                    if (schedule.queueNumber != null)
                      _buildDetailRow('Nomor Antrean', schedule.queueNumber!),
                    if (schedule.notes.isNotEmpty)
                      _buildDetailRow('Catatan', schedule.notes),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        if (schedule.status == ScheduleStatus.pending ||
                            schedule.status == ScheduleStatus.confirmed) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _cancelConsultation(schedule.id);
                              },
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFFE74C3C)),
                                foregroundColor: const Color(0xFFE74C3C),
                              ),
                              child: const Text('Batalkan'),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (schedule.queueNumber != null) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _viewQueueDetail(schedule);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D89),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Lihat Antrean'),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D89),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Tutup'),
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildDetailRow(String label, String value) {
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
                fontSize: 14,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewQueueDetail(ConsultationSchedule schedule) {
    if (schedule.queueNumber != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QueueDetailScreen(
            queueNumber: schedule.queueNumber!,
            isFromAutoQueue: false,
          ),
        ),
      );
    }
  }

  Color _getStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.confirmed:
        return const Color(0xFF2ECC71);
      case ScheduleStatus.pending:
        return const Color(0xFFF39C12);
      case ScheduleStatus.waitingConfirmation:
        return const Color(0xFF3498DB);
      case ScheduleStatus.cancelled:
        return const Color(0xFFE74C3C);
      case ScheduleStatus.completed:
        return const Color(0xFF27AE60);
    }
  }

  String _getStatusText(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.confirmed:
        return 'Dikonfirmasi';
      case ScheduleStatus.pending:
        return 'Menunggu';
      case ScheduleStatus.waitingConfirmation:
        return 'Perlu Konfirmasi';
      case ScheduleStatus.cancelled:
        return 'Dibatalkan';
      case ScheduleStatus.completed:
        return 'Selesai';
    }
  }

  String _getTypeText(ConsultationType type) {
    switch (type) {
      case ConsultationType.consultation:
        return 'Konsultasi';
      case ConsultationType.followUp:
        return 'Kontrol';
      case ConsultationType.checkUp:
        return 'Medical Check Up';
    }
  }
}
