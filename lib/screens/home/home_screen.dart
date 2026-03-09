import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/core/avatar_data.dart';
import 'package:fitmetrics/core/audio_service.dart';
import 'package:fitmetrics/routes.dart';
import 'package:fitmetrics/screens/main_tab_screen.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/core/haptic_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  OnboardingData? _userData;
  double? _maintenanceCalories;
  String? _avatarId;
  int _meditationMinutesToday = 0;
  int _goalMinutes = 20;
  int _streakDays = 0;
  bool _isRestDay = false;
  bool _isLoading = true;
  int _unreadNotifications = 3;

  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _progressAnim = CurvedAnimation(
        parent: _progressCtrl, curve: Curves.easeOutCubic);
    _loadData();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await LocalStorage.getUserData();
    if (data != null) {
      _userData = data;
      _maintenanceCalories = _calculateMaintenance(data);
    }
    _avatarId = await LocalStorage.getAvatarId();
    _meditationMinutesToday =
    await LocalStorage.getMeditationMinutes(DateTime.now());
    _goalMinutes = await LocalStorage.getDailyGoalMinutes();
    final stats = await LocalStorage.getAllTimeStats();
    _streakDays = stats['streakDays'] ?? 0;

    // Rest day: no sessions in last 2 days
    final yesterday =
    await LocalStorage.getMeditationMinutes(DateTime.now().subtract(const Duration(days: 1)));
    _isRestDay = _meditationMinutesToday == 0 && yesterday == 0 && _streakDays == 0;

    setState(() => _isLoading = false);
    _progressCtrl.forward(from: 0);
  }

  double? _calculateMaintenance(OnboardingData data) {
    if (data.currentWeightKg == null ||
        data.heightCm == null ||
        data.age == null ||
        data.gender == null) return null;
    double bmr;
    if (data.gender == 'Male') {
      bmr = 10 * data.currentWeightKg! +
          6.25 * data.heightCm! -
          5 * data.age! +
          5;
    } else {
      bmr = 10 * data.currentWeightKg! +
          6.25 * data.heightCm! -
          5 * data.age! -
          161;
    }
    double multiplier = 1.375;
    for (final goal in data.goals) {
      if (goal.contains('sedentary')) multiplier = 1.2;
      if (goal.contains('lightly_active')) multiplier = 1.375;
      if (goal.contains('moderately_active')) multiplier = 1.55;
      if (goal.contains('very_active')) multiplier = 1.725;
    }
    return bmr * multiplier;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '👋';
    return '🌙';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  void _navigate(String dest) {
    AudioService().playClickSound();
    HapticService.medium();
    if (dest == 'meditation') {
      final mainTabState =
      context.findAncestorStateOfType<MainTabScreenState>();
      mainTabState?.setTab(2);
    } else if (dest == 'progress') {
      Navigator.pushNamed(context, AppRoutes.progress);
    } else if (dest == 'leaderboard') {
      Navigator.pushNamed(context, AppRoutes.leaderboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${dest[0].toUpperCase()}${dest.substring(1)} — coming soon!')),
      );
    }
  }

  void _goToNotifications() {
    AudioService().playClickSound();
    HapticService.light();
    Navigator.pushNamed(context, AppRoutes.notificationHistory);
    setState(() => _unreadNotifications = 0);
  }

  void _goToProfile() {
    AudioService().playClickSound();
    HapticService.light();
    final mainTabState =
    context.findAncestorStateOfType<MainTabScreenState>();
    mainTabState?.setTab(4);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1624),
        body: Center(
            child:
            CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }

    final calories = _maintenanceCalories;
    final name = _userData?.name ?? 'there';
    final progressValue =
    (_goalMinutes > 0 ? _meditationMinutesToday / _goalMinutes : 0.0)
        .clamp(0.0, 1.0);
    final meditationText = _meditationMinutesToday > 0
        ? '$_meditationMinutesToday min today'
        : 'Start today';

    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF3B82F6),
          backgroundColor: const Color(0xFF1A2540),
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Top bar ────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getFormattedDate(),
                              style: const TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${_getGreeting()}, $name! ',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800),
                                ),
                                TextSpan(
                                  text: _getGreetingEmoji(),
                                  style: const TextStyle(fontSize: 19),
                                ),
                              ],
                            ),
                          ),
                          const Text("Here's your daily summary",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // Notification bell
                        GestureDetector(
                          onTap: _goToNotifications,
                          child: Stack(
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white.withAlpha(25)),
                                ),
                                child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white70,
                                    size: 22),
                              ),
                              if (_unreadNotifications > 0)
                                Positioned(
                                  top: 4, right: 4,
                                  child: Container(
                                    width: 16, height: 16,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                          '$_unreadNotifications',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight:
                                              FontWeight.w800)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _goToProfile,
                          child: AvatarWidget(
                              avatarId: _avatarId,
                              size: 46,
                              showBorder: true),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── Rest day banner ────────────────────────────────────────
                if (_isRestDay) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF8B5CF6).withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        const Text('💤', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rest day?',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              Text(
                                  "You haven't meditated in 2 days. Even 5 mins helps!",
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _navigate('meditation'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Start',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Streak + Progress row ──────────────────────────────────
                Row(
                  children: [
                    // Streak card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF59E0B).withAlpha(40),
                              const Color(0xFFF59E0B).withAlpha(15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: const Color(0xFFF59E0B).withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥',
                                style: TextStyle(fontSize: 26)),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text('$_streakDays',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900)),
                                const Text('day streak',
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Daily goal ring
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF3B82F6).withAlpha(40),
                              const Color(0xFF3B82F6).withAlpha(15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: const Color(0xFF3B82F6).withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            AnimatedBuilder(
                              animation: _progressAnim,
                              builder: (_, __) => SizedBox(
                                width: 42, height: 42,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: progressValue *
                                          _progressAnim.value,
                                      strokeWidth: 5,
                                      backgroundColor:
                                      Colors.white.withAlpha(25),
                                      valueColor:
                                      const AlwaysStoppedAnimation(
                                          Color(0xFF3B82F6)),
                                    ),
                                    Text(
                                      '${(progressValue * 100).round()}%',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text('$_meditationMinutesToday/$_goalMinutes min',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                  const Text('daily goal',
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── Calories card ──────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A5F), Color(0xFF0F1624)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border:
                    Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                        ['GOAL', 'FOOD', 'EXERCISE', 'NET'].map((label) =>
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8),
                              child: Text(label,
                                  style: TextStyle(
                                    color: label == 'NET'
                                        ? const Color(0xFF3B82F6)
                                        : Colors.white38,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  )),
                            )).toList(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 160, height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 160, height: 160,
                              child: CircularProgressIndicator(
                                value: 1.0, strokeWidth: 12,
                                backgroundColor:
                                Colors.white.withAlpha(20),
                                valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF3B82F6)),
                              ),
                            ),
                            Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                const Text('your balance\ncalories',
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        height: 1.4),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 6),
                                Text(
                                    calories != null
                                        ? calories.round().toString()
                                        : '—',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900)),
                                const Text('kcal net',
                                    style: TextStyle(
                                        color: Color(0xFF3B82F6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                              label: 'GOAL',
                              value: calories != null
                                  ? calories.round().toString()
                                  : '—',
                              color: Colors.white70),
                          _StatItem(
                              label: '- FOOD',
                              value: '0',
                              color: Colors.orangeAccent,
                              icon: Icons.restaurant_outlined),
                          _StatItem(
                              label: '+ BURNED',
                              value: '0',
                              color: const Color(0xFF10B981),
                              icon:
                              Icons.local_fire_department_outlined),
                          _StatItem(
                              label: 'REMAINING',
                              value: calories != null
                                  ? calories.round().toString()
                                  : '—',
                              color: Colors.white70),
                        ],
                      ),
                    ],
                  ),
                ),

                if (calories == null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFF3B82F6).withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF3B82F6).withAlpha(75)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Color(0xFF3B82F6), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'Complete your profile to see your maintenance calories.',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ── Quick Access ───────────────────────────────────────────
                const Text('Quick Access',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),

                _LeaderboardCard(
                    onTap: () => _navigate('leaderboard')),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _QuickCard(
                        title: 'Diet',
                        subtitle: 'Log meals & macros',
                        icon: Icons.restaurant_menu_outlined,
                        color: const Color(0xFF10B981),
                        onTap: () => _navigate('diet')),
                    _QuickCard(
                        title: 'Workout',
                        subtitle: "Today's plan",
                        icon: Icons.fitness_center_outlined,
                        color: const Color(0xFF3B82F6),
                        onTap: () => _navigate('workout')),
                    _MeditationCard(
                        subtitle: meditationText,
                        onTap: () => _navigate('meditation')),
                    _QuickCard(
                        title: 'Progress',
                        subtitle: 'View your stats',
                        icon: Icons.trending_up,
                        color: const Color(0xFFF59E0B),
                        onTap: () => _navigate('progress')),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Leaderboard full width card ────────────────────────────────────────────────
class _LeaderboardCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LeaderboardCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF59E0B).withAlpha(40),
              const Color(0xFFFFD700).withAlpha(15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFF59E0B).withAlpha(80)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events,
                  color: Color(0xFFF59E0B), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Leaderboard',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withAlpha(40),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('You are #4',
                            style: TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      const Text('View rankings →',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                for (int i = 1; i <= 3; i++)
                  Transform.translate(
                    offset: Offset(-(i - 1) * 10.0, 0),
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF0F1624), width: 2),
                        color: const Color(0xFFF59E0B).withAlpha(40),
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white54, size: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MeditationCard extends StatelessWidget {
  final String subtitle;
  final VoidCallback onTap;
  const _MeditationCard(
      {required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF8B5CF6);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                  'assets/images/meditation/meditation_icon.jpg',
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.self_improvement,
                      color: color,
                      size: 26)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Meditation',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData? icon;
  const _StatItem(
      {required this.label,
        required this.value,
        required this.color,
        this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) Icon(icon, color: color, size: 14),
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard(
      {required this.title,
        required this.subtitle,
        required this.icon,
        required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 26),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
