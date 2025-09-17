import 'package:flutter/material.dart';
import '../../models/consultation_models.dart';
import '../../services/consultation_service.dart';
import '../../services/chat_consultation_service.dart';
import 'chat_consultation_screen.dart';
import 'direct_consultation_screen.dart'; // Add this import

class ChatConsultationListScreen extends StatefulWidget {
  const ChatConsultationListScreen({super.key});

  @override
  State<ChatConsultationListScreen> createState() =>
      _ChatConsultationListScreenState();
}

class _ChatConsultationListScreenState
    extends State<ChatConsultationListScreen> {
  List<ChatConsultation> _consultations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsultations();
  }

  Future<void> _loadConsultations() async {
    try {
      setState(() => _isLoading = true);
      final consultations =
          await ChatConsultationService.getChatConsultations();
      setState(() {
        _consultations = consultations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Gagal memuat riwayat chat: $e');
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
          'Chat Konsultasi',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2E7D89)),
            onPressed: _loadConsultations,
          ),
        ],
      ),
      body: _buildBody(),
      // Add FloatingActionButton for new consultation
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewConsultation,
        backgroundColor: const Color(0xFF2E7D89),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Konsultasi Baru',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D89)),
        ),
      );
    }

    if (_consultations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadConsultations,
      color: const Color(0xFF2E7D89),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _consultations.length,
        itemBuilder: (context, index) {
          return _buildChatItem(_consultations[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D89).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Color(0xFF2E7D89),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Chat Konsultasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai konsultasi dengan dokter untuk memulai chat',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewConsultation,
            icon: const Icon(Icons.medical_services, color: Colors.white),
            label: const Text(
              'Mulai Konsultasi Baru',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D89),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Method to create new consultation
  void _createNewConsultation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DirectConsultationScreen(),
      ),
    ).then((_) {
      // Refresh the list when returning from consultation creation
      _loadConsultations();
    });
  }

  Widget _buildChatItem(ChatConsultation consultation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: consultation.status == ConsultationStatus.inProgress
              ? const Color(0xFF2E7D89)
              : consultation.status == ConsultationStatus.completed
                  ? Colors.green
                  : Colors.grey[300]!,
          width: consultation.status == ConsultationStatus.inProgress ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D89).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF2E7D89),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation.doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      consultation.specialty,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(consultation.status),
            ],
          ),
          const SizedBox(height: 12),

          // Show appropriate message based on status
          if (consultation.status == ConsultationStatus.completed) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Konsultasi telah selesai',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (consultation.messages.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                consultation.messages.last.text,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D89).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      color: Color(0xFF2E7D89), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Chat sudah siap, mulai kirim pesan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D89),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                consultation.status == ConsultationStatus.completed
                    ? 'Konsultasi selesai'
                    : 'Estimasi respons: ${_getEstimatedResponseTime(consultation.estimatedWaitMinutes)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _navigateToChat(consultation),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: consultation.status == ConsultationStatus.inProgress
                        ? const Color(0xFF2E7D89)
                        : consultation.status == ConsultationStatus.completed
                            ? Colors.green
                            : Colors.grey[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    consultation.status == ConsultationStatus.inProgress
                        ? 'Lanjut Chat'
                        : consultation.status == ConsultationStatus.completed
                            ? 'Lihat Riwayat'
                            : 'Lihat Chat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ConsultationStatus status) {
    Color backgroundColor;
    Color textColor;
    String statusText;
    IconData iconData;

    switch (status) {
      case ConsultationStatus.waiting:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        statusText = 'Menunggu';
        iconData = Icons.schedule;
        break;
      case ConsultationStatus.inProgress:
        backgroundColor = const Color(0xFF2E7D89).withOpacity(0.1);
        textColor = const Color(0xFF2E7D89);
        statusText = 'Berlangsung';
        iconData = Icons.chat_bubble;
        break;
      case ConsultationStatus.completed:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        statusText = 'Selesai';
        iconData = Icons.check_circle;
        break;
      case ConsultationStatus.cancelled:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        statusText = 'Dibatalkan';
        iconData = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(ChatConsultation consultation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConsultationScreen(
          consultation: consultation,
        ),
      ),
    );
  }

  String _getEstimatedResponseTime(int minutes) {
    if (minutes < 60) {
      return '$minutes menit';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0
          ? '${hours}j ${remainingMinutes}m'
          : '${hours}j';
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
