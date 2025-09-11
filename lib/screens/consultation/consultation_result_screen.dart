import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/chat_models.dart';
import '../../models/consultation_models.dart';
import 'doctor_call_screen.dart';
import 'general_doctor_call_screen.dart';

class ConsultationResultScreen extends StatefulWidget {
  final List<ChatMessage> chatHistory;
  final AIScreeningResult? aiResult; // Add this parameter

  const ConsultationResultScreen({
    super.key,
    required this.chatHistory,
    this.aiResult, // Add this parameter
  });

  @override
  State<ConsultationResultScreen> createState() =>
      _ConsultationResultScreenState();
}

class _ConsultationResultScreenState extends State<ConsultationResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  ConsultationResult? _result;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _analyzeConsultation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _analyzeConsultation() {
    // Check if we already have AI result from backend
    if (widget.aiResult != null) {
      setState(() {
        _result = _convertAIResultToConsultationResult(widget.aiResult!);
        _isAnalyzing = false;
      });
      _animationController.forward();
      return;
    }

    // Fallback to mock analysis if no AI result
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _result = _generateMockResult();
          _isAnalyzing = false;
        });
        _animationController.forward();
      }
    });
  }

  // Add method to convert AI result to ConsultationResult
  ConsultationResult _convertAIResultToConsultationResult(
      AIScreeningResult aiResult) {
    ConsultationSeverity severity;
    switch (aiResult.severity.toUpperCase()) {
      case 'LOW':
        severity = ConsultationSeverity.low;
        break;
      case 'HIGH':
        severity = ConsultationSeverity.high;
        break;
      default:
        severity = ConsultationSeverity.medium;
    }

    return ConsultationResult(
      severity: severity,
      title: _getSeverityTitle(severity),
      description: aiResult.message,
      recommendations: _getRecommendationsFromAI(aiResult),
      followUp: _getFollowUpFromAI(aiResult),
      doctorSpecialty: aiResult.needsDoctorConsultation ? 'Dokter Umum' : null,
      isUrgent: severity == ConsultationSeverity.high,
    );
  }

  String _getSeverityTitle(ConsultationSeverity severity) {
    switch (severity) {
      case ConsultationSeverity.low:
        return 'Keluhan Ringan';
      case ConsultationSeverity.medium:
        return 'Keluhan Sedang';
      case ConsultationSeverity.high:
        return 'Keluhan Serius';
    }
  }

  List<String> _getRecommendationsFromAI(AIScreeningResult aiResult) {
    // Extract recommendations from AI analysis
    if (aiResult.symptomsAnalysis != null &&
        aiResult.symptomsAnalysis!['recommendations'] != null) {
      return List<String>.from(aiResult.symptomsAnalysis!['recommendations']);
    }

    // Default recommendations based on severity
    switch (aiResult.severity.toUpperCase()) {
      case 'LOW':
        return [
          'Istirahat yang cukup',
          'Perbanyak minum air putih',
          'Konsumsi makanan bergizi',
          'Monitor kondisi selama 2-3 hari'
        ];
      case 'HIGH':
        return [
          'Segera konsultasi dengan dokter',
          'Jangan tunda pengobatan',
          'Siapkan riwayat medis lengkap',
          'Dampingi dengan keluarga'
        ];
      default:
        return [
          'Konsultasi dengan dokter dalam 24 jam',
          'Istirahat yang cukup',
          'Hindari aktivitas berat',
          'Monitor gejala secara berkala'
        ];
    }
  }

  String _getFollowUpFromAI(AIScreeningResult aiResult) {
    if (aiResult.needsDoctorConsultation) {
      return 'Disarankan untuk konsultasi dengan dokter untuk evaluasi lebih lanjut dan mendapatkan penanganan yang tepat.';
    } else {
      return 'Pantau kondisi selama 3-5 hari. Jika kondisi memburuk atau tidak membaik, segera konsultasi dengan dokter.';
    }
  }

  ConsultationResult _generateMockResult() {
    // Mock analysis based on chat history
    final random = Random();
    final severity = ConsultationSeverity.values[random.nextInt(3)];

    switch (severity) {
      case ConsultationSeverity.low:
        return ConsultationResult(
          severity: severity,
          title: 'Keluhan Ringan',
          description:
              'Berdasarkan gejala yang Anda sampaikan, kondisi ini termasuk kategori ringan.',
          recommendations: [
            'Istirahat yang cukup (7-8 jam per hari)',
            'Perbanyak minum air putih (8 gelas per hari)',
            'Konsumsi makanan bergizi seimbang',
            'Hindari stress berlebihan',
            'Lakukan olahraga ringan secara teratur'
          ],
          medication: [
            'Paracetamol 500mg (3x sehari setelah makan)',
            'Vitamin C 1000mg (1x sehari)',
          ],
          followUp:
              'Pantau kondisi selama 3-5 hari. Jika tidak membaik, konsultasi ke dokter.',
        );

      case ConsultationSeverity.medium:
        return ConsultationResult(
          severity: severity,
          title: 'Keluhan Sedang',
          description:
              'Gejala yang Anda alami memerlukan perhatian medis lebih lanjut.',
          recommendations: [
            'Segera konsultasi dengan dokter spesialis',
            'Istirahat total selama 2-3 hari',
            'Hindari aktivitas berat',
            'Monitor suhu tubuh secara berkala'
          ],
          doctorSpecialty: 'Dokter Umum',
          followUp:
              'Disarankan untuk konsultasi langsung dengan dokter dalam 24 jam.',
        );

      case ConsultationSeverity.high:
        return ConsultationResult(
          severity: severity,
          title: 'Keluhan Serius',
          description: 'Kondisi Anda memerlukan penanganan medis segera.',
          recommendations: [
            'Segera konsultasi dengan dokter spesialis',
            'Jangan tunda pengobatan',
            'Siapkan riwayat medis lengkap',
            'Dampingi dengan keluarga saat konsultasi'
          ],
          doctorSpecialty: 'Dokter Spesialis Penyakit Dalam',
          followUp:
              'Disarankan untuk konsultasi langsung dengan dokter sekarang juga.',
          isUrgent: true,
        );
    }
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
          'Hasil Konsultasi AI',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isAnalyzing ? _buildAnalyzingView() : _buildResultView(),
    );
  }

  Widget _buildAnalyzingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D89), Color(0xFF4ECDC4)],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI sedang menganalisis...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mohon tunggu sebentar',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (_result == null) return const SizedBox();

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSeverityCard(),
                const SizedBox(height: 20),
                _buildRecommendationsCard(),
                if (_result!.medication != null) ...[
                  const SizedBox(height: 20),
                  _buildMedicationCard(),
                ],
                const SizedBox(height: 20),
                _buildFollowUpCard(),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeverityCard() {
    Color severityColor;
    IconData severityIcon;

    switch (_result!.severity) {
      case ConsultationSeverity.low:
        severityColor = const Color(0xFF2ECC71);
        severityIcon = Icons.check_circle;
        break;
      case ConsultationSeverity.medium:
        severityColor = const Color(0xFFF39C12);
        severityIcon = Icons.warning;
        break;
      case ConsultationSeverity.high:
        severityColor = const Color(0xFFE74C3C);
        severityIcon = Icons.error;
        break;
    }

    return Container(
      width: double.infinity,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  severityIcon,
                  color: severityColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result!.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      _getSeverityLabel(_result!.severity),
                      style: TextStyle(
                        fontSize: 12,
                        color: severityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _result!.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Container(
      width: double.infinity,
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
                Icons.lightbulb_outline,
                color: Color(0xFF3498DB),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Rekomendasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_result!.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3498DB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rec,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ))),
        ],
      ),
    );
  }

  Widget _buildMedicationCard() {
    if (_result!.medication == null || _result!.medication!.isEmpty) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
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
                Icons.medication,
                color: Color(0xFF9B59B6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Saran Obat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_result!.medication!.map((med) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9B59B6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        med,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ))),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFFFF9800),
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Konsultasikan dengan apoteker sebelum mengonsumsi obat',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE65100),
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

  Widget _buildFollowUpCard() {
    return Container(
      width: double.infinity,
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
                color: Color(0xFF1ABC9C),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Tindak Lanjut',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _result!.followUp,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
              height: 1.5,
            ),
          ),
          if (_result!.doctorSpecialty != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_hospital,
                    color: Color(0xFF1976D2),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Disarankan konsultasi dengan: ${_result!.doctorSpecialty}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
        if (_result!.severity == ConsultationSeverity.low) ...[
          // Untuk keluhan ringan, tetap bisa pilih ikuti saran AI atau konsul dokter umum
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ikuti Saran AI',
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
              onPressed: _consultWithGeneralDoctor,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E7D89)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Konsultasi Dokter Umum',
                style: TextStyle(
                  color: Color(0xFF2E7D89),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else ...[
          // Untuk keluhan sedang/tinggi, langsung ke dokter umum dulu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF9800)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFFF9800),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Rekomendasi Konsultasi',
                        style: TextStyle(
                          color: Color(0xFFE65100),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Anda akan dihubungkan dengan Dokter Umum terlebih dahulu untuk evaluasi awal. Dokter akan menentukan apakah perlu rujukan ke spesialis.',
                  style: TextStyle(
                    color: Color(0xFFE65100),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _consultWithGeneralDoctor,
              style: ElevatedButton.styleFrom(
                backgroundColor: _result!.isUrgent
                    ? const Color(0xFFE74C3C)
                    : const Color(0xFF2E7D89),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _result!.isUrgent ? Icons.emergency : Icons.video_call,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _result!.isUrgent
                        ? 'Konsultasi Darurat - Dokter Umum'
                        : 'Konsultasi Dokter Umum',
                    style: const TextStyle(
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
              'Kembali ke Dashboard',
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

  void _consultWithDoctor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorCallScreen(
          consultationResult: _result!,
        ),
      ),
    );
  }

  void _consultWithGeneralDoctor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneralDoctorCallScreen(
          consultationResult: _result!,
        ),
      ),
    );
  }

  String _getSeverityLabel(ConsultationSeverity severity) {
    switch (severity) {
      case ConsultationSeverity.low:
        return 'RISIKO RENDAH';
      case ConsultationSeverity.medium:
        return 'RISIKO SEDANG';
      case ConsultationSeverity.high:
        return 'RISIKO TINGGI';
    }
  }
}
