import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/consultation_models.dart';
import '../../services/chat_consultation_service.dart';

class ChatConsultationScreen extends StatefulWidget {
  final ChatConsultation consultation;

  const ChatConsultationScreen({
    super.key,
    required this.consultation,
  });

  @override
  State<ChatConsultationScreen> createState() => _ChatConsultationScreenState();
}

class _ChatConsultationScreenState extends State<ChatConsultationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatConsultationMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadChatMessages();
    _startStatusUpdates();
    _sendInitialMessage();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _loadChatMessages() async {
    try {
      final messages =
          await ChatConsultationService.getChatMessages(widget.consultation.id);

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      _animationController.forward();

      // Add initial message if no messages exist
      if (_messages.isEmpty) {
        _sendInitialMessage();
      }

      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);

      // Don't show error for authorization issues - just show empty state
      if (e.toString().contains('Not authorized')) {
        print('🔒 Chat access restricted, showing fallback');
        _sendInitialMessage();
      } else {
        _showErrorSnackBar('Gagal memuat chat: $e');
      }
    }
  }

  void _sendInitialMessage() {
    if (_messages.isEmpty) {
      final initialMessage = ChatConsultationMessage(
        id: 'system_initial',
        text:
            'Konsultasi chat telah dimulai. Silakan ceritakan keluhan Anda dengan detail. Dokter akan merespons sesuai jadwal dan tingkat urgensi.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages = [initialMessage];
      });
    }
  }

  void _startStatusUpdates() {
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkForNewMessages();
    });
  }

  void _checkForNewMessages() async {
    try {
      final messages =
          await ChatConsultationService.getChatMessages(widget.consultation.id);
      if (messages.length > _messages.length) {
        setState(() {
          _messages = messages;
        });
        _scrollToBottom();

        final lastMessage = messages.last;
        if (!lastMessage.isUser) {
          _showNewMessageNotification(lastMessage);
        }
      }
    } catch (e) {
      print('Error checking new messages: $e');
    }
  }

  void _showNewMessageNotification(ChatConsultationMessage message) {
    _showSnackBar('💬 Pesan baru dari dokter');
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingView() : _buildChatView(),
      bottomNavigationBar: _buildInputArea(),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.consultation.doctorName,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.consultation.specialty,
            style: const TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D89).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getStatusText(),
            style: const TextStyle(
              color: Color(0xFF2E7D89),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
            'Memuat chat...',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildConsultationInfo(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Estimasi respons: ${_getEstimatedResponseTime()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Antrian: ${widget.consultation.queuePosition}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 12),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Chat bersifat asinkron. Dokter akan merespons sesuai jadwal.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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

  Widget _buildMessageBubble(ChatConsultationMessage message) {
    bool isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(false),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF2C3E50),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      color: isUser ? Colors.white70 : const Color(0xFF7F8C8D),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildAvatar(true),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF3498DB) : const Color(0xFF2E7D89),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.local_hospital,
        color: Colors.white,
        size: 16,
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
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Ketik pesan Anda...',
                    hintStyle: TextStyle(color: Color(0xFF7F8C8D)),
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
              onTap: _isSending ? null : _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _isSending ? Colors.grey : const Color(0xFF2E7D89),
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final newMessage = await ChatConsultationService.sendChatMessage(
        consultationId: widget.consultation.id,
        message: messageText,
      );

      setState(() {
        _messages.add(newMessage);
        _isSending = false;
      });

      _scrollToBottom();
      _showSuccessSnackBar('Pesan terkirim');
    } catch (e) {
      setState(() => _isSending = false);
      _showErrorSnackBar('Gagal mengirim pesan: $e');
    }
  }

  String _getStatusText() {
    switch (widget.consultation.status) {
      case ConsultationStatus.waiting:
        return 'Menunggu';
      case ConsultationStatus.inProgress:
        return 'Berlangsung';
      case ConsultationStatus.completed:
        return 'Selesai';
      case ConsultationStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  String _getEstimatedResponseTime() {
    final estimatedMinutes = widget.consultation.estimatedWaitMinutes;
    if (estimatedMinutes < 60) {
      return '$estimatedMinutes menit';
    } else {
      final hours = estimatedMinutes ~/ 60;
      final minutes = estimatedMinutes % 60;
      return minutes > 0 ? '${hours}j ${minutes}m' : '${hours}j';
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E7D89),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
