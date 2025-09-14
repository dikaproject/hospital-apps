// Update: lib/screens/consultation/consultation_result_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/chat_models.dart' as chat; // Use alias to avoid conflict
import '../../models/consultation_models.dart';
import 'schedule_consultation_screen.dart'; // Fix path - move to correct location

class ConsultationResultScreen extends StatefulWidget {
  final List<chat.ChatMessage> chatHistory; // Use alias
  final AIScreeningResult? aiResult;

  const ConsultationResultScreen({
    super.key,
    required this.chatHistory,
    this.aiResult,
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

  // Add medical research from AI result
  Map<String, dynamic>? _medicalResearch;

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

    // Extract medical research from AI result
    _medicalResearch = widget.aiResult?.medicalResearch;

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
        return 'Keluhan Ringan - Self Care';
      case ConsultationSeverity.medium:
        return 'Keluhan Sedang - Konsultasi Chat';
      case ConsultationSeverity.high:
        return 'Keluhan Serius - Prioritas Tinggi';
    }
  }

  List<String> _getRecommendationsFromAI(AIScreeningResult aiResult) {
    switch (aiResult.severity.toUpperCase()) {
      case 'LOW':
        return [
          'Istirahat yang cukup (7-8 jam per hari)',
          'Perbanyak minum air putih (8 gelas per hari)',
          'Konsumsi makanan bergizi seimbang',
          'Monitor kondisi selama 2-3 hari',
          'Tetap tersedia konsultasi chat jika khawatir'
        ];
      case 'HIGH':
        return [
          'Segera konsultasi chat dengan dokter umum',
          'Siapkan foto/dokumen medis jika ada',
          'Catat semua gejala secara detail',
          'Jika kondisi darurat, langsung ke IGD',
          'Chat akan direspons dengan prioritas tinggi'
        ];
      default:
        return [
          'Konsultasi chat dengan dokter umum dalam 24 jam',
          'Istirahat yang cukup sambil menunggu',
          'Monitor gejala dan catat perkembangannya',
          'Siapkan riwayat medis untuk konsultasi',
          'Respon dokter estimasi 2-4 jam'
        ];
    }
  }

  String _getFollowUpFromAI(AIScreeningResult aiResult) {
    switch (aiResult.severity.toUpperCase()) {
      case 'LOW':
        return 'Anda dapat mengikuti saran self-care di atas. Namun tetap tersedia konsultasi chat jika kondisi tidak membaik dalam 3-5 hari atau jika Anda merasa khawatir.';
      case 'HIGH':
        return 'Kondisi Anda memerlukan perhatian medis segera. Konsultasi chat akan diprioritaskan dan dokter akan merespons maksimal 1 jam. Jika darurat, segera ke IGD terdekat.';
      default:
        return 'Disarankan untuk konsultasi chat dengan dokter umum. Sistem akan mencarikan dokter yang tersedia dan memberikan estimasi waktu respons. Chat bersifat asinkron seperti email medis.';
    }
  }

  ConsultationResult _generateMockResult() {
    final random = Random();
    final severity = ConsultationSeverity.values[random.nextInt(3)];

    switch (severity) {
      case ConsultationSeverity.low:
        return ConsultationResult(
          severity: severity,
          title: 'Keluhan Ringan - Self Care',
          description:
              'Berdasarkan analisis AI, kondisi Anda termasuk kategori ringan dan dapat diatasi dengan perawatan mandiri.',
          recommendations: [
            'Istirahat yang cukup (7-8 jam per hari)',
            'Perbanyak minum air putih (8 gelas per hari)',
            'Konsumsi makanan bergizi seimbang',
            'Hindari stress berlebihan',
            'Tetap tersedia konsultasi chat jika khawatir'
          ],
          medication: [
            'Paracetamol 500mg (3x sehari setelah makan)',
            'Vitamin C 1000mg (1x sehari)',
          ],
          followUp:
              'Pantau kondisi selama 3-5 hari. Tetap tersedia konsultasi chat jika tidak membaik atau merasa khawatir.',
        );

      case ConsultationSeverity.medium:
        return ConsultationResult(
          severity: severity,
          title: 'Keluhan Sedang - Konsultasi Chat',
          description:
              'Gejala yang Anda alami sebaiknya dikonsultasikan dengan dokter umum melalui chat.',
          recommendations: [
            'Konsultasi chat dengan dokter umum',
            'Siapkan foto/dokumen medis jika ada',
            'Istirahat sambil menunggu respons dokter',
            'Monitor suhu tubuh secara berkala',
            'Catat perkembangan gejala'
          ],
          doctorSpecialty: 'Dokter Umum',
          followUp:
              'Chat dengan dokter umum akan direspons dalam 2-4 jam. Sistem akan mencarikan dokter yang tersedia.',
        );

      case ConsultationSeverity.high:
        return ConsultationResult(
          severity: severity,
          title: 'Keluhan Serius - Prioritas Tinggi',
          description:
              'Kondisi Anda memerlukan perhatian medis segera melalui konsultasi prioritas.',
          recommendations: [
            'Segera konsultasi chat dengan dokter umum',
            'Chat akan diprioritaskan (respons < 1 jam)',
            'Siapkan riwayat medis lengkap',
            'Jika darurat, langsung ke IGD',
            'Dampingi dengan keluarga'
          ],
          doctorSpecialty: 'Dokter Umum',
          followUp:
              'Chat prioritas akan direspons maksimal 1 jam. Jika kondisi darurat, segera ke IGD terdekat.',
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
            'Menentukan tingkat risiko dan rekomendasi',
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

                // Add medical research card if available
                if (_medicalResearch != null &&
                    _medicalResearch!['results'] != null &&
                    (_medicalResearch!['results'] as List).isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildMedicalResearchCard(),
                ],

                if (_result!.medication != null) ...[
                  const SizedBox(height: 20),
                  _buildMedicationCard(),
                ],
                const SizedBox(height: 20),
                _buildFollowUpCard(),
                const SizedBox(height: 20),
                _buildPricingInfo(),
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
    String severityBadge;

    switch (_result!.severity) {
      case ConsultationSeverity.low:
        severityColor = const Color(0xFF2ECC71);
        severityIcon = Icons.self_improvement;
        severityBadge = 'SELF CARE';
        break;
      case ConsultationSeverity.medium:
        severityColor = const Color(0xFFF39C12);
        severityIcon = Icons.chat_bubble_outline;
        severityBadge = 'CHAT DOKTER';
        break;
      case ConsultationSeverity.high:
        severityColor = const Color(0xFFE74C3C);
        severityIcon = Icons.priority_high;
        severityBadge = 'PRIORITAS TINGGI';
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        severityBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildPricingInfo() {
    return Container(
      width: double.infinity,
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
              Icon(Icons.payments, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Informasi Biaya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_result!.severity == ConsultationSeverity.low) ...[
            _buildPriceItem('Self Care (Gratis)', 'Rp 0', true),
            _buildPriceItem('Chat Dokter (Opsional)', 'Rp 15.000', false),
          ] else if (_result!.severity == ConsultationSeverity.medium) ...[
            _buildPriceItem('Chat Dokter Umum', 'Rp 15.000', true),
            _buildPriceItem('Estimasi Respons', '2-4 jam', false),
          ] else ...[
            _buildPriceItem('Chat Prioritas Dokter', 'Rp 25.000', true),
            _buildPriceItem('Respons Cepat', 'Max 1 jam', false),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '💡 Chat bersifat asinkron seperti email medis. Dokter akan merespons sesuai jadwal dan tingkat urgensi.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, String price, bool isIncluded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isIncluded ? Icons.check_circle : Icons.info_outline,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: isIncluded ? FontWeight.bold : FontWeight.normal,
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
                'Saran Obat Self Care',
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
                    'Untuk obat resep, konsultasi chat dengan dokter diperlukan',
                    style: TextStyle(
                      color: Color(0xFFE65100),
                      fontSize: 12,
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
                'Langkah Selanjutnya',
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
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_result!.severity == ConsultationSeverity.low) ...[
          // Untuk keluhan ringan - bisa pilih self care atau konsultasi
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.self_improvement, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Ikuti Self Care (Gratis)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _scheduleConsultation,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E7D89)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      color: Color(0xFF2E7D89), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Chat Dokter (Rp 15.000)',
                    style: TextStyle(
                      color: Color(0xFF2E7D89),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Untuk keluhan sedang/tinggi - langsung ke konsultasi chat
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _result!.isUrgent
                  ? const Color(0xFFFFEBEE)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _result!.isUrgent
                    ? const Color(0xFFE74C3C)
                    : const Color(0xFFFF9800),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _result!.isUrgent
                          ? Icons.priority_high
                          : Icons.info_outline,
                      color: _result!.isUrgent
                          ? const Color(0xFFE74C3C)
                          : const Color(0xFFFF9800),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _result!.isUrgent
                            ? 'Rekomendasi Prioritas'
                            : 'Rekomendasi Konsultasi',
                        style: TextStyle(
                          color: _result!.isUrgent
                              ? const Color(0xFFE74C3C)
                              : const Color(0xFFE65100),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _result!.isUrgent
                      ? 'Kondisi Anda memerlukan perhatian medis segera. Chat akan diprioritaskan dengan respons cepat.'
                      : 'Berdasarkan analisis AI, disarankan konsultasi chat dengan dokter umum untuk evaluasi lebih lanjut.',
                  style: TextStyle(
                    color: _result!.isUrgent
                        ? const Color(0xFFE74C3C)
                        : const Color(0xFFE65100),
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
              onPressed: _scheduleConsultation,
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
                    _result!.isUrgent
                        ? Icons.priority_high
                        : Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _result!.isUrgent
                        ? 'Chat Prioritas (Rp 25.000)'
                        : 'Chat Dokter (Rp 15.000)',
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
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
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

  void _scheduleConsultation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleConsultationScreen(
          aiResult: widget.aiResult,
        ),
      ),
    );
  }

  // Add medical research card widget
  Widget _buildMedicalResearchCard() {
    if (_medicalResearch == null || _medicalResearch!['results'] == null) {
      return const SizedBox();
    }

    final results = _medicalResearch!['results'] as List;
    if (results.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
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
              Icon(Icons.medical_information, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Referensi Medis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Show first result as preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  results[0]['title'] ?? 'Sumber Medis',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  results[0]['snippet'] ?? 'Informasi medis terpercaya',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Sumber: ${results[0]['source'] ?? 'Medical Source'}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Button to view all medical research
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showMedicalResearchDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF667EEA),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Lihat ${results.length} Sumber Medis',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 14),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            _medicalResearch!['disclaimer'] ??
                'Informasi dari sumber medis terpercaya sebagai referensi tambahan.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced medical research dialog
  void _showMedicalResearchDialog() {
    if (_medicalResearch == null || _medicalResearch!['results'] == null)
      return;

    final results = _medicalResearch!['results'] as List;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.medical_information,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Referensi Medis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[600], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ditemukan ${results.length} sumber medis terpercaya:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(results.length, (index) {
                  final result = results[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667EEA).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                result['source'] ?? 'Medical Source',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF667EEA),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '#${index + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result['title'] ?? 'Informasi Medis',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          result['snippet'] ?? 'Informasi medis terpercaya',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            height: 1.3,
                          ),
                        ),
                        if (result['link'] != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.link,
                                    size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    result['link'],
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber,
                          color: Colors.orange[600], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _medicalResearch!['disclaimer'] ??
                              'Informasi ini hanya sebagai referensi tambahan. Konsultasi dengan dokter tetap diperlukan untuk diagnosis dan pengobatan yang akurat.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[800],
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: TextStyle(
                color: const Color(0xFF667EEA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
