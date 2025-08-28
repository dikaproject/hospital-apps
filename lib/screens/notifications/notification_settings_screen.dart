import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _queueNotifications = true;
  bool _appointmentNotifications = true;
  bool _labResultNotifications = true;
  bool _paymentNotifications = true;
  bool _systemNotifications = false;
  bool _healthTipsNotifications = true;
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '07:00';
  bool _quietHoursEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load from SharedPreferences or similar
    // For now, using default values
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
          'Pengaturan Notifikasi',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: Color(0xFF2E7D89),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainSettings(),
            const SizedBox(height: 24),
            _buildNotificationTypes(),
            const SizedBox(height: 24),
            _buildQuietHours(),
            const SizedBox(height: 24),
            _buildTestSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSettings() {
    return _buildSection(
      title: 'Pengaturan Utama',
      icon: Icons.settings,
      children: [
        _buildSwitchTile(
          title: 'Push Notifikasi',
          subtitle: 'Terima notifikasi dari aplikasi',
          value: _pushNotifications,
          onChanged: (value) {
            setState(() => _pushNotifications = value);
            if (!value) {
              // Disable all other notifications
              setState(() {
                _soundEnabled = false;
                _vibrationEnabled = false;
              });
            }
          },
        ),
        _buildSwitchTile(
          title: 'Suara Notifikasi',
          subtitle: 'Mainkan suara saat ada notifikasi',
          value: _soundEnabled,
          onChanged: _pushNotifications
              ? (value) => setState(() => _soundEnabled = value)
              : null,
        ),
        _buildSwitchTile(
          title: 'Getaran',
          subtitle: 'Bergetar saat ada notifikasi',
          value: _vibrationEnabled,
          onChanged: _pushNotifications
              ? (value) => setState(() => _vibrationEnabled = value)
              : null,
        ),
      ],
    );
  }

  Widget _buildNotificationTypes() {
    return _buildSection(
      title: 'Jenis Notifikasi',
      icon: Icons.category,
      children: [
        _buildSwitchTile(
          title: 'Antrean',
          subtitle: 'Update status antrean dan panggilan',
          value: _queueNotifications,
          onChanged: _pushNotifications
              ? (value) => setState(() => _queueNotifications = value)
              : null,
          leading: const Icon(Icons.schedule, color: Color(0xFF3498DB)),
        ),
        _buildSwitchTile(
          title: 'Jadwal Konsultasi',
          subtitle: 'Reminder jadwal dan perubahan',
          value: _appointmentNotifications,
          onChanged: _pushNotifications
              ? (value) => setState(() => _appointmentNotifications = value)
              : null,
          leading: const Icon(Icons.calendar_today, color: Color(0xFF9B59B6)),
        ),
        _buildSwitchTile(
          title: 'Hasil Lab',
          subtitle: 'Notifikasi hasil pemeriksaan lab',
          value: _labResultNotifications,
          onChanged: _pushNotifications
              ? (value) => setState(() => _labResultNotifications = value)
              : null,
          leading: const Icon(Icons.science, color: Color(0xFF2ECC71)),
        ),
        _buildSwitchTile(
          title: 'Pembayaran',
          subtitle: 'Konfirmasi dan receipt pembayaran',
          value: _paymentNotifications,
          onChanged: _pushNotifications
              ? (value) => setState(() => _paymentNotifications = value)
              : null,
          leading: const Icon(Icons.payment, color: Color(0xFFF39C12)),
        ),
        _buildSwitchTile(
          title: 'Update Sistem',
          subtitle: 'Info update aplikasi dan maintenance',
          value: _systemNotifications,
          onChanged: _pushNotifications
              ? (value) => setState(() => _systemNotifications = value)
              : null,
          leading: const Icon(Icons.system_update, color: Color(0xFF34495E)),
        ),
        _buildSwitchTile(
          title: 'Tips Kesehatan',
          subtitle: 'Artikel dan tips kesehatan harian',
          value: _healthTipsNotifications,
          onChanged: _pushNotifications
              ? (value) => setState(() => _healthTipsNotifications = value)
              : null,
          leading:
              const Icon(Icons.health_and_safety, color: Color(0xFF1ABC9C)),
        ),
      ],
    );
  }

  Widget _buildQuietHours() {
    return _buildSection(
      title: 'Jam Tenang',
      icon: Icons.bedtime,
      children: [
        _buildSwitchTile(
          title: 'Aktifkan Jam Tenang',
          subtitle: 'Nonaktifkan notifikasi pada jam tertentu',
          value: _quietHoursEnabled,
          onChanged: _pushNotifications
              ? (value) => setState(() => _quietHoursEnabled = value)
              : null,
        ),
        if (_quietHoursEnabled && _pushNotifications) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  label: 'Mulai',
                  time: _quietHoursStart,
                  onTimeChanged: (time) =>
                      setState(() => _quietHoursStart = time),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(
                  label: 'Selesai',
                  time: _quietHoursEnd,
                  onTimeChanged: (time) =>
                      setState(() => _quietHoursEnd = time),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTestSection() {
    return _buildSection(
      title: 'Test Notifikasi',
      icon: Icons.bug_report,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info, color: Color(0xFF3498DB), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Test Pengaturan Notifikasi',
                    style: TextStyle(
                      color: Color(0xFF3498DB),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Gunakan tombol di bawah untuk menguji apakah notifikasi bekerja dengan pengaturan saat ini.',
                style: TextStyle(
                  color: Color(0xFF3498DB),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pushNotifications ? _testSound : null,
                      icon: Icon(
                        _soundEnabled ? Icons.volume_up : Icons.volume_off,
                        size: 16,
                      ),
                      label: const Text('Test Suara',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3498DB),
                        side: const BorderSide(color: Color(0xFF3498DB)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pushNotifications ? _testVibration : null,
                      icon: Icon(
                        _vibrationEnabled
                            ? Icons.vibration
                            : Icons.phone_android,
                        size: 16,
                      ),
                      label: const Text('Test Getar',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3498DB),
                        side: const BorderSide(color: Color(0xFF3498DB)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pushNotifications ? _testFullNotification : null,
                  icon: const Icon(Icons.notification_add, size: 16),
                  label: const Text('Test Notifikasi Lengkap',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2E7D89), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    Widget? leading,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onChanged != null
                        ? const Color(0xFF2C3E50)
                        : const Color(0xFF95A5A6),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: onChanged != null
                        ? const Color(0xFF7F8C8D)
                        : const Color(0xFF95A5A6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2E7D89),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required String time,
    required ValueChanged<String> onTimeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _selectTime(context, time, onTimeChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, String currentTime,
      ValueChanged<String> onTimeChanged) async {
    final timeParts = currentTime.split(':');
    final currentTimeOfDay = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTimeOfDay,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D89),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onTimeChanged(formattedTime);
    }
  }

  void _testSound() {
    NotificationService.testSound();
    _showSnackBar('Test suara diputar');
  }

  void _testVibration() {
    NotificationService.testVibration();
    _showSnackBar('Test getaran dijalankan');
  }

  void _testFullNotification() {
    NotificationService.sendTestNotification();
    _showSnackBar('Test notifikasi lengkap dikirim');
  }

  void _saveSettings() {
    // Save to SharedPreferences or similar storage
    NotificationService.updateSettings({
      'pushNotifications': _pushNotifications,
      'soundEnabled': _soundEnabled,
      'vibrationEnabled': _vibrationEnabled,
      'queueNotifications': _queueNotifications,
      'appointmentNotifications': _appointmentNotifications,
      'labResultNotifications': _labResultNotifications,
      'paymentNotifications': _paymentNotifications,
      'systemNotifications': _systemNotifications,
      'healthTipsNotifications': _healthTipsNotifications,
      'quietHoursEnabled': _quietHoursEnabled,
      'quietHoursStart': _quietHoursStart,
      'quietHoursEnd': _quietHoursEnd,
    });

    _showSnackBar('Pengaturan notifikasi berhasil disimpan');
    Navigator.pop(context);
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
