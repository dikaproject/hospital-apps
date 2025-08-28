import 'package:flutter/material.dart';
import '../models/family_models.dart';

class FamilyStatsWidget extends StatelessWidget {
  final FamilyStats stats;

  const FamilyStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Keluarga',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        _buildStatsGrid(),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.family_restroom,
                title: 'Total Anggota',
                value: stats.totalMembers.toString(),
                subtitle: '${stats.activeMembers} aktif',
                color: const Color(0xFF3498DB),
                gradientColors: [
                  const Color(0xFF3498DB),
                  const Color(0xFF2980B9),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.event,
                title: 'Jadwal Konsultasi',
                value: stats.upcomingAppointments.toString(),
                subtitle: 'akan datang',
                color: const Color(0xFF2ECC71),
                gradientColors: [
                  const Color(0xFF2ECC71),
                  const Color(0xFF27AE60),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.science,
                title: 'Hasil Lab',
                value: stats.pendingResults.toString(),
                subtitle: 'menunggu',
                color: const Color(0xFF9B59B6),
                gradientColors: [
                  const Color(0xFF9B59B6),
                  const Color(0xFF8E44AD),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.medication,
                title: 'Obat Aktif',
                value: stats.activeMedications.toString(),
                subtitle: 'dikonsumsi',
                color: const Color(0xFFE67E22),
                gradientColors: [
                  const Color(0xFFE67E22),
                  const Color(0xFFD35400),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildEmergencyContactCard(),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              if (value != '0')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stats.emergencyContacts > 0
              ? const Color(0xFFE74C3C).withOpacity(0.3)
              : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emergency,
              color: Color(0xFFE74C3C),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kontak Darurat',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stats.emergencyContacts > 0
                      ? '${stats.emergencyContacts} anggota tersedia untuk kontak darurat'
                      : 'Belum ada kontak darurat',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: stats.emergencyContacts > 0
                  ? const Color(0xFF2ECC71).withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              stats.emergencyContacts > 0 ? 'Aktif' : 'Tidak Aktif',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: stats.emergencyContacts > 0
                    ? const Color(0xFF2ECC71)
                    : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
