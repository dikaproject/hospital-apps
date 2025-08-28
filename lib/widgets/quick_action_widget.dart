import 'package:flutter/material.dart';

class QuickActionWidget extends StatelessWidget {
  final VoidCallback onAddMember;
  final VoidCallback onViewSchedules;
  final VoidCallback onViewLabResults;
  final VoidCallback onEmergencyContact;
  final bool isHeadOfFamily;

  const QuickActionWidget({
    super.key,
    required this.onAddMember,
    required this.onViewSchedules,
    required this.onViewLabResults,
    required this.onEmergencyContact,
    this.isHeadOfFamily = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.event_note,
                  label: 'Jadwal Keluarga',
                  color: const Color(0xFF3498DB),
                  onTap: onViewSchedules,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.science,
                  label: 'Hasil Lab',
                  color: const Color(0xFF2ECC71),
                  onTap: onViewLabResults,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.emergency,
                  label: 'Kontak Darurat',
                  color: const Color(0xFFE74C3C),
                  onTap: onEmergencyContact,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isHeadOfFamily
                    ? _buildActionButton(
                        icon: Icons.person_add,
                        label: 'Tambah Anggota',
                        color: const Color(0xFF9B59B6),
                        onTap: onAddMember,
                      )
                    : _buildActionButton(
                        icon: Icons.settings,
                        label: 'Pengaturan',
                        color: const Color(0xFF95A5A6),
                        onTap: () {}, // Placeholder
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
