import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/core/haptic_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  OnboardingData? _userData;
  int _meditationToday = 0;
  int _meditationWeek = 0;
  int _dailyGoal = 15;
  List<int> _weeklyData = List.filled(7, 0);
  Map<String, int> _allTimeStats = {};
  bool _isLoading = true;
  int _chartFilter = 0; // 0=Week, 1=Month

  late AnimationController _animCtrl;
  late Animation<double> _barAnim;

  final _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _barAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _userData = await LocalStorage.getUserData();
    _meditationToday = await LocalStorage.getMeditationMinutes(DateTime.now());
    _meditationWeek = await LocalStorage.getMeditationMinutesForLastDays(7);
    _dailyGoal = await LocalStorage.getDailyGoalMinutes();
    _weeklyData = await LocalStorage.getWeeklyMeditationData();
    _allTimeStats = await LocalStorage.getAllTimeStats();
    setState(() => _isLoading = false);
    _animCtrl.forward(from: 0);
  }

  double? _calcBMR() {
    final d = _userData;
    if (d == null || d.currentWeightKg == null ||
        d.heightCm == null || d.age == null || d.gender == null) return null;
    if (d.gender == 'Male') {
      return 10 * d.currentWeightKg! + 6.25 * d.heightCm! - 5 * d.age! + 5;
    }
    return 10 * d.currentWeightKg! + 6.25 * d.heightCm! - 5 * d.age! - 161;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1624),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }

    final bmr = _calcBMR();
    final goalProgress = (_meditationToday / _dailyGoal).clamp(0.0, 1.0);
    final maxBar = _weeklyData.isEmpty ? 1 : _weeklyData.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () { HapticService.light(); Navigator.pop(context); },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text('My Progress',
                      style: TextStyle(color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF3B82F6),
                backgroundColor: const Color(0xFF1A2540),
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Today's goal ring ────────────────────────
                      _GoalRingCard(
                        progress: goalProgress,
                        minutesToday: _meditationToday,
                        goalMinutes: _dailyGoal,
                      ),

                      const SizedBox(height: 20),

                      // ── Weekly bar chart ─────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withAlpha(15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Meditation Activity',
                                    style: TextStyle(color: Colors.white,
                                        fontSize: 15, fontWeight: FontWeight.w700)),
                                // Filter tabs
                                Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: ['Week', 'Month'].asMap().entries.map((e) {
                                      final sel = e.key == _chartFilter;
                                      return GestureDetector(
                                        onTap: () {
                                          HapticService.selection();
                                          setState(() => _chartFilter = e.key);
                                          _animCtrl.forward(from: 0);
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: sel ? const Color(0xFF3B82F6) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(e.value,
                                                style: TextStyle(
                                                  color: sel ? Colors.white : Colors.white54,
                                                  fontSize: 11,
                                                  fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                                                )),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('$_meditationWeek min this week',
                                style: const TextStyle(color: Colors.white38,
                                    fontSize: 12)),
                            const SizedBox(height: 20),

                            // Bar chart
                            AnimatedBuilder(
                              animation: _barAnim,
                              builder: (_, __) => SizedBox(
                                height: 140,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: List.generate(7, (i) {
                                    final val = _weeklyData[i];
                                    final frac = maxBar > 0
                                        ? (val / maxBar) * _barAnim.value
                                        : 0.0;
                                    final isToday = i == 6;
                                    final barH = (frac * 100).clamp(4.0, 100.0);
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (val > 0)
                                          Text('${val}m',
                                              style: TextStyle(
                                                color: isToday
                                                    ? const Color(0xFF3B82F6)
                                                    : Colors.white38,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        const SizedBox(height: 3),
                                        Container(
                                          width: 28,
                                          height: barH,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isToday
                                                  ? [const Color(0xFF3B82F6),
                                                const Color(0xFF8B5CF6)]
                                                  : [Colors.white.withAlpha(80),
                                                Colors.white.withAlpha(30)],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(_weekDays[i],
                                            style: TextStyle(
                                              color: isToday
                                                  ? const Color(0xFF3B82F6)
                                                  : Colors.white38,
                                              fontSize: 10,
                                              fontWeight: isToday
                                                  ? FontWeight.w700
                                                  : FontWeight.normal,
                                            )),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── All-time stats ───────────────────────────
                      const Text('All-Time Stats',
                          style: TextStyle(color: Colors.white, fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _StatCard(
                            title: 'Total Hours',
                            value: '${_allTimeStats['totalHours'] ?? 0}h',
                            sub: '${_allTimeStats['totalMinutes'] ?? 0} mins',
                            icon: Icons.access_time,
                            color: const Color(0xFF3B82F6),
                          ),
                          _StatCard(
                            title: 'Current Streak',
                            value: '${_allTimeStats['streakDays'] ?? 0}',
                            sub: 'days in a row 🔥',
                            icon: Icons.local_fire_department,
                            color: const Color(0xFFF59E0B),
                          ),
                          _StatCard(
                            title: 'Longest Streak',
                            value: '${_allTimeStats['longestStreak'] ?? 0}',
                            sub: 'days record 🏆',
                            icon: Icons.emoji_events,
                            color: const Color(0xFFFFD700),
                          ),
                          _StatCard(
                            title: 'Total Sessions',
                            value: '${_allTimeStats['totalSessions'] ?? 0}',
                            sub: 'completed',
                            icon: Icons.self_improvement,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Body stats ───────────────────────────────
                      const Text('Body Stats',
                          style: TextStyle(color: Colors.white, fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _StatCard(
                            title: 'Weight',
                            value: _userData?.currentWeightKg != null
                                ? '${_userData!.currentWeightKg!.toStringAsFixed(1)}'
                                : '—',
                            sub: 'kg',
                            icon: Icons.monitor_weight_outlined,
                            color: const Color(0xFF10B981),
                          ),
                          _StatCard(
                            title: 'Height',
                            value: _userData?.heightCm != null
                                ? '${_userData!.heightCm!.round()}'
                                : '—',
                            sub: 'cm',
                            icon: Icons.height,
                            color: const Color(0xFF3B82F6),
                          ),
                          _StatCard(
                            title: 'BMR',
                            value: bmr != null ? '${bmr.round()}' : '—',
                            sub: 'kcal/day',
                            icon: Icons.local_fire_department_outlined,
                            color: const Color(0xFFF59E0B),
                          ),
                          _StatCard(
                            title: 'Age',
                            value: _userData?.age?.toString() ?? '—',
                            sub: 'years old',
                            icon: Icons.cake_outlined,
                            color: const Color(0xFFEC4899),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Goal ring card ─────────────────────────────────────────────────────────────
class _GoalRingCard extends StatelessWidget {
  final double progress;
  final int minutesToday;
  final int goalMinutes;
  const _GoalRingCard({
    required this.progress,
    required this.minutesToday,
    required this.goalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF0F1624)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          // Ring
          SizedBox(
            width: 90, height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90, height: 90,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 9,
                    backgroundColor: Colors.white.withAlpha(20),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3B82F6),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$pct%',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.w900,
                        )),
                    Text(progress >= 1.0 ? '🎉' : '🎯',
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progress >= 1.0 ? 'Daily Goal Reached! 🎉' : 'Daily Goal',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text('$minutesToday / $goalMinutes min',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withAlpha(20),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3B82F6),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  progress >= 1.0
                      ? 'Amazing work today!'
                      : '${(goalMinutes - minutesToday).clamp(0, 999)} min left to reach goal',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title, value, sub;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.title, required this.value, required this.sub,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.w900)),
              Text(sub, style: TextStyle(color: color.withAlpha(200), fontSize: 10)),
              Text(title,
                  style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
