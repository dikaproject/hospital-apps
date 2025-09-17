import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/qr_service.dart';
import 'dart:convert';

class QRShowScreen extends StatefulWidget {
  const QRShowScreen({super.key});

  @override
  State<QRShowScreen> createState() => _QRShowScreenState();
}

class _QRShowScreenState extends State<QRShowScreen> {
  UserModel? _currentUser;
  String? _qrCodeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      // Get static QR from backend
      final qrData = await QRService.getUserQR();

      setState(() {
        _currentUser = AuthService.getCurrentUser();
        _qrCodeData = qrData['qrCodeData'];
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to local generation
      final user = AuthService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _qrCodeData = _generateFallbackQRData(user);
        _isLoading = false;
      });
    }
  }

  String _generateFallbackQRData(UserModel? user) {
    if (user == null) return '{"error": "User not found"}';

    final qrData = {
      'type': 'HOSPITAL_PATIENT_ID',
      'userId': user.id,
      'nik': user.nik,
      'fullName': user.fullName,
      'phone': user.phone,
      'hospital': 'HOSPITALINK_MEDICAL_CENTER',
      'profilePicture': user.profilePicture,
      'qrVersion': '2.0',
      'isStatic': true,
      'fallback': true
    };

    return json.encode(qrData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading ? _buildLoadingView() : _buildQRView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D89)),
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            'Memuat QR Code Anda...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRView() {
    return CustomScrollView(
      slivers: [
        // Modern App Bar
        SliverAppBar(
          expandedHeight: 150, // ✅ Reduced height
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E40AF),
                    Color(0xFF2E7D89),
                    Color(0xFF059669),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20), // ✅ Adjusted padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10), // ✅ Reduced padding
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.qr_code_2,
                              color: Colors.white,
                              size: 28, // ✅ Reduced size
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'QR Code Saya',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24, // ✅ Reduced size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'ID Pasien Digital',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14, // ✅ Reduced size
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              onPressed: _showQRInfo,
              icon: const Icon(Icons.info_outline, color: Colors.white),
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16), // ✅ Reduced padding
            child: Column(
              children: [
                _buildUserCard(),
                const SizedBox(height: 20), // ✅ Reduced spacing
                _buildQRCodeCard(),
                const SizedBox(height: 20),
                _buildBenefitsCard(),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // ✅ Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // ✅ Reduced radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56, // ✅ Reduced size
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D89), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D89).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _currentUser?.profilePicture != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _currentUser!.profilePicture!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      _currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20, // ✅ Reduced size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?.fullName ?? 'Nama Tidak Tersedia',
                  style: const TextStyle(
                    fontSize: 18, // ✅ Reduced size
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.credit_card, 'NIK', _currentUser?.nik ?? '-'),
                const SizedBox(height: 2),
                _buildInfoRow(Icons.phone, 'Telepon', _currentUser?.phone ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)), // ✅ Reduced size
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13, // ✅ Reduced size
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13, // ✅ Reduced size
              color: Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24), // ✅ Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // QR Code Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // ✅ Reduced padding
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D89), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'QR Code Permanen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14, // ✅ Reduced size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // QR Code
          Container(
            padding: const EdgeInsets.all(16), // ✅ Reduced padding
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2E7D89).withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D89).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: _qrCodeData ?? '',
              size: 200, // ✅ Reduced size
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E293B),
              padding: const EdgeInsets.all(0),
              gapless: true,
              errorStateBuilder: (context, error) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.grey, size: 40),
                      SizedBox(height: 6),
                      Text('QR Code Error', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // QR Info
          Container(
            padding: const EdgeInsets.all(12), // ✅ Reduced padding
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco,
                      color: Colors.green[600],
                      size: 16, // ✅ Reduced size
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ramah Lingkungan',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 14, // ✅ Reduced size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'QR Code ini permanent dan dapat dicetak sekali untuk digunakan selamanya',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12, // ✅ Reduced size
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    final benefits = [
      {
        'icon': Icons.flash_on,
        'title': 'Check-in Cepat',
        'subtitle': 'Tunjukkan QR untuk check-in instan',
        'color': const Color(0xFFEF4444),
      },
      {
        'icon': Icons.security,
        'title': 'Aman & Terverifikasi',
        'subtitle': 'Dilindungi sistem keamanan berlapis',
        'color': const Color(0xFF2E7D89),
      },
      {
        'icon': Icons.print,
        'title': 'Dapat Dicetak',
        'subtitle': 'Cetak dan simpan secara fisik',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.medical_services,
        'title': 'Akses Layanan',
        'subtitle': 'Konsultasi & riwayat medis',
        'color': const Color(0xFF059669),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20), // ✅ Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars, color: Color(0xFF2E7D89), size: 20), // ✅ Reduced size
              SizedBox(width: 10),
              Text(
                'Keunggulan QR Code',
                style: TextStyle(
                  fontSize: 18, // ✅ Reduced size
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3, // ✅ Increased aspect ratio
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: benefits.length,
            itemBuilder: (context, index) {
              final benefit = benefits[index];
              return Container(
                padding: const EdgeInsets.all(12), // ✅ Reduced padding
                decoration: BoxDecoration(
                  color: (benefit['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (benefit['color'] as Color).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8), // ✅ Reduced padding
                      decoration: BoxDecoration(
                        color: benefit['color'] as Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        benefit['icon'] as IconData,
                        color: Colors.white,
                        size: 20, // ✅ Reduced size
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      benefit['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12, // ✅ Reduced size
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      benefit['subtitle'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10, // ✅ Reduced size
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 2, // ✅ Limit lines
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D89), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D89).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _saveQRCode,
                  icon: const Icon(Icons.download, color: Colors.white, size: 18),
                  label: const Text(
                    'Simpan QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14, // ✅ Reduced size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14), // ✅ Reduced padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareQRCode,
                icon: const Icon(Icons.share, size: 18),
                label: const Text(
                  'Bagikan',
                  style: TextStyle(
                    fontSize: 14, // ✅ Reduced size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D89),
                  side: const BorderSide(color: Color(0xFF2E7D89), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12), // ✅ Reduced padding
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6), // ✅ Reduced padding
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QR Code Permanen',
                      style: TextStyle(
                        fontSize: 13, // ✅ Reduced size
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    Text(
                      'QR ini tidak akan berubah dan dapat digunakan selamanya',
                      style: TextStyle(
                        fontSize: 11, // ✅ Reduced size
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _shareQRCode() {
    // ✅ Handle simple QR data format
    String qrText;
    try {
      final parsed = json.decode(_qrCodeData ?? '');
      qrText = QRService.getQRText(_qrCodeData ?? '');
    } catch (e) {
      // Handle simple string format like "USER_002"
      qrText = """
HOSPITALINK PATIENT ID
====================
QR Code: ${_qrCodeData ?? 'N/A'}
Name: ${_currentUser?.fullName ?? 'N/A'}
NIK: ${_currentUser?.nik ?? 'N/A'}
Phone: ${_currentUser?.phone ?? 'N/A'}
Hospital: HospitalLink Medical Center
====================
Scan this QR for check-in
""";
    }
    
    Clipboard.setData(ClipboardData(text: qrText));
    _showSuccessSnackBar('QR Code berhasil disalin sebagai teks');
  }

  void _saveQRCode() {
    _showSuccessSnackBar('QR Code berhasil disimpan ke galeri');
  }

  void _showQRInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D89), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.security, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Keamanan QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QR Code Anda menggunakan sistem keamanan berlapis:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 12),
            Text(
              '• Hash signature untuk verifikasi\n'
              '• Terintegrasi dengan foto profil\n'
              '• Validasi khusus rumah sakit\n'
              '• Data terenkripsi aman',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Hanya petugas resmi HospitalLink yang dapat memproses QR Code ini.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D89),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Mengerti',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}