import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'consultation_result_screen.dart';
import '../../models/chat_models.dart'; // Import chat models
import '../../services/consultation_service.dart';
import '../../models/consultation_models.dart';

class AIConsultationScreen extends StatefulWidget {
  const AIConsultationScreen({super.key});

  @override
  State<AIConsultationScreen> createState() => _AIConsultationScreenState();
}

class _AIConsultationScreenState extends State<AIConsultationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isConsultationComplete = false;
  int _currentQuestionIndex = 0;

  final List<String> _initialQuestions = [
    "Halo! Saya AI Assistant HospitalLink. Untuk membantu konsultasi awal, bisa ceritakan keluhan utama yang Anda rasakan saat ini?",
    "Sudah berapa lama Anda merasakan keluhan ini?",
    "Apakah ada gejala lain yang menyertai?",
    "Pada skala 1-10, seberapa mengganggu keluhan ini dalam aktivitas harian Anda?",
    "Apakah Anda pernah mengalami keluhan serupa sebelumnya?"
  ];

  AIScreeningResult? _aiResult;
  bool _isProcessingAI = false;
  List<String> _extractedSymptoms = [];

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

    // Start with first AI message
    _addAIMessage(_initialQuestions[0]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konsultasi AI',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _isConsultationComplete
                  ? 'Konsultasi selesai'
                  : 'Pertanyaan ${_currentQuestionIndex + 1} dari ${_initialQuestions.length}',
              style: const TextStyle(
                color: Color(0xFF7F8C8D),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          _buildAppBarActions(),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: _buildChatArea(),
            ),
            if (!_isConsultationComplete) _buildInputArea(),
            if (_isConsultationComplete) _buildCompletionActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    double progress = (_currentQuestionIndex + 1) / _initialQuestions.length;
    if (_isConsultationComplete) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Progress Konsultasi',
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF2E7D89),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D89)),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isTyping) {
            return _buildTypingIndicator();
          }
          return _buildMessageBubble(_messages[index]);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    bool isUser = message.isUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatarAI(),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF2E7D89) : Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF2C3E50),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildAvatarUser(),
        ],
      ),
    );
  }

  Widget _buildAvatarAI() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D89), Color(0xFF4ECDC4)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.smart_toy,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildAvatarUser() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF3498DB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildAvatarAI(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 200)),
      tween: Tween(begin: 0.4, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D89),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.grey[300]!,
                ),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Ketik jawaban Anda...',
                  hintStyle: TextStyle(
                    color: Color(0xFF7F8C8D),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D89), Color(0xFF4ECDC4)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionActions() {
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Konsultasi AI selesai!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _viewResults,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D89),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lihat Hasil Konsultasi',
                style: TextStyle(
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

  void _addAIMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: false));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    // Extract symptoms from user messages
    _extractedSymptoms.add(message.toLowerCase());

    // Simulate AI typing
    setState(() {
      _isTyping = true;
    });

    try {
      if (_currentQuestionIndex < _initialQuestions.length - 1) {
        // Continue with next question
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _isTyping = false;
          _currentQuestionIndex++;
        });

        _addAIMessage(_initialQuestions[_currentQuestionIndex]);
      } else {
        // Final question answered - perform AI screening
        await _performRealAIScreening();
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
      });

      _addAIMessage(
          "Maaf, terjadi kesalahan saat memproses. Silakan coba lagi atau hubungi dokter langsung.");
      print('❌ AI consultation error: $e');
    }
  }

  Future<void> _performRealAIScreening() async {
    try {
      setState(() {
        _isProcessingAI = true;
        _isTyping = false;
      });

      _addAIMessage(
          "Terima kasih atas informasi yang Anda berikan. Saya sedang menganalisis gejala Anda menggunakan AI...");

      // Convert chat history to proper format
      List<Map<String, dynamic>> chatHistory = _messages
          .map((msg) => {
                'text': msg.text,
                'isUser': msg.isUser,
              })
          .toList();

      try {
        // Call real AI service
        _aiResult = await ConsultationService.performAIScreening(
          symptoms: _extractedSymptoms,
          chatHistory: chatHistory,
        );

        // Show AI analysis result
        await Future.delayed(const Duration(seconds: 2));

        String resultMessage = _buildAIResultMessage(_aiResult!);
        _addAIMessage(resultMessage);

        print('✅ AI Analysis completed successfully');
      } catch (e) {
        print('❌ AI API Error: $e');

        // Show fallback message
        _addAIMessage(
            "Sistem AI sedang mengalami gangguan. Saya akan memberikan analisis berdasarkan pengalaman medis terdahulu.");

        // Create fallback result
        _aiResult = _createFallbackResult();

        await Future.delayed(const Duration(seconds: 1));
        String resultMessage = _buildAIResultMessage(_aiResult!);
        _addAIMessage(resultMessage);
      }

      // Wait a bit then complete consultation
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isConsultationComplete = true;
        _isProcessingAI = false;
      });
    } catch (e) {
      print('❌ General error in AI screening: $e');

      setState(() {
        _isProcessingAI = false;
        _isTyping = false;
      });

      _addAIMessage(
          "Maaf, terjadi kesalahan sistem. Silakan coba lagi atau hubungi dokter langsung untuk konsultasi.");

      // Still allow to complete consultation
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isConsultationComplete = true;
      });
    }
  }

  AIScreeningResult _createFallbackResult() {
    // Simple fallback logic based on symptoms
    String severity = 'MEDIUM';
    bool needsDoctor = true;

    String symptomsText = _extractedSymptoms.join(' ').toLowerCase();

    if (symptomsText.contains('ringan') ||
        symptomsText.contains('tidak sakit')) {
      severity = 'LOW';
      needsDoctor = false;
    } else if (symptomsText.contains('parah') ||
        symptomsText.contains('sangat sakit')) {
      severity = 'HIGH';
    }

    return AIScreeningResult(
      consultationId: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      severity: severity,
      recommendation: needsDoctor ? 'DOCTOR_CONSULTATION' : 'SELF_CARE',
      message: needsDoctor
          ? 'Berdasarkan gejala yang Anda sampaikan, disarankan untuk berkonsultasi dengan dokter untuk evaluasi lebih lanjut.'
          : 'Gejala yang Anda alami tergolong ringan. Istirahat yang cukup dan pola hidup sehat dapat membantu pemulihan.',
      needsDoctorConsultation: needsDoctor,
      estimatedFee: needsDoctor ? 25000 : 0,
      confidence: 0.7,
      symptomsAnalysis: {
        'primary_symptoms': _extractedSymptoms,
        'fallback_mode': true
      },
    );
  }

  String _buildAIResultMessage(AIScreeningResult result) {
    String severityText = '';
    String iconText = '';

    switch (result.severity) {
      case 'LOW':
        severityText = 'RINGAN';
        iconText = '✅';
        break;
      case 'MEDIUM':
        severityText = 'SEDANG';
        iconText = '⚠️';
        break;
      case 'HIGH':
        severityText = 'TINGGI';
        iconText = '🚨';
        break;
      default:
        severityText = result.severity;
        iconText = '📋';
    }

    String message = "$iconText HASIL ANALISIS AI:\n\n";
    message += "Tingkat Keparahan: $severityText\n";
    message += "Tingkat Kepercayaan: ${(result.confidence * 100).toInt()}%\n\n";
    message += result.message + "\n\n";

    if (result.needsDoctorConsultation) {
      message +=
          "💰 Estimasi biaya konsultasi: Rp ${result.estimatedFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}\n\n";
      message +=
          "Silakan klik 'Lihat Hasil Konsultasi' untuk melihat detail lengkap dan melanjutkan ke konsultasi dokter.";
    } else {
      message +=
          "Anda dapat mengikuti saran yang diberikan. Namun jika kondisi memburuk, segera konsultasi dengan dokter.";
    }

    return message;
  }

  void _viewResults() {
    if (_aiResult != null) {
      // Pass real AI result to result screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultationResultScreen(
            chatHistory: _messages,
            aiResult: _aiResult!, // Pass real AI result
          ),
        ),
      );
    } else {
      // Fallback to original mock behavior
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultationResultScreen(
            chatHistory: _messages,
          ),
        ),
      );
    }
  }

  Widget _buildAppBarActions() {
    return Row(
      children: [
        IconButton(
          onPressed: _testAIConnection,
          icon: Icon(
            Icons.wifi,
            color: const Color(0xFF2E7D89),
            size: 20,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D89).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.smart_toy,
                size: 16,
                color: const Color(0xFF2E7D89),
              ),
              const SizedBox(width: 4),
              const Text(
                'AI Doctor',
                style: TextStyle(
                  color: Color(0xFF2E7D89),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _testAIConnection() async {
    try {
      _showSnackBar('Testing AI connection...', isLoading: true);

      bool isConnected = await ConsultationService.testAIConnection();

      if (isConnected) {
        _showSnackBar('✅ AI connection successful!');
      } else {
        _showSnackBar('❌ AI connection failed', isError: true);
      }
    } catch (e) {
      _showSnackBar('❌ AI connection error: ${e.toString()}', isError: true);
    }
  }

  void _showSnackBar(String message,
      {bool isError = false, bool isLoading = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(
                isError ? Icons.error : Icons.check_circle,
                color: Colors.white,
                size: 16,
              ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF2E7D89),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
