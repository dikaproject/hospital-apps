import 'package:flutter/material.dart';
import '../models/family_models.dart';

class FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onTap;
  final bool isHeadOfFamily;

  const FamilyMemberCard({
    super.key,
    required this.member,
    required this.onTap,
    this.isHeadOfFamily = false,
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
            color: _getBorderColor(),
            width: _getBorderWidth(),
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
          children: [
            Row(
              children: [
                _buildProfileSection(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoSection(),
                ),
                _buildStatusIndicator(),
              ],
            ),
            const SizedBox(height: 16),
            _buildHealthStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: _getProfileColor().withOpacity(0.1),
          child: member.profileImage.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    member.profileImage,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitialsAvatar(),
                  ),
                )
              : _buildInitialsAvatar(),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color:
                  member.isActive ? const Color(0xFF2ECC71) : Colors.grey[400],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar() {
    return Text(
      member.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
      style: TextStyle(
        color: _getProfileColor(),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                member.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (member.relation == FamilyRelation.self)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Saya',
                  style: TextStyle(
                    color: Color(0xFF3498DB),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              _getRelationIcon(member.relation),
              color: Colors.grey[600],
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '${getFamilyRelationText(member.relation)} • ${member.age} tahun',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.access_time, color: Colors.grey[600], size: 12),
            const SizedBox(width: 4),
            Text(
              'Aktif ${_formatLastActivity()}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF95A5A6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _getHealthStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getHealthStatusIcon(),
            color: _getHealthStatusColor(),
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getHealthStatusText(),
          style: TextStyle(
            fontSize: 10,
            color: _getHealthStatusColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (member.emergencyContact) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.emergency,
              color: Color(0xFFE74C3C),
              size: 10,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHealthStats() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.event,
              label: 'Jadwal',
              value: member.upcomingAppointments.toString(),
              color: const Color(0xFF3498DB),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.science,
              label: 'Lab',
              value: member.pendingLabResults.toString(),
              color: const Color(0xFF2ECC71),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.medication,
              label: 'Obat',
              value: member.activeMedications.toString(),
              color: const Color(0xFF9B59B6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getBorderColor() {
    if (member.relation == FamilyRelation.self) {
      return const Color(0xFF3498DB);
    }
    if (member.healthStatus == HealthStatus.needsAttention) {
      return const Color(0xFFF39C12);
    }
    if (member.healthStatus == HealthStatus.critical) {
      return const Color(0xFFE74C3C);
    }
    return Colors.grey[200]!;
  }

  double _getBorderWidth() {
    if (member.relation == FamilyRelation.self) return 2.0;
    if (member.healthStatus != HealthStatus.good) return 1.5;
    return 1.0;
  }

  Color _getProfileColor() {
    switch (member.relation) {
      case FamilyRelation.self:
        return const Color(0xFF3498DB);
      case FamilyRelation.spouse:
        return const Color(0xFF9B59B6);
      case FamilyRelation.child:
        return const Color(0xFF2ECC71);
      case FamilyRelation.parent:
        return const Color(0xFF34495E);
      case FamilyRelation.grandparent:
        return const Color(0xFFE67E22);
      case FamilyRelation.sibling:
        return const Color(0xFF1ABC9C);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  IconData _getRelationIcon(FamilyRelation relation) {
    switch (relation) {
      case FamilyRelation.self:
        return Icons.person;
      case FamilyRelation.spouse:
        return Icons.favorite;
      case FamilyRelation.child:
        return Icons.child_care;
      case FamilyRelation.parent:
        return Icons.family_restroom;
      case FamilyRelation.grandparent:
        return Icons.elderly;
      case FamilyRelation.sibling:
        return Icons.people;
      default:
        return Icons.person_outline;
    }
  }

  Color _getHealthStatusColor() {
    switch (member.healthStatus) {
      case HealthStatus.good:
        return const Color(0xFF2ECC71);
      case HealthStatus.needsAttention:
        return const Color(0xFFF39C12);
      case HealthStatus.critical:
        return const Color(0xFFE74C3C);
    }
  }

  IconData _getHealthStatusIcon() {
    switch (member.healthStatus) {
      case HealthStatus.good:
        return Icons.check_circle;
      case HealthStatus.needsAttention:
        return Icons.warning;
      case HealthStatus.critical:
        return Icons.error;
    }
  }

  String _getHealthStatusText() {
    switch (member.healthStatus) {
      case HealthStatus.good:
        return 'Sehat';
      case HealthStatus.needsAttention:
        return 'Perlu Perhatian';
      case HealthStatus.critical:
        return 'Kritis';
    }
  }

  String _formatLastActivity() {
    final now = DateTime.now();
    final difference = now.difference(member.lastActivity);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'baru saja';
    }
  }
}
