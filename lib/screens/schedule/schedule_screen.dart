import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/schedule_models.dart';
import '../../services/auth_service.dart';
import '../queue/queue_detail_screen.dart';
import '../../widgets/qr_code_widget.dart'; // Add this import

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
  bool _isLoading = true;

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

  void _loadSchedules() {
    // Simulate loading data
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _activeSchedules = _generateActiveSchedules();
        _upcomingSchedules = _generateUpcomingSchedules();
        _isLoading = false;
      });
      _animationController.forward();
    });
  }

  List<ConsultationSchedule> _generateActiveSchedules() {
    final random = Random();
    final schedules = <ConsultationSchedule>[];

    // Generate 0-2 active schedules
    final activeCount = random.nextInt(3);

    for (int i = 0; i < activeCount; i++) {
      schedules.add(ConsultationSchedule(
        id: 'ACT_${random.nextInt(1000)}',
        doctorName: [
          'Dr. Sarah Wijaya, Sp.PD',
          'Dr. Ahmad Budi, Sp.JP',
          'Dr. Lisa Sari, Sp.M'
        ][random.nextInt(3)],
        specialty: [
          'Spesialis Penyakit Dalam',
          'Spesialis Jantung',
          'Spesialis Mata'
        ][random.nextInt(3)],
        hospital: 'RS Mitra Keluarga',
        scheduledDate: DateTime.now().add(Duration(
          days: random.nextInt(7) + 1,
          hours: random.nextInt(8) + 8,
        )),
        type: [
          ConsultationType.followUp,
          ConsultationType.checkUp,
          ConsultationType.consultation
        ][random.nextInt(3)],
        status: ScheduleStatus.confirmed,
        queueNumber: 'A-${random.nextInt(50) + 1}',
        estimatedDuration: random.nextInt(30) + 15,
        room: 'Ruang ${['A-1', 'B-2', 'C-3'][random.nextInt(3)]}',
        notes: 'Kontrol rutin setelah pengobatan',
        isUrgent: random.nextBool(),
      ));
    }

    return schedules;
  }

  List<ConsultationSchedule> _generateUpcomingSchedules() {
    final random = Random();
    final schedules = <ConsultationSchedule>[];

    // Generate 2-5 upcoming schedules
    final upcomingCount = random.nextInt(4) + 2;

    for (int i = 0; i < upcomingCount; i++) {
      schedules.add(ConsultationSchedule(
        id: 'UPC_${random.nextInt(1000)}',
        doctorName: [
          'Dr. Sarah Wijaya, Sp.PD',
          'Dr. Ahmad Budi, Sp.JP',
          'Dr. Lisa Sari, Sp.M',
          'Dr. Andi Pratama',
          'Dr. Maya Sari, Sp.OG'
        ][random.nextInt(5)],
        specialty: [
          'Spesialis Penyakit Dalam',
          'Spesialis Jantung',
          'Spesialis Mata',
          'Dokter Umum',
          'Spesialis Kandungan'
        ][random.nextInt(5)],
        hospital: 'RS Mitra Keluarga',
        scheduledDate: DateTime.now().add(Duration(
          days: random.nextInt(30) + 8,
          hours: random.nextInt(8) + 8,
        )),
        type: [
          ConsultationType.followUp,
          ConsultationType.checkUp,
          ConsultationType.consultation
        ][random.nextInt(3)],
        status: [
          ScheduleStatus.pending,
          ScheduleStatus.confirmed,
          ScheduleStatus.waitingConfirmation
        ][random.nextInt(3)],
        estimatedDuration: random.nextInt(30) + 15,
        room: 'Ruang ${['A-1', 'B-2', 'C-3', 'D-4'][random.nextInt(4)]}',
        notes: [
          'Kontrol rutin setelah pengobatan',
          'Pemeriksaan lanjutan',
          'Konsultasi hasil laboratorium',
          'Check up berkala'
        ][random.nextInt(4)],
      ));
    }

    return schedules;
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
              _buildUpcomingSchedulesSection(),
            ],
          ),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Detail',
                          style: TextStyle(
                            color: schedule.isUrgent
                                ? const Color(0xFFE74C3C)
                                : const Color(0xFF2ECC71),
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
        ...List.generate(_upcomingSchedules.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildUpcomingScheduleCard(_upcomingSchedules[index]),
          );
        }),
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
                        fontSize: 11,
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
                    Text(
                      'Detail Jadwal Konsultasi',
                      style: const TextStyle(
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

                    // QR Code Section
                    if (schedule.status == ScheduleStatus.confirmed) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.qr_code,
                                    color: Color(0xFF2E7D89)),
                                const SizedBox(width: 8),
                                const Text(
                                  'QR Code Konsultasi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showQRCode(schedule),
                                    icon: const Icon(Icons.qr_code_scanner,
                                        size: 16),
                                    label: const Text('Tampilkan QR'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF2E7D89),
                                      side: const BorderSide(
                                          color: Color(0xFF2E7D89)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showPrintCode(schedule),
                                    icon: const Icon(Icons.print, size: 16),
                                    label: const Text('Kode Print'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D89),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (schedule.status == ScheduleStatus.confirmed &&
                        schedule.queueNumber != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _viewQueueDetail(schedule);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Lihat Detail Antrean',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
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
                              'Tutup',
                              style: TextStyle(
                                color: Color(0xFF7F8C8D),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (schedule.status == ScheduleStatus.pending ||
                            schedule.status ==
                                ScheduleStatus.waitingConfirmation) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _rescheduleAppointment(schedule),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3498DB),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Reschedule',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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

  void _showQRCode(ConsultationSchedule schedule) {
    Navigator.pop(context); // Close detail modal first

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'QR Code Konsultasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF7F8C8D)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: QRCodeWidget(
                  data:
                      'CONSULTATION_${schedule.id}_${DateTime.now().millisecondsSinceEpoch}',
                  size: 200,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                schedule.doctorName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(schedule.scheduledDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareQRCode(schedule),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Bagikan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3498DB),
                        side: const BorderSide(color: Color(0xFF3498DB)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _saveQRCode(schedule),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D89),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrintCode(ConsultationSchedule schedule) {
    Navigator.pop(context); // Close detail modal first

    final printCode = _generatePrintCode();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Kode Print Konsultasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF7F8C8D)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.confirmation_number,
                      color: Color(0xFF2E7D89),
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kode Print',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      printCode,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D89),
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      schedule.doctorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(schedule.scheduledDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8C8D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFC107)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF856404),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Berikan kode ini ke petugas RS untuk mencetak tiket konsultasi',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF856404),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyPrintCode(printCode),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Salin Kode'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3498DB),
                        side: const BorderSide(color: Color(0xFF3498DB)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Mengerti'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D89),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generatePrintCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  void _shareQRCode(ConsultationSchedule schedule) =>
      _showSnackBar('Bagikan QR akan segera hadir!');
  void _saveQRCode(ConsultationSchedule schedule) =>
      _showSnackBar('QR berhasil disimpan!');
  void _copyPrintCode(String code) {
    // Copy to clipboard
    _showSnackBar('Kode $code berhasil disalin!');
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

  void _rescheduleAppointment(ConsultationSchedule schedule) {
    Navigator.pop(context);
    _showSnackBar('Fitur reschedule akan segera hadir!');
  }

  Future<void> _refreshSchedules() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _activeSchedules = _generateActiveSchedules();
      _upcomingSchedules = _generateUpcomingSchedules();
      _isLoading = false;
    });
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
}
