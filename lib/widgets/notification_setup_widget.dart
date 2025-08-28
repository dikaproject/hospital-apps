import 'package:flutter/material.dart';
import '../models/lab_models.dart';

class NotificationSetupWidget extends StatefulWidget {
  final Medication medication;
  final Function(Medication) onSave;

  const NotificationSetupWidget({
    super.key,
    required this.medication,
    required this.onSave,
  });

  @override
  State<NotificationSetupWidget> createState() =>
      _NotificationSetupWidgetState();
}

class _NotificationSetupWidgetState extends State<NotificationSetupWidget> {
  late Medication _medication;
  List<String> _selectedTimes = [];
  int _selectedDuration = 7;

  final List<String> _timeSlots = [
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00'
  ];

  final List<int> _durationOptions = [3, 7, 14, 21, 30];

  @override
  void initState() {
    super.initState();
    _medication = widget.medication;
    _selectedTimes = List.from(_medication.reminderTimes);
    _selectedDuration = _medication.duration;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMedicationInfo(),
                  const SizedBox(height: 24),
                  _buildReminderToggle(),
                  if (_medication.reminderEnabled) ...[
                    const SizedBox(height: 24),
                    _buildTimeSelection(),
                    const SizedBox(height: 24),
                    _buildDurationSelection(),
                    const SizedBox(height: 24),
                    _buildPreviewSection(),
                  ],
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Color(0xFF3498DB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pengaturan Pengingat Obat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Color(0xFF7F8C8D)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _medication.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.medication, color: Colors.grey[600], size: 14),
              const SizedBox(width: 6),
              Text(
                '${_medication.dosage} • ${_medication.frequency}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600], size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _medication.instructions,
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
    );
  }

  Widget _buildReminderToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktifkan Pengingat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dapatkan notifikasi untuk minum obat tepat waktu',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _medication.reminderEnabled,
            onChanged: (value) {
              setState(() {
                _medication.reminderEnabled = value;
                if (!value) {
                  _selectedTimes.clear();
                }
              });
            },
            activeColor: const Color(0xFF2ECC71),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Waktu Pengingat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Sesuaikan dengan frekuensi: ${_medication.frequency}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.map((time) {
                  final isSelected = _selectedTimes.contains(time);
                  return GestureDetector(
                    onTap: () => _toggleTime(time),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2E7D89)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2E7D89)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durasi Pengingat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Berapa lama ingin diingatkan?',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: _durationOptions.map((duration) {
                  final isSelected = _selectedDuration == duration;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDuration = duration),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2E7D89)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2E7D89)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        '$duration hari',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.preview, color: Color(0xFF3498DB), size: 16),
              const SizedBox(width: 8),
              const Text(
                'Preview Pengingat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedTimes.isNotEmpty) ...[
            Text(
              'Anda akan diingatkan setiap hari pada:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedTimes.join(' • '),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3498DB),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selama $_selectedDuration hari ke depan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ] else ...[
            Text(
              'Pilih waktu pengingat terlebih dahulu',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
            onPressed: _selectedTimes.isNotEmpty || !_medication.reminderEnabled
                ? _saveSettings
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D89),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Simpan Pengaturan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
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
              'Batal',
              style: TextStyle(
                color: Color(0xFF7F8C8D),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleTime(String time) {
    setState(() {
      if (_selectedTimes.contains(time)) {
        _selectedTimes.remove(time);
      } else {
        _selectedTimes.add(time);
      }
      _selectedTimes.sort();
    });
  }

  void _saveSettings() {
    final updatedMedication = Medication(
      id: _medication.id,
      name: _medication.name,
      dosage: _medication.dosage,
      frequency: _medication.frequency,
      duration: _selectedDuration,
      instructions: _medication.instructions,
      sideEffects: _medication.sideEffects,
      isActive: _medication.isActive,
      reminderEnabled: _medication.reminderEnabled,
      reminderTimes: _selectedTimes,
    );

    widget.onSave(updatedMedication);
    Navigator.pop(context);
  }
}
