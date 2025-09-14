// Fix: lib/screens/consultation/ai_consultation_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/chat_models.dart' as chat; // Use alias
import '../../models/consultation_models.dart';
import '../../services/consultation_service.dart';
import 'consultation_result_screen.dart';

class AIConsultationScreen extends StatefulWidget {
  const AIConsultationScreen({super.key});

  @override
  State<AIConsultationScreen> createState() => _AIConsultationScreenState();
}

class _AIConsultationScreenState extends State<AIConsultationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<chat.ChatMessage> _messages = []; // Use alias
  List<String> _symptoms = [];
  bool _isLoading = false;
  bool _isAnalyzing = false;
  AIScreeningResult? _aiResult;

  String? _currentConsultationId;
  int _questionCount = 0;
  bool _isCollectingInfo = true;
  Map<String, dynamic>? _finalDiagnosis;

  final List<String> _quickSymptoms = [
    'Demam',
    'Batuk',
    'Pilek',
    'Sakit kepala',
    'Mual',
    'Diare',
    'Nyeri dada',
    'Sesak napas',
    'Pusing',
    'Sakit perut',
    'Nyeri otot',
    'Sakit tenggorokan',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        chat.ChatMessage(
          text:
              'Halo! Saya AI Assistant HospitalLink. Saya akan mengajukan beberapa pertanyaan untuk memahami kondisi kesehatan Anda dengan lebih baik. Mari kita mulai - ceritakan gejala utama yang Anda rasakan.',
          isUser: false,
        ),
      );
    });
    _scrollToBottom();
  }

  // Add missing _scrollToBottom method
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Add missing _viewResults method
  void _viewResults() {
    if (_finalDiagnosis != null && _currentConsultationId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultationResultScreen(
            chatHistory: _messages,
            aiResult: AIScreeningResult(
              consultationId: _currentConsultationId!,
              severity: _finalDiagnosis!['severity'],
              recommendation: 'DOCTOR_CONSULTATION',
              message: _finalDiagnosis!['explanation'] ??
                  'Hasil analisis medis telah selesai.',
              needsDoctorConsultation: _finalDiagnosis!['needsDoctor'] ?? true,
              estimatedFee: 25000,
              confidence: _finalDiagnosis!['confidence'] ?? 0.7,
              type: 'FINAL_DIAGNOSIS',
              primaryDiagnosis: _finalDiagnosis!['primaryDiagnosis'],
              possibleConditions: _finalDiagnosis!['possibleConditions'],
              urgencyLevel: _finalDiagnosis!['urgencyLevel'],
              recommendedActions: _finalDiagnosis!['recommendedActions'],
              medicalResearch: _finalDiagnosis!['medicalResearch'],
            ),
          ),
        ),
      );
    }
  }

  // Add missing _buildUserAvatar method
  Widget _buildUserAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF34495E), Color(0xFF2C3E50)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34495E).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 20),
    );
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isLoading) return;

    print('📤 Sending message: $messageText');

    setState(() {
      _messages.add(
        chat.ChatMessage(
          text: messageText,
          isUser: true,
        ),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      AIScreeningResult result;

      if (_currentConsultationId == null) {
        // First message - start AI screening
        _extractSymptomsFromMessage(messageText);

        print('🔬 Starting AI screening with symptoms: $_symptoms');

        result = await ConsultationService.performAIScreening(
          symptoms: _symptoms.isNotEmpty ? _symptoms : [messageText],
          chatHistory: _convertMessagesToHistory(),
          questionCount: _questionCount,
        );

        _currentConsultationId = result.consultationId;
        print('🆔 Consultation ID: $_currentConsultationId');
      } else {
        // Continue existing consultation
        print('🔄 Continuing consultation: $_currentConsultationId');

        result = await ConsultationService.continueAIConsultation(
          consultationId: _currentConsultationId!,
          userResponse: messageText,
          chatHistory: _convertMessagesToHistory(),
        );
      }

      await _handleAIResponse(result);
    } catch (e) {
      print('❌ Error sending message: $e');
      setState(() {
        _messages.add(
          chat.ChatMessage(
            text:
                'Maaf, terjadi kesalahan saat memproses pesan Anda. Silakan coba lagi.',
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  // Fix: lib/screens/consultation/ai_consultation_screen.dart
  // Update _handleAIResponse method untuk auto redirect

  Future<void> _handleAIResponse(AIScreeningResult result) async {
    print('🤖 Handling AI response type: ${result.type}');
    print('📝 Response message: ${result.message}');

    setState(() {
      _questionCount++;
    });

    if (result.type == 'FOLLOW_UP_QUESTION') {
      // AI is asking a follow-up question
      final questionText =
          result.question ?? result.message ?? 'Pertanyaan tidak tersedia';

      print('❓ Adding follow-up question: $questionText');

      setState(() {
        _messages.add(
          chat.ChatMessage(
            text: questionText,
            isUser: false,
            metadata: {
              'isQuestion': true,
              'questionNumber': result.questionNumber ?? _questionCount,
              'totalQuestions': result.totalQuestions ?? 5,
              'progress': result.progress ??
                  {
                    'current': _questionCount,
                    'total': 5,
                    'percentage': (_questionCount / 5 * 100).round()
                  },
            },
          ),
        );
      });

      _scrollToBottom();
    } else if (result.type == 'FINAL_DIAGNOSIS') {
      // AI has completed the analysis - AUTO REDIRECT to result
      print('✅ Final diagnosis completed - redirecting to result...');

      setState(() {
        _isCollectingInfo = false;
        _finalDiagnosis = {
          'severity': result.severity,
          'confidence': result.confidence,
          'primaryDiagnosis': result.primaryDiagnosis,
          'possibleConditions': result.possibleConditions,
          'explanation': result.message,
          'needsDoctor': result.needsDoctorConsultation,
          'urgencyLevel': result.urgencyLevel,
          'recommendedActions': result.recommendedActions,
          'medicalResearch': result.medicalResearch,
        };
      });

      // Add final message before redirect
      setState(() {
        _messages.add(
          chat.ChatMessage(
            text:
                '🎉 **Analisis AI Selesai!**\n\nSemua informasi telah terkumpul dan dianalisis. Anda akan diarahkan ke halaman hasil untuk melihat diagnosis dan rekomendasi lengkap.',
            isUser: false,
            metadata: {
              'isFinalMessage': true,
            },
          ),
        );
      });

      _scrollToBottom();

      // Wait for message to appear, then redirect
      await Future.delayed(const Duration(milliseconds: 1500));

      // Navigate to result screen immediately
      if (mounted) {
        Navigator.pushReplacement(
          // Use pushReplacement instead of push
          context,
          MaterialPageRoute(
            builder: (context) => ConsultationResultScreen(
              chatHistory: _messages,
              aiResult: AIScreeningResult(
                consultationId: _currentConsultationId!,
                severity: result.severity,
                recommendation: result.recommendation ?? 'DOCTOR_CONSULTATION',
                message: result.message,
                needsDoctorConsultation: result.needsDoctorConsultation,
                estimatedFee: result.needsDoctorConsultation ? 25000 : 0,
                confidence: result.confidence,
                type: result.type,
                primaryDiagnosis: result.primaryDiagnosis,
                possibleConditions: result.possibleConditions,
                urgencyLevel: result.urgencyLevel,
                recommendedActions: result.recommendedActions,
                medicalResearch: result.medicalResearch,
                isComplete: true,
              ),
            ),
          ),
        );
      }
    }
  }

  String _buildFinalDiagnosisMessage(AIScreeningResult result) {
    String message = '📋 **Hasil Analisis Lengkap**\n\n';

    message += '🏥 **Kemungkinan Kondisi:**\n';
    message +=
        '${result.primaryDiagnosis ?? "Memerlukan evaluasi lebih lanjut"}\n\n';

    if (result.possibleConditions != null &&
        result.possibleConditions!.isNotEmpty) {
      message += '🔍 **Differential Diagnosis:**\n';
      for (String condition in result.possibleConditions!) {
        message += '• $condition\n';
      }
      message += '\n';
    }

    message +=
        '⚠️ **Tingkat Urgensi:** ${_getUrgencyText(result.urgencyLevel)}\n\n';

    message +=
        '💡 **Penjelasan:**\n${result.message}\n\n'; // Use message instead of explanation

    if (result.recommendedActions != null &&
        result.recommendedActions!.isNotEmpty) {
      message += '📝 **Rekomendasi Tindakan:**\n';
      for (String action in result.recommendedActions!) {
        message += '• $action\n';
      }
      message += '\n';
    }

    if (result.needsDoctorConsultation) {
      message +=
          '👨‍⚕️ **Rekomendasi:** Konsultasi dengan dokter diperlukan untuk konfirmasi diagnosis dan penanganan yang tepat.';
    } else {
      message +=
          '💚 **Rekomendasi:** Kondisi dapat diatasi dengan perawatan mandiri. Namun tetap pantau perkembangan gejala.';
    }

    return message;
  }

  String _getUrgencyText(String? urgencyLevel) {
    switch (urgencyLevel) {
      case 'DARURAT':
        return 'DARURAT - Segera ke IGD';
      case 'SEGERA':
        return 'SEGERA - Dalam beberapa jam';
      case 'DALAM_24_JAM':
        return 'MENDESAK - Dalam 24 jam';
      case 'TIDAK_MENDESAK':
        return 'TIDAK MENDESAK - Dapat dijadwalkan';
      default:
        return 'KONSULTASI DIANJURKAN';
    }
  }

  void _showMedicalResearchDialog(Map<String, dynamic> medicalResearch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📚 Informasi Medis Tambahan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sumber informasi medis terpercaya:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                (medicalResearch['results'] as List).length,
                (index) {
                  final result = medicalResearch['results'][index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result['snippet'],
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sumber: ${result['source']}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                medicalResearch['disclaimer'] ??
                    'Informasi tambahan dari sumber medis terpercaya.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _convertMessagesToHistory() {
    return _messages
        .map((msg) => {
              'text': msg.text,
              'isUser': msg.isUser,
              'timestamp': DateTime.now().toIso8601String(),
            })
        .toList();
  }

  void _extractSymptomsFromMessage(String message) {
    List<String> matchedSymptoms = [];
    for (String symptom in _quickSymptoms) {
      if (message.toLowerCase().contains(symptom.toLowerCase())) {
        matchedSymptoms.add(symptom);
      }
    }
    setState(() {
      _symptoms = matchedSymptoms.isNotEmpty ? matchedSymptoms : [message];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konsultasi AI'),
        centerTitle: true,
        // Remove the view results action since we auto-redirect
      ),
      body: Column(
        children: [
          // Progress indicator for questions
          if (_isCollectingInfo && _questionCount > 0)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Icon(Icons.quiz, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mengumpulkan informasi medis...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _questionCount / 5.0,
                          backgroundColor: Colors.blue[100],
                          valueColor: AlwaysStoppedAnimation(Colors.blue[600]),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pertanyaan $_questionCount dari 5',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Loading indicator
          if (_isLoading) _buildLoadingIndicator(),

          // Remove diagnosis summary - we auto-redirect now

          // Input area - disable when analysis is complete
          if (_isCollectingInfo) _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(chat.ChatMessage message) {
    final isUser = message.isUser;
    // Safe access to metadata with null check
    final metadata = message.metadata ?? {};
    final isQuestion = metadata['isQuestion'] == true;
    final isFinalDiagnosis = metadata['isFinalDiagnosis'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAIAvatar(isQuestion: isQuestion, isFinal: isFinalDiagnosis),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF2E7D89)
                    : isFinalDiagnosis
                        ? Colors.green[50]
                        : isQuestion
                            ? Colors.blue[50]
                            : Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: !isUser && (isQuestion || isFinalDiagnosis)
                    ? Border.all(
                        color:
                            isQuestion ? Colors.blue[200]! : Colors.green[200]!,
                        width: 1,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isQuestion && metadata['progress'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.help_outline,
                              size: 16, color: Colors.blue[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Pertanyaan ${metadata['progress']['current']}/${metadata['progress']['total']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isFinalDiagnosis)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.medical_services,
                              size: 16, color: Colors.green[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Hasil Analisis Medis',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF2C3E50),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAIAvatar({bool isQuestion = false, bool isFinal = false}) {
    Color color1, color2;
    IconData icon;

    if (isFinal) {
      color1 = const Color(0xFF27AE60);
      color2 = const Color(0xFF2ECC71);
      icon = Icons.medical_services;
    } else if (isQuestion) {
      color1 = const Color(0xFF3498DB);
      color2 = const Color(0xFF5DADE2);
      icon = Icons.help_outline;
    } else {
      color1 = const Color(0xFF2E7D89);
      color2 = const Color(0xFF4ECDC4);
      icon = Icons.smart_toy;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _questionCount < 5
                    ? 'AI sedang menganalisis jawaban Anda...'
                    : 'Membuat diagnosis lengkap...',
                style: TextStyle(
                  color: const Color(0xFF2C3E50),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_questionCount < 5)
                Text(
                  'Pertanyaan selanjutnya akan muncul sebentar lagi',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
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
                  hintText: 'Ketik gejala Anda...',
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
                onSubmitted: (_) => _sendMessage(),
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
}
