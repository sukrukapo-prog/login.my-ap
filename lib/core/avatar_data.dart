import 'package:flutter/material.dart';

class AppAvatar {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String category; // 'male', 'female', 'animal'

  const AppAvatar({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.category,
  });
}

const List<AppAvatar> allAvatars = [
  // Male avatars
  AppAvatar(
    id: 'male_athlete',
    name: 'Athlete',
    primaryColor: Color(0xFF3B82F6),
    secondaryColor: Color(0xFF1E3A5F),
    icon: Icons.sports_gymnastics,
    category: 'male',
  ),
  AppAvatar(
    id: 'male_casual',
    name: 'Casual',
    primaryColor: Color(0xFF10B981),
    secondaryColor: Color(0xFF064E3B),
    icon: Icons.person,
    category: 'male',
  ),
  AppAvatar(
    id: 'male_sporty',
    name: 'Sporty',
    primaryColor: Color(0xFFF59E0B),
    secondaryColor: Color(0xFF78350F),
    icon: Icons.directions_run,
    category: 'male',
  ),
  AppAvatar(
    id: 'male_zen',
    name: 'Zen',
    primaryColor: Color(0xFF8B5CF6),
    secondaryColor: Color(0xFF3B0764),
    icon: Icons.self_improvement,
    category: 'male',
  ),
  AppAvatar(
    id: 'male_runner',
    name: 'Runner',
    primaryColor: Color(0xFFEF4444),
    secondaryColor: Color(0xFF7F1D1D),
    icon: Icons.directions_walk,
    category: 'male',
  ),
  AppAvatar(
    id: 'male_strong',
    name: 'Strong',
    primaryColor: Color(0xFFEC4899),
    secondaryColor: Color(0xFF831843),
    icon: Icons.fitness_center,
    category: 'male',
  ),

  // Female avatars
  AppAvatar(
    id: 'female_athlete',
    name: 'Athlete',
    primaryColor: Color(0xFF06B6D4),
    secondaryColor: Color(0xFF164E63),
    icon: Icons.sports_gymnastics,
    category: 'female',
  ),
  AppAvatar(
    id: 'female_casual',
    name: 'Casual',
    primaryColor: Color(0xFF84CC16),
    secondaryColor: Color(0xFF365314),
    icon: Icons.person_2,
    category: 'female',
  ),
  AppAvatar(
    id: 'female_yoga',
    name: 'Yoga',
    primaryColor: Color(0xFFA78BFA),
    secondaryColor: Color(0xFF4C1D95),
    icon: Icons.self_improvement,
    category: 'female',
  ),
  AppAvatar(
    id: 'female_runner',
    name: 'Runner',
    primaryColor: Color(0xFFF97316),
    secondaryColor: Color(0xFF7C2D12),
    icon: Icons.directions_run,
    category: 'female',
  ),
  AppAvatar(
    id: 'female_strong',
    name: 'Strong',
    primaryColor: Color(0xFFF43F5E),
    secondaryColor: Color(0xFF881337),
    icon: Icons.fitness_center,
    category: 'female',
  ),
  AppAvatar(
    id: 'female_zen',
    name: 'Zen',
    primaryColor: Color(0xFF14B8A6),
    secondaryColor: Color(0xFF134E4A),
    icon: Icons.spa,
    category: 'female',
  ),

  // Animal avatars
  AppAvatar(
    id: 'animal_lion',
    name: 'Lion',
    primaryColor: Color(0xFFD97706),
    secondaryColor: Color(0xFF78350F),
    icon: Icons.pets,
    category: 'animal',
  ),
  AppAvatar(
    id: 'animal_wolf',
    name: 'Wolf',
    primaryColor: Color(0xFF6B7280),
    secondaryColor: Color(0xFF111827),
    icon: Icons.night_shelter,
    category: 'animal',
  ),
  AppAvatar(
    id: 'animal_eagle',
    name: 'Eagle',
    primaryColor: Color(0xFF92400E),
    secondaryColor: Color(0xFF1C1917),
    icon: Icons.flight,
    category: 'animal',
  ),
  AppAvatar(
    id: 'animal_tiger',
    name: 'Tiger',
    primaryColor: Color(0xFFEA580C),
    secondaryColor: Color(0xFF1C0A00),
    icon: Icons.track_changes,
    category: 'animal',
  ),
];

AppAvatar getAvatarById(String? id) {
  if (id == null) return allAvatars[0];
  return allAvatars.firstWhere(
        (a) => a.id == id,
    orElse: () => allAvatars[0],
  );
}

// Widget to display an avatar anywhere in the app
class AvatarWidget extends StatelessWidget {
  final String? avatarId;
  final double size;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    required this.avatarId,
    this.size = 48,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = getAvatarById(avatarId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [avatar.primaryColor, avatar.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: showBorder
            ? Border.all(color: avatar.primaryColor.withOpacity(0.6), width: 2.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: avatar.primaryColor.withOpacity(0.35),
            blurRadius: size * 0.3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        avatar.icon,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}