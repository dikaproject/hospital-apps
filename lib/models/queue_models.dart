enum QueueStatus { waiting, called, inProgress, completed, cancelled }

class QueueDetailInfo {
  final String queueNumber;
  final String currentNumber;
  final QueueStatus status;
  final String doctorName;
  final String specialty;
  final String hospital;
  final String room;
  final int estimatedWaitTime;
  final int remainingQueue;
  final DateTime appointmentTime;
  final String? consultationId;
  final bool isPriority;
  
  // Tambahan field yang dibutuhkan queue_detail_screen.dart
  final int position;
  final int totalQueue;
  final DateTime createdAt;
  final DateTime estimatedCallTime;
  final bool isFromOnlineConsultation;

  QueueDetailInfo({
    required this.queueNumber,
    required this.currentNumber,
    required this.status,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.room,
    required this.estimatedWaitTime,
    required this.remainingQueue,
    required this.appointmentTime,
    this.consultationId,
    this.isPriority = false,
    // Tambahan required parameters
    required this.position,
    required this.totalQueue,
    required this.createdAt,
    required this.estimatedCallTime,
    this.isFromOnlineConsultation = false,
  });

  // Tambah copyWith method untuk memudahkan update
  QueueDetailInfo copyWith({
    String? queueNumber,
    String? currentNumber,
    QueueStatus? status,
    String? doctorName,
    String? specialty,
    String? hospital,
    String? room,
    int? estimatedWaitTime,
    int? remainingQueue,
    DateTime? appointmentTime,
    String? consultationId,
    bool? isPriority,
    int? position,
    int? totalQueue,
    DateTime? createdAt,
    DateTime? estimatedCallTime,
    bool? isFromOnlineConsultation,
  }) {
    return QueueDetailInfo(
      queueNumber: queueNumber ?? this.queueNumber,
      currentNumber: currentNumber ?? this.currentNumber,
      status: status ?? this.status,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      hospital: hospital ?? this.hospital,
      room: room ?? this.room,
      estimatedWaitTime: estimatedWaitTime ?? this.estimatedWaitTime,
      remainingQueue: remainingQueue ?? this.remainingQueue,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      consultationId: consultationId ?? this.consultationId,
      isPriority: isPriority ?? this.isPriority,
      position: position ?? this.position,
      totalQueue: totalQueue ?? this.totalQueue,
      createdAt: createdAt ?? this.createdAt,
      estimatedCallTime: estimatedCallTime ?? this.estimatedCallTime,
      isFromOnlineConsultation: isFromOnlineConsultation ?? this.isFromOnlineConsultation,
    );
  }
}