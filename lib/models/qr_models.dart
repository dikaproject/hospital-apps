class HospitalQRData {
  final String type;
  final String userId;
  final String? nik;
  final String fullName;
  final String? phone;
  final int timestamp;
  final String hospital;
  final String? profilePicture;
  final String qrVersion;

  HospitalQRData({
    required this.type,
    required this.userId,
    this.nik,
    required this.fullName,
    this.phone,
    required this.timestamp,
    required this.hospital,
    this.profilePicture,
    this.qrVersion = '1.0',
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'userId': userId,
      'nik': nik,
      'fullName': fullName,
      'phone': phone,
      'timestamp': timestamp,
      'hospital': hospital,
      'profilePicture': profilePicture,
      'qrVersion': qrVersion,
    };
  }

  factory HospitalQRData.fromJson(Map<String, dynamic> json) {
    return HospitalQRData(
      type: json['type'] ?? '',
      userId: json['userId'] ?? '',
      nik: json['nik'],
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      timestamp: json['timestamp'] ?? 0,
      hospital: json['hospital'] ?? '',
      profilePicture: json['profilePicture'],
      qrVersion: json['qrVersion'] ?? '1.0',
    );
  }

  // Validation methods
  bool isValid() {
    return userId.isNotEmpty && 
           fullName.isNotEmpty && 
           timestamp > 0 &&
           _isTimestampValid();
  }

  bool _isTimestampValid() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - timestamp;
    // QR valid for 5 minutes
    return diff < (5 * 60 * 1000);
  }

  bool requiresFaceVerification() {
    return profilePicture != null && profilePicture!.isNotEmpty;
  }
}