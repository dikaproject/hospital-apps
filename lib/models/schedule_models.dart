enum ScheduleStatus {
  pending,
  confirmed,
  waitingConfirmation,
  cancelled,
  completed,
}

enum ConsultationType {
  consultation,
  followUp,
  checkUp,
}

class ConsultationSchedule {
  final String id;
  final String doctorName;
  final String specialty;
  final String hospital;
  final DateTime scheduledDate;
  final ConsultationType type;
  final ScheduleStatus status;
  final String? queueNumber;
  final int estimatedDuration; // in minutes
  final String room;
  final String notes;
  final bool isUrgent;

  ConsultationSchedule({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.scheduledDate,
    required this.type,
    required this.status,
    this.queueNumber,
    required this.estimatedDuration,
    required this.room,
    this.notes = '',
    this.isUrgent = false,
  });

  ConsultationSchedule copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    String? hospital,
    DateTime? scheduledDate,
    ConsultationType? type,
    ScheduleStatus? status,
    String? queueNumber,
    int? estimatedDuration,
    String? room,
    String? notes,
    bool? isUrgent,
  }) {
    return ConsultationSchedule(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      hospital: hospital ?? this.hospital,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      type: type ?? this.type,
      status: status ?? this.status,
      queueNumber: queueNumber ?? this.queueNumber,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      room: room ?? this.room,
      notes: notes ?? this.notes,
      isUrgent: isUrgent ?? this.isUrgent,
    );
  }

  bool get isActive {
    final now = DateTime.now();
    final scheduledDay =
        DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return (status == ScheduleStatus.confirmed || isUrgent) &&
        (scheduledDay.isAtSameMomentAs(today) ||
            scheduledDay.isAtSameMomentAs(tomorrow) ||
            (scheduledDay.isAfter(today) &&
                scheduledDay.isBefore(today.add(const Duration(days: 7)))));
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return scheduledDate.isAfter(now) && !isActive;
  }
}
