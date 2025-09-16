import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/schedule_models.dart' as schedule_models;
import '../../models/consultation_models.dart';
import '../../models/chat_models.dart' as chat; // Add this import
import '../../services/schedule_service.dart';
import '../../services/auth_service.dart';
import '../../services/http_service.dart';
import '../queue/queue_detail_screen.dart';
import '../consultation/chat_consultation_screen.dart';
import '../consultation/ai_consultation_screen.dart';
import '../consultation/consultation_result_screen.dart';
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

      final results = await Future.wait([
        ScheduleService.getActiveConsultations(),
        ScheduleService.getUpcomingConsultations(),
        ScheduleService.getChatConsultations(),
      ]);

      final activeConsultations = results[0] as List<ScheduleConsultationItem>;
      final upcomingConsultations = results[1] as List<ScheduleConsultationItem>;
      final chatConsultations = results[2] as List<ChatConsultation>;

      setState(() {
        _activeSchedules = activeConsultations.map((item) => item.toLegacySchedule()).toList();
        _upcomingSchedules = upcomingConsultations.map((item) => item.toLegacySchedule()).toList();
        _chatConsultations = chatConsultations;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
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

  // Fix _buildUpcomingScheduleCard method - complete missing Text widgets
  Widget _buildUpcomingScheduleCard(ConsultationSchedule schedule) {
    return GestureDetector(
      onTap: () => _showScheduleDetail(schedule),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
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
                        schedule.doctorName, // Fix: Add missing text
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        schedule.specialty, // Fix: Add missing text
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getScheduleTypeText(schedule),
                    style: TextStyle(
                      color: Colors.blue[600],
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
                Icons.schedule,
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
            if (_upcomingSchedules.isNotEmpty)
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
          _buildEmptyUpcomingSchedule(),
        ] else ...[
          ...List.generate(_upcomingSchedules.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildUpcomingScheduleCard(_upcomingSchedules[index]),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildEmptyUpcomingSchedule() {
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
              Icons.event_note,
              color: Colors.grey[400],
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada jadwal mendatang',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Jadwal konsultasi untuk hari-hari mendatang akan muncul di sini',
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

  // Fix _showScheduleDetail method - complete missing content
  void _showScheduleDetail(ConsultationSchedule schedule) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Detail Konsultasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.doctorName, // Fix: Add missing content
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            schedule.specialty, // Fix: Add missing content
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${schedule.hospital} - ${schedule.room}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Tanggal & Waktu', _formatDateTime(schedule.scheduledDate)),
                    _buildDetailRow('Tipe Konsultasi', _getScheduleTypeText(schedule)),
                    _buildDetailRow('Status', schedule.isUrgent ? 'Prioritas Tinggi' : 'Normal'),
                    if (schedule.notes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Catatan:', // Fix: Add missing content
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.notes, // Fix: Add missing content
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _handleContinueConsultation(schedule);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D89),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _getContinueText(schedule),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showCancelOptions(schedule);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF7F8C8D)),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Opsi',
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                fontSize: 12,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF7F8C8D))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fix _buildChatConsultationCard method - complete missing Text widgets
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
                        consultation.doctorName, // Fix: Add missing text
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        consultation.specialty, // Fix: Add missing text
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

  // Fix _openChatConsultation method - use correct parameter name
  void _openChatConsultation(ChatConsultation consultation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConsultationScreen(
          consultation: consultation, // Fix: Use 'consultation' parameter
        ),
      ),
    );
  }

  // Fix _buildActiveScheduleCard method - complete missing content
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
                        schedule.doctorName, // Fix: Add missing content
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.specialty, // Fix: Add missing content
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getScheduleTypeText(schedule),
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
                Expanded(
                  child: Text(
                    '${schedule.hospital} - ${schedule.room}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _handleContinueConsultation(schedule), // Fix: Add missing onPressed
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: schedule.isUrgent 
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_getContinueIcon(schedule), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _getContinueText(schedule),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () => _showCancelOptions(schedule),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
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

  // Helper methods
  String _getScheduleTypeText(ConsultationSchedule schedule) {
    if (schedule.specialty.contains('AI')) {
      return 'AI KONSULTASI';
    } else if (schedule.room.contains('Chat')) {
      return 'CHAT DOKTER';
    } else {
      return 'APPOINTMENT';
    }
  }

  IconData _getContinueIcon(ConsultationSchedule schedule) {
    if (schedule.specialty.contains('AI')) {
      return Icons.smart_toy;
    } else if (schedule.room.contains('Chat')) {
      return Icons.chat_bubble_outline;
    } else {
      return Icons.local_hospital;
    }
  }

  String _getContinueText(ConsultationSchedule schedule) {
    if (schedule.specialty.contains('AI')) {
      return 'Lanjutkan';
    } else if (schedule.room.contains('Chat')) {
      return 'Chat';
    } else {
      return 'Lihat';
    }
  }

  // Fix _handleContinueConsultation method - Fix chat import issue
void _handleContinueConsultation(ConsultationSchedule schedule) async {
  try {
    print('🚀 Continuing consultation: ${schedule.id}');
    
    final consultationData = await _getConsultationData(schedule.id);
    
    print('📊 Consultation type: ${consultationData['type']}');
    print('📊 Is completed: ${consultationData['isCompleted']}');
    print('📊 AI Analysis type: ${consultationData['aiAnalysis']?['type']}');

    if (consultationData['type'] == 'AI') {
      // Check AI analysis type first - THIS IS THE KEY FIX
      final aiAnalysis = consultationData['aiAnalysis'];
      
      // PRIORITY 1: Check if AI Analysis is FINAL_DIAGNOSIS (regardless of isCompleted flag)
      if (aiAnalysis != null && aiAnalysis['type'] == 'FINAL_DIAGNOSIS') {
        print('✅ AI Analysis is FINAL_DIAGNOSIS - going directly to results');
        
        // Parse chat history for results screen
        List<chat.ChatMessage> chatMessages = [];
        if (consultationData['chatHistory'] != null) {
          final rawChatHistory = consultationData['chatHistory'];
          if (rawChatHistory is List) {
            chatMessages = rawChatHistory
                .map((msg) {
                  try {
                    if (msg is Map<String, dynamic>) {
                      return chat.ChatMessage.fromJson(msg);
                    } else {
                      return chat.ChatMessage.fromJson(
                          Map<String, dynamic>.from(msg as Map));
                    }
                  } catch (e) {
                    print('Error parsing chat message: $e');
                    return chat.ChatMessage(
                      text: msg['text']?.toString() ?? 'Pesan tidak dapat dimuat',
                      isUser: msg['isUser'] == true,
                    );
                  }
                })
                .toList();
          }
        }

        // Parse AI result from FINAL_DIAGNOSIS
        AIScreeningResult? aiResult;
        try {
          // Create proper AIScreeningResult from the complete AI analysis
          aiResult = AIScreeningResult.fromJson({
            'consultationId': schedule.id,
            'severity': aiAnalysis['severity'] ?? 'MEDIUM',
            'recommendation': aiAnalysis['recommendation'] ?? 'DOCTOR_CONSULTATION',
            'message': aiAnalysis['explanation'] ?? 'Hasil analisis AI telah selesai.',
            'needsDoctorConsultation': aiAnalysis['needsDoctor'] ?? true,
            'estimatedFee': 25000.0,
            'confidence': aiAnalysis['confidence'] ?? 0.7,
            'type': 'FINAL_DIAGNOSIS',
            'primaryDiagnosis': aiAnalysis['primaryDiagnosis'],
            'possibleConditions': aiAnalysis['possibleConditions'],
            'urgencyLevel': _mapSeverityToUrgency(aiAnalysis['severity']),
            'recommendedActions': _extractRecommendedActions(aiAnalysis),
            'medicalResearch': aiAnalysis['medicalResearch'],
            'isComplete': true,
          });
          
          print('🎯 Created AIScreeningResult: ${aiResult.message}');
          print('🔍 Primary diagnosis: ${aiResult.primaryDiagnosis}');
          print('📋 Possible conditions: ${aiResult.possibleConditions}');
          
        } catch (e) {
          print('❌ Error parsing AI result: $e');
          // Fallback AI result
          aiResult = AIScreeningResult(
            consultationId: schedule.id,
            severity: aiAnalysis['severity'] ?? 'MEDIUM',
            recommendation: 'DOCTOR_CONSULTATION',
            message: aiAnalysis['explanation'] ?? 'Hasil analisis tersedia, silakan lihat detail.',
            needsDoctorConsultation: aiAnalysis['needsDoctor'] ?? true,
            estimatedFee: 25000,
            confidence: aiAnalysis['confidence'] ?? 0.7,
            type: 'FINAL_DIAGNOSIS',
          );
        }

        // Navigate directly to results screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsultationResultScreen(
              chatHistory: chatMessages,
              aiResult: aiResult,
            ),
          ),
        );
        return; // Exit early - don't check other conditions
        
      } 
      // PRIORITY 2: Check if it's still a follow-up question
      else if (aiAnalysis != null && aiAnalysis['type'] == 'FOLLOW_UP_QUESTION') {
        print('❓ AI still asking questions - resuming consultation');
        
        // Parse chat history for resume
        List<Map<String, dynamic>>? rawChatHistory;
        if (consultationData['chatHistory'] != null) {
          final chatHistoryData = consultationData['chatHistory'];
          if (chatHistoryData is List) {
            rawChatHistory = chatHistoryData
                .map((item) => item is Map<String, dynamic> 
                    ? item 
                    : Map<String, dynamic>.from(item as Map))
                .toList();
          }
        }

        print('🔄 Resuming AI consultation with ${rawChatHistory?.length ?? 0} messages');

        // Go to AI consultation screen to continue
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIConsultationScreen(
              existingConsultationId: schedule.id,
              chatHistory: rawChatHistory,
            ),
          ),
        );
        return; // Exit early
      }
      // PRIORITY 3: Check database isCompleted flag as fallback
      else if (consultationData['isCompleted'] == true) {
        print('📋 Consultation marked as completed in database');
        
        // Use existing logic for completed consultations
        List<chat.ChatMessage> chatMessages = [];
        if (consultationData['chatHistory'] != null) {
          final rawChatHistory = consultationData['chatHistory'];
          if (rawChatHistory is List) {
            chatMessages = rawChatHistory
                .map((msg) {
                  try {
                    if (msg is Map<String, dynamic>) {
                      return chat.ChatMessage.fromJson(msg);
                    } else {
                      return chat.ChatMessage.fromJson(
                          Map<String, dynamic>.from(msg as Map));
                    }
                  } catch (e) {
                    print('Error parsing chat message: $e');
                    return chat.ChatMessage(
                      text: msg['text']?.toString() ?? 'Pesan tidak dapat dimuat',
                      isUser: msg['isUser'] == true,
                    );
                  }
                })
                .toList();
          }
        }

        AIScreeningResult? aiResult;
        if (consultationData['aiAnalysis'] != null) {
          try {
            if (consultationData['aiAnalysis'] is Map<String, dynamic>) {
              aiResult = AIScreeningResult.fromJson(
                  consultationData['aiAnalysis'] as Map<String, dynamic>);
            } else {
              aiResult = AIScreeningResult.fromJson(
                  Map<String, dynamic>.from(
                      consultationData['aiAnalysis'] as Map));
            }
          } catch (e) {
            print('Error parsing AI result: $e');
            aiResult = AIScreeningResult(
              consultationId: schedule.id,
              severity: 'MEDIUM',
              recommendation: 'DOCTOR_CONSULTATION',
              message: 'Hasil analisis tersedia, silakan lihat detail.',
              needsDoctorConsultation: true,
              estimatedFee: 25000,
              confidence: 0.7,
              type: 'FINAL_DIAGNOSIS',
            );
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsultationResultScreen(
              chatHistory: chatMessages,
              aiResult: aiResult,
            ),
          ),
        );
      }
      // PRIORITY 4: Default case - consultation in progress
      else {
        print('🔄 Consultation still in progress - resuming');
        
        // Parse chat history for resume
        List<Map<String, dynamic>>? rawChatHistory;
        if (consultationData['chatHistory'] != null) {
          final chatHistoryData = consultationData['chatHistory'];
          if (chatHistoryData is List) {
            rawChatHistory = chatHistoryData
                .map((item) => item is Map<String, dynamic> 
                    ? item 
                    : Map<String, dynamic>.from(item as Map))
                .toList();
          }
        }

        print('🔄 Resuming AI consultation with ${rawChatHistory?.length ?? 0} messages');

        // Go to AI consultation screen to continue
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIConsultationScreen(
              existingConsultationId: schedule.id,
              chatHistory: rawChatHistory,
            ),
          ),
        );
      }
    } else if (consultationData['type'] == 'CHAT_DOCTOR') {
      // Handle chat doctor consultations (unchanged)
      try {
        ChatConsultation consultation;
        if (consultationData is Map<String, dynamic>) {
          consultation = ChatConsultation.fromJson(consultationData);
        } else {
          consultation = ChatConsultation.fromJson(
              Map<String, dynamic>.from(consultationData as Map));
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConsultationScreen(
              consultation: consultation,
            ),
          ),
        );
      } catch (e) {
        print('Error parsing chat consultation: $e');
        _showSnackBar('Error membuka chat konsultasi: $e');
        return;
      }
    } else {
      _showScheduleDetail(schedule);
    }
  } catch (e) {
    print('Error in _handleContinueConsultation: $e');
    _showSnackBar('Gagal membuka konsultasi: $e');
  }
}

String _mapSeverityToUrgency(String? severity) {
  switch (severity?.toUpperCase()) {
    case 'LOW':
      return 'TIDAK_MENDESAK';
    case 'MEDIUM':
      return 'DALAM_24_JAM';
    case 'HIGH':
      return 'SEGERA';
    default:
      return 'KONSULTASI_DIANJURKAN';
  }
}

List<String> _extractRecommendedActions(Map<String, dynamic> aiAnalysis) {
  // Try to extract from raw_response or create default recommendations
  final recommendations = <String>[];
  
  if (aiAnalysis['needsDoctor'] == true) {
    recommendations.add('Konsultasi dengan dokter umum direkomendasikan');
    recommendations.add('Siapkan riwayat gejala untuk konsultasi');
    recommendations.add('Monitor perkembangan gejala secara berkala');
  }
  
  // Add severity-specific recommendations
  switch (aiAnalysis['severity']?.toString().toUpperCase()) {
    case 'HIGH':
      recommendations.add('Prioritas konsultasi - respons cepat diperlukan');
      recommendations.add('Jika kondisi memburuk, segera ke IGD');
      break;
    case 'MEDIUM':
      recommendations.add('Konsultasi dalam 24 jam direkomendasikan');
      recommendations.add('Hindari aktivitas berat sementara waktu');
      break;
    case 'LOW':
      recommendations.add('Istirahat yang cukup');
      recommendations.add('Perbanyak minum air putih');
      break;
  }
  
  return recommendations;
}

  void _showCancelOptions(ConsultationSchedule schedule) {
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
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Opsi Konsultasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCancelOption(
              icon: Icons.pause_circle_outline,
              title: 'Tutup Sementara',
              subtitle: 'Simpan progress, dapat dilanjutkan nanti',
              color: const Color(0xFF3498DB),
              onTap: () {
                Navigator.pop(context);
                _closeTemporarily(schedule);
              },
            ),
            if (_canMarkAsCompleted(schedule)) ...[
              _buildCancelOption(
                icon: Icons.check_circle_outline,
                title: 'Tandai Selesai',
                subtitle: 'Konsultasi sudah cukup, tidak perlu lanjutan',
                color: const Color(0xFF2ECC71),
                onTap: () {
                  Navigator.pop(context);
                  _markAsCompleted(schedule);
                },
              ),
            ],
            _buildCancelOption(
              icon: Icons.cancel_outlined,
              title: 'Batalkan Konsultasi',
              subtitle: 'Batalkan dan hapus dari jadwal',
              color: const Color(0xFFE74C3C),
              onTap: () {
                Navigator.pop(context);
                _confirmCancelConsultation(schedule);
              },
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  bool _canMarkAsCompleted(ConsultationSchedule schedule) {
    return schedule.specialty.contains('AI') ||
        schedule.room.contains('Chat') ||
        schedule.notes.isNotEmpty;
  }

  void _closeTemporarily(ConsultationSchedule schedule) async {
    try {
      setState(() {
        _activeSchedules.removeWhere((s) => s.id == schedule.id);
      });
      _showSnackBar('Konsultasi disimpan, dapat dilanjutkan dari riwayat');
    } catch (e) {
      _showSnackBar('Gagal menyimpan konsultasi: $e');
    }
  }

  void _markAsCompleted(ConsultationSchedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tandai Selesai'),
        content: const Text(
            'Apakah Anda yakin konsultasi ini sudah selesai? '
            'Hasil konsultasi akan tetap tersimpan di riwayat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
            ),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ScheduleService.markConsultationCompleted(schedule.id);
        setState(() {
          _activeSchedules.removeWhere((s) => s.id == schedule.id);
        });
        _showSnackBar('Konsultasi ditandai selesai');
      } catch (e) {
        _showSnackBar('Gagal menandai selesai: $e');
      }
    }
  }

  void _confirmCancelConsultation(ConsultationSchedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[600], size: 24),
            const SizedBox(width: 8),
            const Text('Batalkan Konsultasi'),
          ],
        ),
        content: const Text(
            'Apakah Anda yakin ingin membatalkan konsultasi ini? '
            'Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ScheduleService.cancelConsultation(schedule.id);
        setState(() {
          _activeSchedules.removeWhere((s) => s.id == schedule.id);
          _upcomingSchedules.removeWhere((s) => s.id == schedule.id);
        });
        _showSnackBar('Konsultasi berhasil dibatalkan');
      } catch (e) {
        _showSnackBar('Gagal membatalkan konsultasi: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _getConsultationData(String consultationId) async {
  try {
    print('🔍 Getting consultation data for: $consultationId');
    
    final response = await HttpService.get(
      '/api/consultations/details/$consultationId',
      token: AuthService.getCurrentToken(),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        final consultationData = responseData['data']['consultation'];
        
        // Debug log AI analysis
        print('📊 AI Analysis from backend: ${consultationData['aiAnalysis']}');
        print('🗨️ Chat History length: ${consultationData['chatHistory']?.length ?? 0}');
        print('✅ Is Completed: ${consultationData['isCompleted']}');
        
        return consultationData;
      }
    }

    throw Exception('Failed to get consultation data');
  } catch (e) {
    print('❌ Error getting consultation data: $e');
    throw Exception('Failed to get consultation data: $e');
  }
}

  Future<void> _refreshSchedules() async {
    await _loadSchedules();
  }

  String _formatDateTime(DateTime dateTime) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
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

  void _cancelConsultation(String consultationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Konsultasi'),
        content: const Text('Apakah Anda yakin ingin membatalkan konsultasi ini?'),
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
}