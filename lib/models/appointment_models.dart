import 'family_models.dart';

enum AppointmentStatus {
  confirmed,
  waitingConfirmation,
  cancelled,
  completed,
}

enum AppointmentType {
  consultation,
  checkup,
  followUp,
  emergency,
}

class FamilyAppointment {
  final String id;
  final String memberName;
  final FamilyRelation memberRelation;
  final String doctorName;
  final String specialty;
  final String hospital;
  final DateTime dateTime;
  final String queueNumber;
  final AppointmentStatus status;
  final AppointmentType type;
  final String notes;

  FamilyAppointment({
    required this.id,
    required this.memberName,
    required this.memberRelation,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.dateTime,
    this.queueNumber = '',
    required this.status,
    required this.type,
    this.notes = '',
  });
}
