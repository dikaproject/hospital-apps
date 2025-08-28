import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/family_models.dart';
import '../../models/appointment_models.dart';

class FamilyScheduleScreen extends StatefulWidget {
  const FamilyScheduleScreen({super.key});

  @override
  State<FamilyScheduleScreen> createState() => _FamilyScheduleScreenState();
}

class _FamilyScheduleScreenState extends State<FamilyScheduleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<FamilyAppointment> _upcomingAppointments = [];
  List<FamilyAppointment> _pastAppointments = [];
  bool _isLoading = true;
  String _selectedMemberFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAppointments() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _upcomingAppointments = _generateUpcomingAppointments();
        _pastAppointments = _generatePastAppointments();
        _isLoading = false;
      });
    });
  }

  List<FamilyAppointment> _generateUpcomingAppointments() {
    return [
      FamilyAppointment(
        id: 'APP_001',
        memberName: 'Nenek Sari',
        memberRelation: FamilyRelation.grandparent,
        doctorName: 'Dr. Sarah Wijaya, Sp.PD',
        specialty: 'Penyakit Dalam',
        hospital: 'RS Siloam Hospitals',
        dateTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
        queueNumber: 'A-005',
        status: AppointmentStatus.confirmed,
        type: AppointmentType.consultation,
        notes: 'Kontrol rutin diabetes dan hipertensi',
      ),
      FamilyAppointment(
        id: 'APP_002',
        memberName: 'Ahmad Santoso',
        memberRelation: FamilyRelation.child,
        doctorName: 'Dr. Michael Chen, Sp.A',
        specialty: 'Anak',
        hospital: 'RS Hermina Kemayoran',
        dateTime: DateTime.now().add(const Duration(days: 5, hours: 14)),
        queueNumber: 'B-012',
        status: AppointmentStatus.waitingConfirmation,
        type: AppointmentType.checkup,
        notes: 'Pemeriksaan kesehatan tahunan',
      ),
      FamilyAppointment(
        id: 'APP_003',
        memberName: 'Siti Santoso',
        memberRelation: FamilyRelation.spouse,
        doctorName: 'Dr. Lisa Andriani, Sp.OG',
        specialty: 'Kandungan',
        hospital: 'RS Bunda Jakarta',
        dateTime: DateTime.now().add(const Duration(days: 7, hours: 9)),
        queueNumber: 'C-003',
        status: AppointmentStatus.confirmed,
        type: AppointmentType.consultation,
        notes: 'Konsultasi program kehamilan',
      ),
    ];
  }

  List<FamilyAppointment> _generatePastAppointments() {
    return [
      FamilyAppointment(
        id: 'APP_004',
        memberName: 'Budi Santoso',
        memberRelation: FamilyRelation.self,
        doctorName: 'Dr. Rahman Abdullah, Sp.JP',
        specialty: 'Jantung',
        hospital: 'RS Harapan Kita',
        dateTime: DateTime.now().subtract(const Duration(days: 3, hours: 11)),
        queueNumber: 'D-008',
        status: AppointmentStatus.completed,
        type: AppointmentType.consultation,
        notes: 'Pemeriksaan jantung rutin - hasil normal',
      ),
      FamilyAppointment(
        id: 'APP_005',
        memberName: 'Nenek Sari',
        memberRelation: FamilyRelation.grandparent,
        doctorName: 'Dr. Sarah Wijaya, Sp.PD',
        specialty: 'Penyakit Dalam',
        hospital: 'RS Siloam Hospitals',
        dateTime: DateTime.now().subtract(const Duration(days: 30, hours: 10)),
        queueNumber: 'A-015',
        status: AppointmentStatus.completed,
        type: AppointmentType.consultation,
        notes: 'Kontrol diabetes - gula darah terkontrol',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingView() : _buildContent(),
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
            'Jadwal Konsultasi Keluarga',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Pantau jadwal semua anggota keluarga',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showFilterDialog,
          icon: const Icon(Icons.filter_list, color: Color(0xFF2E7D89)),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF2E7D89),
        labelColor: const Color(0xFF2E7D89),
        unselectedLabelColor: const Color(0xFF7F8C8D),
        tabs: const [
          Tab(text: 'Akan Datang'),
          Tab(text: 'Riwayat'),
        ],
      ),
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
            'Memuat jadwal keluarga...',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildUpcomingTab(),
        _buildPastTab(),
      ],
    );
  }

  Widget _buildUpcomingTab() {
    final filteredAppointments =
        _getFilteredAppointments(_upcomingAppointments);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        _loadAppointments();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 20),
            if (filteredAppointments.isEmpty) ...[
              _buildEmptyState(
                icon: Icons.event_available,
                title: 'Tidak ada jadwal',
                subtitle: 'Belum ada jadwal konsultasi yang akan datang',
              ),
            ] else ...[
              ...filteredAppointments.map((appointment) =>
                  _buildAppointmentCard(appointment, isUpcoming: true)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPastTab() {
    final filteredAppointments = _getFilteredAppointments(_pastAppointments);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        _loadAppointments();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (filteredAppointments.isEmpty) ...[
              _buildEmptyState(
                icon: Icons.history,
                title: 'Belum ada riwayat',
                subtitle: 'Belum ada riwayat konsultasi keluarga',
              ),
            ] else ...[
              ...filteredAppointments.map((appointment) =>
                  _buildAppointmentCard(appointment, isUpcoming: false)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final todayAppointments = _upcomingAppointments.where((app) {
      final today = DateTime.now();
      return app.dateTime.year == today.year &&
          app.dateTime.month == today.month &&
          app.dateTime.day == today.day;
    }).length;

    final thisWeekAppointments = _upcomingAppointments.where((app) {
      final now = DateTime.now();
      final weekFromNow = now.add(const Duration(days: 7));
      return app.dateTime.isAfter(now) && app.dateTime.isBefore(weekFromNow);
    }).length;

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.today, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Ringkasan Jadwal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  label: 'Hari Ini',
                  value: todayAppointments.toString(),
                  icon: Icons.today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  label: 'Minggu Ini',
                  value: thisWeekAppointments.toString(),
                  icon: Icons.date_range,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  label: 'Total',
                  value: _upcomingAppointments.length.toString(),
                  icon: Icons.event_note,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(FamilyAppointment appointment,
      {required bool isUpcoming}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(appointment.status).withOpacity(0.3),
        ),
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
              CircleAvatar(
                radius: 20,
                backgroundColor: _getRelationColor(appointment.memberRelation)
                    .withOpacity(0.1),
                child: Text(
                  appointment.memberName
                      .split(' ')
                      .map((e) => e[0])
                      .take(2)
                      .join(),
                  style: TextStyle(
                    color: _getRelationColor(appointment.memberRelation),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.memberName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      getFamilyRelationText(appointment.memberRelation),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(appointment.status),
                  style: TextStyle(
                    color: _getStatusColor(appointment.status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[600], size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_hospital,
                        color: Colors.grey[600], size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${appointment.specialty} • ${appointment.hospital}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey[600], size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _formatDateTime(appointment.dateTime),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const Spacer(),
                    if (appointment.queueNumber.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3498DB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'No. ${appointment.queueNumber}',
                          style: const TextStyle(
                            color: Color(0xFF3498DB),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (appointment.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                appointment.notes,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
          if (isUpcoming) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rescheduleAppointment(appointment),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFF39C12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Reschedule',
                      style: TextStyle(
                        color: Color(0xFFF39C12),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewAppointmentDetail(appointment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D89),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
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
  List<FamilyAppointment> _getFilteredAppointments(
      List<FamilyAppointment> appointments) {
    if (_selectedMemberFilter == 'all') return appointments;
    return appointments
        .where((app) => app.memberName == _selectedMemberFilter)
        .toList();
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return const Color(0xFF2ECC71);
      case AppointmentStatus.waitingConfirmation:
        return const Color(0xFFF39C12);
      case AppointmentStatus.cancelled:
        return const Color(0xFFE74C3C);
      case AppointmentStatus.completed:
        return const Color(0xFF3498DB);
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Terkonfirmasi';
      case AppointmentStatus.waitingConfirmation:
        return 'Menunggu';
      case AppointmentStatus.cancelled:
        return 'Dibatalkan';
      case AppointmentStatus.completed:
        return 'Selesai';
    }
  }

  Color _getRelationColor(FamilyRelation relation) {
    switch (relation) {
      case FamilyRelation.self:
        return const Color(0xFF3498DB);
      case FamilyRelation.spouse:
        return const Color(0xFF9B59B6);
      case FamilyRelation.child:
        return const Color(0xFF2ECC71);
      case FamilyRelation.parent:
        return const Color(0xFF34495E);
      case FamilyRelation.grandparent:
        return const Color(0xFFE67E22);
      case FamilyRelation.sibling:
        return const Color(0xFF1ABC9C);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Hari ini, ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Besok, ${_formatTime(dateTime)}';
    } else if (difference.inDays > 0 && difference.inDays < 7) {
      return '${_getDayName(dateTime.weekday)}, ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getDayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }

  void _showFilterDialog() {
    final memberNames = [
      'all',
      ..._upcomingAppointments.map((a) => a.memberName).toSet()
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Anggota Keluarga'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: memberNames
              .map(
                (name) => RadioListTile<String>(
                  title: Text(name == 'all' ? 'Semua Anggota' : name),
                  value: name,
                  groupValue: _selectedMemberFilter,
                  onChanged: (value) {
                    setState(() => _selectedMemberFilter = value!);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _rescheduleAppointment(FamilyAppointment appointment) {
    _showSnackBar(
        'Fitur reschedule untuk ${appointment.memberName} akan segera hadir!');
  }

  void _viewAppointmentDetail(FamilyAppointment appointment) {
    _showSnackBar(
        'Detail appointment ${appointment.memberName} akan segera hadir!');
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
