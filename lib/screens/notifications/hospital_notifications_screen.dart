import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/notification_models.dart';
import '../../services/notification_service.dart';
import 'notification_settings_screen.dart';

class HospitalNotificationsScreen extends StatefulWidget {
  const HospitalNotificationsScreen({super.key});

  @override
  State<HospitalNotificationsScreen> createState() =>
      _HospitalNotificationsScreenState();
}

class _HospitalNotificationsScreenState
    extends State<HospitalNotificationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<HospitalNotification> _allNotifications = [];
  List<HospitalNotification> _unreadNotifications = [];
  bool _isLoading = true;
  String _selectedTypeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadNotifications() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _allNotifications = _generateNotifications();
        _unreadNotifications =
            _allNotifications.where((n) => !n.isRead).toList();
        _isLoading = false;
      });
    });
  }

  List<HospitalNotification> _generateNotifications() {
    return [
      HospitalNotification(
        id: 'NOTIF_001',
        title: 'Antrean Anda Hampir Tiba',
        message:
            'Nomor antrean A-15 akan dipanggil dalam 5 menit. Silakan bersiap ke ruang poli.',
        type: NotificationType.queue,
        priority: NotificationPriority.high,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: false,
        actionUrl: '/queue/detail/A-15',
        hospitalName: 'RS Siloam Hospitals',
        relatedData: {'queueNumber': 'A-15', 'estimatedTime': '5 menit'},
      ),
      HospitalNotification(
        id: 'NOTIF_002',
        title: 'Hasil Lab Tersedia',
        message:
            'Hasil pemeriksaan darah lengkap Anda sudah dapat dilihat. Klik untuk melihat detail.',
        type: NotificationType.labResult,
        priority: NotificationPriority.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        actionUrl: '/lab/results/LAB_001',
        hospitalName: 'RS Hermina Kemayoran',
        relatedData: {'testType': 'Darah Lengkap', 'resultDate': '27 Ags 2025'},
      ),
      HospitalNotification(
        id: 'NOTIF_003',
        title: 'Reminder Jadwal Konsultasi',
        message:
            'Jangan lupa konsultasi dengan Dr. Sarah Wijaya besok jam 10:00 di Poli Umum.',
        type: NotificationType.appointment,
        priority: NotificationPriority.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: true,
        actionUrl: '/schedule/appointment/APP_001',
        hospitalName: 'RS Siloam Hospitals',
        relatedData: {
          'doctorName': 'Dr. Sarah Wijaya',
          'appointmentTime': 'Besok 10:00'
        },
      ),
      HospitalNotification(
        id: 'NOTIF_004',
        title: 'Update Sistem HospitalLink',
        message:
            'Fitur baru telah ditambahkan! Sekarang Anda dapat mengelola keluarga dengan lebih mudah.',
        type: NotificationType.system,
        priority: NotificationPriority.low,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        actionUrl: '/family/dashboard',
        hospitalName: 'HospitalLink System',
      ),
      HospitalNotification(
        id: 'NOTIF_005',
        title: 'Pembayaran Berhasil',
        message:
            'Pembayaran konsultasi sebesar Rp 150.000 telah berhasil diproses.',
        type: NotificationType.payment,
        priority: NotificationPriority.medium,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        actionUrl: '/payment/receipt/PAY_001',
        hospitalName: 'RS Harapan Kita',
        relatedData: {'amount': 'Rp 150.000', 'paymentMethod': 'QRIS'},
      ),
      HospitalNotification(
        id: 'NOTIF_006',
        title: 'Info Kesehatan: Tips Hidup Sehat',
        message:
            'Jaga kesehatan dengan rutin olahraga dan konsumsi makanan bergizi seimbang.',
        type: NotificationType.healthTip,
        priority: NotificationPriority.low,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: false,
        hospitalName: 'Tim Medis HospitalLink',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingView() : _buildContent(),
      floatingActionButton: _buildTestNotificationFAB(),
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
            'Notifikasi Rumah Sakit',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Info terbaru dari rumah sakit',
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
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationSettingsScreen(),
            ),
          ),
          icon: const Icon(Icons.settings, color: Color(0xFF2E7D89)),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF2E7D89),
        labelColor: const Color(0xFF2E7D89),
        unselectedLabelColor: const Color(0xFF7F8C8D),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum Dibaca'),
                if (_unreadNotifications.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE74C3C),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _unreadNotifications.length.toString(),
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
          const Tab(text: 'Semua'),
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
            'Memuat notifikasi...',
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
        _buildUnreadTab(),
        _buildAllTab(),
      ],
    );
  }

  Widget _buildUnreadTab() {
    final filteredNotifications =
        _getFilteredNotifications(_unreadNotifications);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        _loadNotifications();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (filteredNotifications.isEmpty) ...[
              _buildEmptyState(
                icon: Icons.notifications_none,
                title: 'Tidak ada notifikasi baru',
                subtitle: 'Semua notifikasi sudah dibaca',
              ),
            ] else ...[
              _buildQuickActions(),
              const SizedBox(height: 20),
              ...filteredNotifications
                  .map((notification) => _buildNotificationCard(notification)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllTab() {
    final filteredNotifications = _getFilteredNotifications(_allNotifications);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        _loadNotifications();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 20),
            if (filteredNotifications.isEmpty) ...[
              _buildEmptyState(
                icon: Icons.notifications_off,
                title: 'Belum ada notifikasi',
                subtitle: 'Notifikasi akan muncul di sini',
              ),
            ] else ...[
              ...filteredNotifications
                  .map((notification) => _buildNotificationCard(notification)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.mark_email_read, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aksi Cepat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola semua notifikasi dengan mudah',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _markAllAsRead,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3498DB),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Tandai Semua Dibaca',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalNotifications = _allNotifications.length;
    final unreadCount = _unreadNotifications.length;
    final todayNotifications = _allNotifications.where((n) {
      final today = DateTime.now();
      return n.timestamp.year == today.year &&
          n.timestamp.month == today.month &&
          n.timestamp.day == today.day;
    }).length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total',
            value: totalNotifications.toString(),
            icon: Icons.notifications,
            color: const Color(0xFF3498DB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Belum Dibaca',
            value: unreadCount.toString(),
            icon: Icons.mark_email_unread,
            color: unreadCount > 0
                ? const Color(0xFFE74C3C)
                : const Color(0xFF95A5A6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Hari Ini',
            value: todayNotifications.toString(),
            icon: Icons.today,
            color: const Color(0xFF2ECC71),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(HospitalNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey[200]!
              : _getPriorityColor(notification.priority),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            _getTypeColor(notification.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(notification.type),
                        color: _getTypeColor(notification.type),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            notification.hospitalName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(notification.priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(notification.priority)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getPriorityText(notification.priority),
                            style: TextStyle(
                              color: _getPriorityColor(notification.priority),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: notification.isRead
                        ? const Color(0xFF7F8C8D)
                        : const Color(0xFF2C3E50),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey[500], size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    if (notification.actionUrl != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D89).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.touch_app,
                                color: Color(0xFF2E7D89), size: 12),
                            const SizedBox(width: 4),
                            const Text(
                              'Tap untuk aksi',
                              style: TextStyle(
                                color: Color(0xFF2E7D89),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildTestNotificationFAB() {
    return FloatingActionButton.extended(
      onPressed: _showTestNotificationDialog,
      backgroundColor: const Color(0xFF2E7D89),
      icon: const Icon(Icons.notification_add, color: Colors.white),
      label: const Text(
        'Test Notif',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper methods
  List<HospitalNotification> _getFilteredNotifications(
      List<HospitalNotification> notifications) {
    if (_selectedTypeFilter == 'all') return notifications;

    NotificationType? filterType;
    switch (_selectedTypeFilter) {
      case 'queue':
        filterType = NotificationType.queue;
        break;
      case 'appointment':
        filterType = NotificationType.appointment;
        break;
      case 'labResult':
        filterType = NotificationType.labResult;
        break;
      case 'payment':
        filterType = NotificationType.payment;
        break;
      case 'system':
        filterType = NotificationType.system;
        break;
      case 'healthTip':
        filterType = NotificationType.healthTip;
        break;
    }

    return filterType != null
        ? notifications.where((n) => n.type == filterType).toList()
        : notifications;
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.queue:
        return const Color(0xFF3498DB);
      case NotificationType.appointment:
        return const Color(0xFF9B59B6);
      case NotificationType.labResult:
        return const Color(0xFF2ECC71);
      case NotificationType.payment:
        return const Color(0xFFF39C12);
      case NotificationType.system:
        return const Color(0xFF34495E);
      case NotificationType.healthTip:
        return const Color(0xFF1ABC9C);
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.queue:
        return Icons.schedule;
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.labResult:
        return Icons.science;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.system:
        return Icons.system_update;
      case NotificationType.healthTip:
        return Icons.health_and_safety;
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return const Color(0xFFE74C3C);
      case NotificationPriority.medium:
        return const Color(0xFFF39C12);
      case NotificationPriority.low:
        return const Color(0xFF95A5A6);
    }
  }

  String _getPriorityText(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return 'PENTING';
      case NotificationPriority.medium:
        return 'NORMAL';
      case NotificationPriority.low:
        return 'INFO';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Notifikasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'all',
            'queue',
            'appointment',
            'labResult',
            'payment',
            'system',
            'healthTip'
          ]
              .map(
                (type) => RadioListTile<String>(
                  title: Text(_getFilterTypeName(type)),
                  value: type,
                  groupValue: _selectedTypeFilter,
                  onChanged: (value) {
                    setState(() => _selectedTypeFilter = value!);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _getFilterTypeName(String type) {
    switch (type) {
      case 'all':
        return 'Semua Notifikasi';
      case 'queue':
        return 'Antrean';
      case 'appointment':
        return 'Jadwal Konsultasi';
      case 'labResult':
        return 'Hasil Lab';
      case 'payment':
        return 'Pembayaran';
      case 'system':
        return 'Sistem';
      case 'healthTip':
        return 'Tips Kesehatan';
      default:
        return type;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _unreadNotifications) {
        notification.isRead = true;
      }
      _unreadNotifications.clear();
    });
    _showSnackBar('Semua notifikasi ditandai sudah dibaca');
  }

  void _handleNotificationTap(HospitalNotification notification) {
    // Mark as read
    if (!notification.isRead) {
      setState(() {
        notification.isRead = true;
        _unreadNotifications.remove(notification);
      });
    }

    // Handle action
    if (notification.actionUrl != null) {
      _handleNotificationAction(notification);
    } else {
      _showSnackBar('Detail: ${notification.title}');
    }
  }

  void _handleNotificationAction(HospitalNotification notification) {
    switch (notification.type) {
      case NotificationType.queue:
        _showSnackBar(
            'Membuka detail antrean ${notification.relatedData?['queueNumber']}');
        break;
      case NotificationType.appointment:
        _showSnackBar('Membuka jadwal konsultasi');
        break;
      case NotificationType.labResult:
        _showSnackBar('Membuka hasil lab');
        break;
      case NotificationType.payment:
        _showSnackBar('Membuka receipt pembayaran');
        break;
      default:
        _showSnackBar('Membuka ${notification.title}');
    }
  }

  void _showTestNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.notification_add, color: Color(0xFF2E7D89)),
            SizedBox(width: 8),
            Text('Test Notifikasi'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih jenis notifikasi untuk ditest:'),
            SizedBox(height: 16),
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
              _sendTestNotification();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D89),
            ),
            child: const Text(
              'Kirim Test',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification() {
    NotificationService.sendTestNotification();
    _showSnackBar('Test notifikasi berhasil dikirim!');

    // Add test notification to list
    setState(() {
      final testNotif = HospitalNotification(
        id: 'TEST_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Notifikasi',
        message:
            'Ini adalah test notifikasi untuk memastikan sistem berjalan dengan baik.',
        type: NotificationType.system,
        priority: NotificationPriority.low,
        timestamp: DateTime.now(),
        isRead: false,
        hospitalName: 'HospitalLink Test',
      );

      _allNotifications.insert(0, testNotif);
      _unreadNotifications.insert(0, testNotif);
    });
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
