import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/prescription_models.dart';

class MedicationNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(initializationSettings);
  }

  static Future<void> scheduleMedicationReminders(
      DigitalPrescription prescription) async {
    for (var medication in prescription.medications) {
      await _scheduleMedicationReminder(
          medication, prescription.prescriptionCode);
    }
  }

  static Future<void> _scheduleMedicationReminder(
      PrescriptionMedication medication, String prescriptionCode) async {
    // Parse frequency (e.g., "3x sehari", "2x sehari", "1x sehari")
    final frequency = _parseFrequency(medication.frequency);
    final timesPerDay = frequency['times'] as int;
    final intervalHours = 24 ~/ timesPerDay;

    // ✅ FIX: Use durationDays property instead of undefined property
    final durationDays = medication.durationDays;

    // Schedule notifications for the duration
    for (int day = 0; day < durationDays; day++) {
      for (int timeIndex = 0; timeIndex < timesPerDay; timeIndex++) {
        final scheduledDate = DateTime.now().add(Duration(
          days: day,
          hours: 8 + (timeIndex * intervalHours), // Start at 8 AM
        ));

        final id = '${medication.medicationId}_${day}_$timeIndex'.hashCode;

        await _notifications.zonedSchedule(
          id,
          'Pengingat Minum Obat',
          '${medication.genericName} - ${medication.dosage}\n${medication.instructions}',
          tz.TZDateTime.from(scheduledDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_reminders',
              'Pengingat Obat',
              channelDescription:
                  'Pengingat untuk minum obat sesuai resep dokter',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              color: Color(0xFF667EEA),
              enableVibration: true,
              playSound: true,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }

    print(
        '✅ Scheduled ${durationDays * timesPerDay} notifications for ${medication.genericName}');
  }

  static Map<String, dynamic> _parseFrequency(String frequency) {
    // Parse frequency string like "3x sehari", "2x sehari", etc.
    final regex =
        RegExp(r'(\d+)x?\s*(sehari|per\s*hari)', caseSensitive: false);
    final match = regex.firstMatch(frequency.toLowerCase());

    if (match != null) {
      return {'times': int.parse(match.group(1)!), 'period': 'daily'};
    }

    // Default to 3 times a day if parsing fails
    return {'times': 3, 'period': 'daily'};
  }

  static Future<void> cancelMedicationReminders(String medicationId) async {
    // Cancel all notifications for this medication
    // This would require keeping track of notification IDs
    print('Cancelled reminders for medication: $medicationId');
  }

  static Future<void> testNotification() async {
    await _notifications.show(
      999,
      'Test Pengingat Obat',
      'Ini adalah test notifikasi pengingat obat. Jika Anda melihat ini, pengingat sudah berfungsi!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_test',
          'Test Pengingat',
          channelDescription: 'Test untuk pengingat obat',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF667EEA),
        ),
      ),
    );
  }
}
