import 'package:flutter/material.dart';
import '../../models/consultation_models.dart';
import '../../services/consultation_service.dart';
import '../../services/chat_consultation_service.dart';
import 'chat_consultation_screen.dart';
import 'chat_consultation_list_screen.dart'; // Add this import

class DirectConsultationScreen extends StatefulWidget {
  const DirectConsultationScreen({super.key});

  @override
  State<DirectConsultationScreen> createState() =>
      _DirectConsultationScreenState();
}

class _DirectConsultationScreenState extends State<DirectConsultationScreen> {
  List<DoctorInfo> _availableDoctors = [];
  DoctorInfo? _selectedDoctor;
  bool _isLoading = true;
  bool _isBooking = false;
  String? _errorMessage; // Add error state

  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Don't call _loadAvailableDoctors here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call after dependencies are ready
    if (_isLoading) {
      _loadAvailableDoctors();
    }
  }

  void _loadAvailableDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final doctors = await ConsultationService.getAvailableDoctors();

      final generalDoctors = doctors
          .where((doctor) => doctor.isGeneralPractitioner && doctor.isAvailable)
          .toList();

      if (mounted) {
        setState(() {
          _availableDoctors = generalDoctors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat daftar dokter: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
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
          'Konsultasi Langsung',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBookButton(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return _buildConsultationForm();
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
            'Memuat daftar dokter...',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAvailableDoctors,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D89),
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildDoctorSelection(),
          const SizedBox(height: 24),
          _buildSymptomsInput(),
          const SizedBox(height: 24),
          _buildNotesInput(),
          const SizedBox(height: 24),
          if (_selectedDoctor != null) _buildFeeInfo(),
          const SizedBox(height: 100), // Space for bottom button
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
              Icon(Icons.medical_services, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Konsultasi Langsung',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ Langsung chat dengan dokter umum pilihan',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  '✅ Tanpa screening AI terlebih dahulu',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  '✅ Respons dokter dalam 1-4 jam',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Dokter Umum',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        if (_availableDoctors.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.medical_services_outlined,
                      size: 48, color: Color(0xFF7F8C8D)),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada dokter tersedia',
                    style: TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Coba lagi dalam beberapa saat',
                    style: TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableDoctors.length,
            itemBuilder: (context, index) {
              final doctor = _availableDoctors[index];
              final isSelected = _selectedDoctor?.id == doctor.id;

              return GestureDetector(
                onTap: () => _selectDoctor(doctor),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2E7D89).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2E7D89)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D89).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: doctor.photoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(
                                  doctor.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person,
                                          color: Color(0xFF2E7D89)),
                                ),
                              )
                            : const Icon(Icons.person,
                                color: Color(0xFF2E7D89)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
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
                              doctor.specialtyDisplay,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                            if (doctor.experience != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                doctor.experience!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF7F8C8D),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            doctor.formattedFee,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(0xFF2E7D89)
                                  : const Color(0xFF2C3E50),
                            ),
                          ),
                          if (doctor.rating != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  doctor.rating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF7F8C8D),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSymptomsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gejala yang Dirasakan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _symptomsController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Ceritakan gejala yang Anda rasakan...',
              hintStyle: TextStyle(color: Color(0xFF7F8C8D)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan Tambahan (Opsional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Informasi tambahan yang perlu dokter ketahui...',
              hintStyle: TextStyle(color: Color(0xFF7F8C8D)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long, color: Color(0xFF2E7D89), size: 20),
              SizedBox(width: 8),
              Text(
                'Rincian Biaya',
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
                child: Text(
                  'Konsultasi dengan ${_selectedDoctor!.name}',
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                _selectedDoctor!.formattedFee,
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Biaya',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _selectedDoctor!.formattedFee,
                style: const TextStyle(
                  color: Color(0xFF2E7D89),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    final canBook = _selectedDoctor != null &&
        _symptomsController.text.trim().isNotEmpty &&
        !_isBooking;

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
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canBook ? _bookDirectConsultation : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D89),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: _isBooking
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Memproses...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    canBook
                        ? 'Mulai Konsultasi - ${_selectedDoctor!.formattedFee}'
                        : 'Lengkapi Data Konsultasi',
                    style: TextStyle(
                      color: canBook ? Colors.white : Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _selectDoctor(DoctorInfo doctor) {
    setState(() {
      _selectedDoctor = doctor;
    });
  }

  void _bookDirectConsultation() async {
    if (_selectedDoctor == null || _symptomsController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isBooking = true);

    try {
      final symptoms = _symptomsController.text
          .trim()
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // Direct consultation - auto paid
      final result = await ConsultationService.startDirectConsultation(
        doctorId: _selectedDoctor!.id,
        symptoms: symptoms,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (mounted) {
        _showSuccessAndNavigateToChat(result);
      }
    } catch (e) {
      setState(() => _isBooking = false);
      // _showErrorSnackBar('Gagal memulai konsultasi: $e');
    } finally {
      setState(() => _isBooking = false);
    }
  }

  // Direct success and navigate to chat
  void _showSuccessAndNavigateToChat(DirectConsultationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF2ECC71),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Konsultasi Berhasil Dimulai!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Chat dengan ${result.doctor.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Biaya: ${result.doctor.formattedFee} (Tunai)',
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chat sudah siap! Dokter akan merespons dalam 1-4 jam.',
              style: TextStyle(
                color: Color(0xFF7F8C8D),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToChat(result);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D89),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Mulai Chat Sekarang',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChat(DirectConsultationResult result) {
    final chatConsultation = ChatConsultation(
      id: result.consultationId,
      doctorName: result.doctor.name,
      specialty: result.doctor.specialtyDisplay,
      scheduledTime: result.scheduledTime,
      status: ConsultationStatus.inProgress,
      queuePosition: result.position,
      estimatedWaitMinutes: result.estimatedWaitMinutes,
      messages: [],
      hasUnreadMessages: false,
    );

    // Navigate back to main screen, then to chat list, then to specific chat
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    // Then navigate to chat list first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatConsultationListScreen(),
      ),
    ).then((_) {
      // After chat list loads, automatically open the new chat
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConsultationScreen(
                consultation: chatConsultation,
              ),
            ),
          );
        }
      });
    });
  }
}
