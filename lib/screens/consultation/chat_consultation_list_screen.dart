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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D89).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: Color(0xFF2E7D89),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Chat Dokter Aktif',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Chat hanya tersedia untuk konsultasi dokter yang sedang aktif.\n\nKonsultasi AI tidak memiliki fitur chat.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createNewConsultation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D89),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Mulai Chat Dokter Baru',
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
          ],
        ),
      ),
    );
  }

  // Method to create new consultation
  void _createNewConsultation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const DirectConsultationScreen(), // ✅ No required parameters
      ),
    ).then((_) {
      // Refresh the list when returning from consultation creation
      _loadConsultations();
    });
  }

  // Add debug info in _buildChatItem method:
  Widget _buildChatItem(ChatConsultation consultation) {
    // ✅ SAFETY CHECK: Ensure only active doctor consultations are displayed
    print('🔍 Rendering consultation: ${consultation.id}');
    print('   - Doctor: ${consultation.doctorName}');
    print('   - Status: ${consultation.status}');
    print('   - Messages: ${consultation.messages.length}');
    print('   - Created: ${consultation.scheduledTime}');

    // ✅ Only allow chat for in-progress consultations
    final bool canChat = consultation.status == ConsultationStatus.inProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canChat ? const Color(0xFF2E7D89) : Colors.grey[300]!,
          width: canChat ? 2 : 1,
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
                    // ✅ Show consultation type for clarity
                    Text(
                      'Chat Dokter Aktif',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2E7D89),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(consultation.status),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ Chat status information
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: canChat
                  ? const Color(0xFF2E7D89).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  canChat ? Icons.chat_bubble_outline : Icons.info_outline,
                  color: canChat ? const Color(0xFF2E7D89) : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    canChat
                        ? consultation.messages.isNotEmpty
                            ? 'Pesan terakhir: ${consultation.messages.last.text.length > 30 ? consultation.messages.last.text.substring(0, 30) + "..." : consultation.messages.last.text}'
                            : 'Chat siap digunakan, kirim pesan pertama'
                        : 'Chat tidak tersedia',
                    style: TextStyle(
                      fontSize: 12,
                      color: canChat ? const Color(0xFF2E7D89) : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                canChat ? 'Chat aktif - respons real-time' : 'Chat tidak aktif',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: canChat ? () => _navigateToChat(consultation) : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: canChat ? const Color(0xFF2E7D89) : Colors.grey[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    canChat ? 'Buka Chat' : 'Tidak Aktif',
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
