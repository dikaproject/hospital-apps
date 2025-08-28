import 'package:flutter/material.dart';
import '../models/lab_models.dart';

class MedicationCardWidget extends StatelessWidget {
  final Medication medication;
  final VoidCallback onTap;
  final Function(bool) onToggleReminder;

  const MedicationCardWidget({
    super.key,
    required this.medication,
    required this.onTap,
    required this.onToggleReminder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: medication.isActive
                ? const Color(0xFF2ECC71).withOpacity(0.3)
                : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Color(0xFF3498DB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        '${medication.dosage} • ${medication.frequency}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildReminderToggle(),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.grey[600], size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Durasi: ${medication.duration} hari',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.info_outline,
                          color: Colors.grey[600], size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          medication.instructions,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7F8C8D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (medication.reminderEnabled &&
                      medication.reminderTimes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.notifications_active,
                            color: const Color(0xFF2ECC71), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Pengingat: ${medication.reminderTimes.join(", ")}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2ECC71),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (medication.sideEffects.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.warning_amber,
                      color: const Color(0xFFF39C12), size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Efek samping: ${medication.sideEffects}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFF39C12),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReminderToggle() {
    return GestureDetector(
      onTap: () => onToggleReminder(!medication.reminderEnabled),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: medication.reminderEnabled
              ? const Color(0xFF2ECC71).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: medication.reminderEnabled
                ? const Color(0xFF2ECC71)
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              medication.reminderEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: medication.reminderEnabled
                  ? const Color(0xFF2ECC71)
                  : Colors.grey[600],
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              medication.reminderEnabled ? 'ON' : 'OFF',
              style: TextStyle(
                color: medication.reminderEnabled
                    ? const Color(0xFF2ECC71)
                    : Colors.grey[600],
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
