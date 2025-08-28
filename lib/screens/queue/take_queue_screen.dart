import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'queue_detail_screen.dart';
import '../consultation/ai_consultation_screen.dart';

class TakeQueueScreen extends StatefulWidget {
  const TakeQueueScreen({super.key});

  @override
  State<TakeQueueScreen> createState() => _TakeQueueScreenState();
}

class _TakeQueueScreenState extends State<TakeQueueScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentStep = 0;
  String? _selectedSpecialty;
  String? _selectedDoctor;
  String? _selectedTime;
  String? _selectedDate;
  bool _isExistingPatient = true;
  String? _consultationId;

  final List<String> _specialties = [
    'Dokter Umum',
    'Spesialis Penyakit Dalam',
    'Spesialis Jantung',
    'Spesialis Mata',
    'Spesialis THT',
    'Spesialis Kulit',
    'Spesialis Neurologi',
    'Spesialis Orthopedi',
  ];

  final Map<String, List<String>> _doctorsBySpecialty = {
    'Dokter Umum': ['Dr. Sarah Wijaya', 'Dr. Budi Santoso', 'Dr. Maya Sari'],
    'Spesialis Penyakit Dalam': ['Dr. Ahmad Rahman, Sp.PD', 'Dr. Siti Nurhaliza, Sp.PD'],
    'Spesialis Jantung': ['Dr. Joko Anwar, Sp.JP', 'Dr. Rina Kartika, Sp.JP'],
    'Spesialis Mata': ['Dr. David Chen, Sp.M', 'Dr. Lisa Indah, Sp.M'],
    'Spesialis THT': ['Dr. Eko Prasetyo, Sp.THT', 'Dr. Dewi Sartika, Sp.THT'],
    'Spesialis Kulit': ['Dr. Andi Wijaya, Sp.KK', 'Dr. Nurul Hidayah, Sp.KK'],
    'Spesialis Neurologi': ['Dr. Bambang Sutrisno, Sp.N', 'Dr. Indira Safitri, Sp.N'],
    'Spesialis Orthopedi': ['Dr. Rudi Hartono, Sp.OT', 'Dr. Melissa Tan, Sp.OT'],
  };

  final List<String> _timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
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
          'Ambil Antrean',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: _buildStepContent(),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _getStepTitle(),
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Langkah ${_currentStep + 1} dari 4',
                style: const TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= _currentStep 
                        ? const Color(0xFF2E7D89) 
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPatientTypeStep();
      case 1:
        return _buildSpecialtyStep();
      case 2:
        return _buildDoctorStep();
      case 3:
        return _buildScheduleStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPatientTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jenis Kunjungan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih jenis kunjungan yang sesuai dengan kebutuhan Anda',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 24),
          _buildPatientTypeCard(
            title: 'Pasien Baru',
            subtitle: 'Kunjungan pertama untuk keluhan baru',
            icon: Icons.person_add,
            isSelected: !_isExistingPatient,
            onTap: () => setState(() => _isExistingPatient = false),
          ),
          const SizedBox(height: 16),
          _buildPatientTypeCard(
            title: 'Pasien Lama',
            subtitle: 'Kontrol rutin atau lanjutan konsultasi',
            icon: Icons.person,
            isSelected: _isExistingPatient,
            onTap: () => setState(() => _isExistingPatient = true),
          ),
          const SizedBox(height: 24),
          if (_isExistingPatient) _buildConsultationIdInput(),
          const SizedBox(height: 24),
          _buildConsultationOption(),
        ],
      ),
    );
  }

  Widget _buildPatientTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D89) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF2E7D89) 
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
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
                      color: isSelected 
                          ? const Color(0xFF2E7D89) 
                          : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D89),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationIdInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D89).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF2E7D89),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'ID Konsultasi (Opsional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D89),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Masukkan ID konsultasi sebelumnya',
              hintStyle: const TextStyle(color: Color(0xFF7F8C8D)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => _consultationId = value,
          ),
          const SizedBox(height: 8),
          const Text(
            'Jika Anda memiliki ID konsultasi online sebelumnya, masukkan untuk mendapat prioritas antrean',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationOption() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Konsultasi AI Dulu?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Dapatkan konsultasi awal gratis dengan AI untuk menentukan jenis pemeriksaan yang tepat',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startAIConsultation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF667EEA),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mulai Konsultasi AI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Spesialis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih jenis spesialis sesuai dengan keluhan Anda',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 24),
          ...(_specialties.map((specialty) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSpecialtyCard(specialty),
              ))),
        ],
      ),
    );
  }

  Widget _buildSpecialtyCard(String specialty) {
    bool isSelected = _selectedSpecialty == specialty;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedSpecialty = specialty),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D89) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF2E7D89) 
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getSpecialtyIcon(specialty),
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                specialty,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected 
                      ? const Color(0xFF2E7D89) 
                      : const Color(0xFF2C3E50),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D89),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorStep() {
    List<String> doctors = _doctorsBySpecialty[_selectedSpecialty] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Dokter $_selectedSpecialty',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih dokter yang tersedia untuk konsultasi hari ini',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 24),
          ...(doctors.map((doctor) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildDoctorCard(doctor),
              ))),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(String doctorName) {
    bool isSelected = _selectedDoctor == doctorName;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedDoctor = doctorName),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D89) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected 
                      ? [const Color(0xFF2E7D89), const Color(0xFF4ECDC4)]
                      : [Colors.grey[300]!, Colors.grey[400]!],
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
                    doctorName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? const Color(0xFF2E7D89) 
                          : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedSpecialty ?? '',
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Tersedia',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D89),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Jadwal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih tanggal dan waktu yang tersedia',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 24),
          _buildDateSelection(),
          const SizedBox(height: 24),
          _buildTimeSelection(),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
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
            'Pilih Tanggal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                DateTime date = DateTime.now().add(Duration(days: index));
                String dateStr = '${date.day}/${date.month}';
                bool isSelected = _selectedDate == dateStr;
                
                return Padding(
                  padding: EdgeInsets.only(right: index < 6 ? 12 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDate = dateStr),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF2E7D89) 
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getDayName(date.weekday),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelection() {
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
            'Pilih Waktu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              String time = _timeSlots[index];
              bool isSelected = _selectedTime == time;
              bool isAvailable = Random().nextBool(); // Mock availability
              
              return GestureDetector(
                onTap: isAvailable ? () => setState(() => _selectedTime = time) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: !isAvailable 
                        ? Colors.grey[200]
                        : isSelected 
                            ? const Color(0xFF2E7D89)
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: !isAvailable 
                          ? Colors.grey[300]!
                          : isSelected 
                              ? const Color(0xFF2E7D89)
                              : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: !isAvailable 
                            ? Colors.grey[500]
                            : isSelected 
                                ? Colors.white
                                : const Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF7F8C8D)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sebelumnya',
                  style: TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D89),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(
                _currentStep == 3 ? 'Buat Antrean' : 'Selanjutnya',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Jenis Kunjungan';
      case 1:
        return 'Pilih Spesialis';
      case 2:
        return 'Pilih Dokter';
      case 3:
        return 'Pilih Jadwal';
      default:
        return '';
    }
  }

  IconData _getSpecialtyIcon(String specialty) {
    switch (specialty) {
      case 'Dokter Umum':
        return Icons.local_hospital;
      case 'Spesialis Penyakit Dalam':
        return Icons.favorite;
      case 'Spesialis Jantung':
        return Icons.monitor_heart;
      case 'Spesialis Mata':
        return Icons.visibility;
      case 'Spesialis THT':
        return Icons.hearing;
      case 'Spesialis Kulit':
        return Icons.face;
      case 'Spesialis Neurologi':
        return Icons.psychology;
      case 'Spesialis Orthopedi':
        return Icons.accessibility;
      default:
        return Icons.medical_services;
    }
  }

  String _getDayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // Always can proceed from patient type
      case 1:
        return _selectedSpecialty != null;
      case 2:
        return _selectedDoctor != null;
      case 3:
        return _selectedDate != null && _selectedTime != null;
      default:
        return false;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _createQueue();
    }
  }

  void _createQueue() {
    // Generate queue number
    final queueNumber = 'M${Random().nextInt(50) + 1}';
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QueueDetailScreen(
          queueNumber: queueNumber,
          isFromAutoQueue: false,
        ),
      ),
    );
  }

  void _startAIConsultation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AIConsultationScreen(),
      ),
    );
  }
}