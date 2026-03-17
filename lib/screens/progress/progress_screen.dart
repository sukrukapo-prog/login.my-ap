import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/services/firestore_service.dart';
import 'package:fitmetrics/services/food_storage_service.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/core/haptic_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {

  OnboardingData? _userData;
  Map<String, dynamic> _progress = {};
  Map<String, int> _foodCalories = {};
  int _foodGoal   = 2000;
  int _waterMl    = 0;
  bool _isLoading = true;
  int _tabIndex   = 0;

  late AnimationController _counterCtrl;
  late AnimationController _barCtrl;
  late AnimationController _tabSlideCtrl;
  late Animation<double> _counterAnim;
  late Animation<double> _barAnim;
  late Animation<Offset> _slideAnim;

  final _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _counterCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _barCtrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _tabSlideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _counterAnim  = CurvedAnimation(parent: _counterCtrl,  curve: Curves.easeOut);
    _barAnim      = CurvedAnimation(parent: _barCtrl,      curve: Curves.easeOutCubic);
    _slideAnim    = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _tabSlideCtrl, curve: Curves.easeOut));
    _loadData();
  }

  @override
  void dispose() {
    _counterCtrl.dispose();
    _barCtrl.dispose();
    _tabSlideCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      FirestoreService.getFullProgressData(),
      FoodStorageService.getAllCalories(),
      FoodStorageService.getCalorieGoal(),
      FoodStorageService.getWaterMl(),
      LocalStorage.getUserData(),
    ]);
    if (!mounted) return;
    setState(() {
      _progress     = results[0] as Map<String, dynamic>;
      _foodCalories = results[1] as Map<String, int>;
      _foodGoal     = results[2] as int;
      _waterMl      = results[3] as int;
      _userData     = results[4] as OnboardingData?;
      _isLoading    = false;
    });
    _counterCtrl.forward(from: 0);
    _barCtrl.forward(from: 0);
    _tabSlideCtrl.forward(from: 0);
  }

  void _switchTab(int i) {
    if (i == _tabIndex) return;
    HapticService.selection();
    setState(() => _tabIndex = i);
    _tabSlideCtrl.forward(from: 0);
    _counterCtrl.forward(from: 0);
    _barCtrl.forward(from: 0);
  }

  int get _medMinutes {
    if (_tabIndex == 0) return (_progress['medToday'] as int?) ?? 0;
    if (_tabIndex == 1) return (_progress['medWeek']  as int?) ?? 0;
    return (_progress['medTotal'] as int?) ?? 0;
  }
  int get _medSessions   => (_progress['medSessions']    as int?) ?? 0;
  int get _streak        => (_progress['streakCurrent']  as int?) ?? 0;
  int get _longestStreak => (_progress['streakLongest']  as int?) ?? 0;

  int get _workoutSessions {
    if (_tabIndex == 0) return (_progress['workoutsToday'] as int?) ?? 0;
    if (_tabIndex == 1) return (_progress['workoutsWeek']  as int?) ?? 0;
    return (_progress['workoutsTotal'] as int?) ?? 0;
  }
  int get _caloriesBurned {
    if (_tabIndex == 0) return (_progress['calToday'] as int?) ?? 0;
    if (_tabIndex == 1) return (_progress['calWeek']  as int?) ?? 0;
    return (_progress['calTotal'] as int?) ?? 0;
  }

  int get _foodTotal   => _foodCalories.values.fold(0, (a, b) => a + b);
  int get _waterGlasses => (_waterMl / 250).floor();

  double? get _bmi {
    final d = _userData;
    if (d?.currentWeightKg == null || d?.heightCm == null) return null;
    final hm = d!.heightCm! / 100;
    return d.currentWeightKg! / (hm * hm);
  }
  String get _bmiCategory {
    final b = _bmi;
    if (b == null) return '—';
    if (b < 18.5) return 'Underweight';
    if (b < 25)   return 'Normal';
    if (b < 30)   return 'Overweight';
    return 'Obese';
  }
  Color get _bmiColor {
    final b = _bmi;
    if (b == null) return Colors.white38;
    if (b < 18.5) return const Color(0xFF3B82F6);
    if (b < 25)   return const Color(0xFF2ECC71);
    if (b < 30)   return const Color(0xFFFF9F43);
    return const Color(0xFFFF4757);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1624),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: SlideTransition(
                position: _slideAnim,
                child: RefreshIndicator(
                  color: const Color(0xFF3B82F6),
                  backgroundColor: const Color(0xFF1A2540),
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMeditationSection(),
                        const SizedBox(height: 16),
                        _buildWorkoutSection(),
                        const SizedBox(height: 16),
                        _buildFoodSection(),
                        const SizedBox(height: 16),
                        _buildWaterSection(),
                        const SizedBox(height: 16),
                        _buildBMISection(),
                        const SizedBox(height: 16),
                        _buildBodyStatsSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Row(children: [
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
      const Text('My Progress', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
    ]),
  );

  Widget _buildTabBar() {
    final tabs = ['Today', 'This Week', 'All Time'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(color: Colors.white.withAlpha(12), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: tabs.asMap().entries.map((e) {
            final sel = e.key == _tabIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => _switchTab(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF3B82F6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(e.value,
                      style: TextStyle(
                        color: sel ? Colors.white : Colors.white54,
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      ))),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) => Row(children: [
    Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 16),
    ),
    const SizedBox(width: 10),
    Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
  ]);

  Widget _buildMeditationSection() {
    final weeklyMed = (_progress['weeklyMed'] as List?)?.cast<int>() ?? List.filled(7, 0);
    final maxBar = weeklyMed.isEmpty ? 1 : weeklyMed.reduce((a, b) => a > b ? a : b).clamp(1, 9999);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Meditation', Icons.self_improvement, const Color(0xFF8B5CF6)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _statCard('Minutes', _medMinutes, '', const Color(0xFF8B5CF6), Icons.access_time)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Streak', _streak, 'days 🔥', const Color(0xFFF59E0B), Icons.local_fire_department)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Sessions', _medSessions, '', const Color(0xFF3B82F6), Icons.play_circle_outline)),
      ]),
      if (_tabIndex == 1) ...[const SizedBox(height: 12), _barChart(weeklyMed, maxBar, const Color(0xFF8B5CF6))],
      if (_tabIndex == 2) ...[const SizedBox(height: 10), _wideStatCard('Longest Streak', _longestStreak, 'days 🏆', const Color(0xFFFFD700), Icons.emoji_events)],
    ]);
  }

  Widget _buildWorkoutSection() {
    final weeklyWo = (_progress['weeklyWorkoutCal'] as List?)?.cast<int>() ?? List.filled(7, 0);
    final maxBar = weeklyWo.isEmpty ? 1 : weeklyWo.reduce((a, b) => a > b ? a : b).clamp(1, 9999);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Workout', Icons.fitness_center, const Color(0xFF2ECC71)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _statCard('Sessions', _workoutSessions, '', const Color(0xFF2ECC71), Icons.fitness_center)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Kcal Burned', _caloriesBurned, '', const Color(0xFFFF9F43), Icons.local_fire_department)),
      ]),
      if (_tabIndex == 1) ...[const SizedBox(height: 12), _barChart(weeklyWo, maxBar, const Color(0xFF2ECC71))],
    ]);
  }

  Widget _buildFoodSection() {
    // Food is daily local data — only show for Today tab
    if (_tabIndex != 0) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('Food & Nutrition', Icons.restaurant, const Color(0xFFEC4899)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF151F30),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.15)),
          ),
          child: Column(children: [
            const Text('🍽️', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            const Text('Food data is tracked daily', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Switch to Today tab to see your calorie intake', style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
          ]),
        ),
      ]);
    }

    final progress = (_foodTotal / _foodGoal).clamp(0.0, 1.0);
    final over = _foodTotal > _foodGoal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Food & Nutrition', Icons.restaurant, const Color(0xFFEC4899)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151F30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.2)),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AnimatedBuilder(animation: _counterAnim, builder: (_, __) =>
                  Text('${(_foodTotal * _counterAnim.value).round()} kcal',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
              Text('of $_foodGoal kcal goal', style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: over ? const Color(0xFFFF4757).withOpacity(0.15) : const Color(0xFF2ECC71).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                over ? '+${_foodTotal - _foodGoal} over' : '${(_foodGoal - _foodTotal).clamp(0, _foodGoal)} left',
                style: TextStyle(color: over ? const Color(0xFFFF4757) : const Color(0xFF2ECC71), fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          AnimatedBuilder(animation: _barAnim, builder: (_, __) =>
              ClipRRect(borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress * _barAnim.value, minHeight: 10,
                    backgroundColor: Colors.white.withAlpha(20),
                    valueColor: AlwaysStoppedAnimation(over ? const Color(0xFFFF4757) : const Color(0xFFEC4899)),
                  ))),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _miniStat('Breakfast', _foodCalories['breakfast'] ?? 0, const Color(0xFFF59E0B)),
            _miniStat('Lunch',     _foodCalories['lunch']     ?? 0, const Color(0xFF2ECC71)),
            _miniStat('Dinner',    _foodCalories['dinner']    ?? 0, const Color(0xFF8B5CF6)),
            _miniStat('Drinks',    _foodCalories['drinks']    ?? 0, const Color(0xFF3B82F6)),
            _miniStat('Fruits',    _foodCalories['fruits']    ?? 0, const Color(0xFFEC4899)),
          ]),
        ]),
      ),
    ]);
  }

  Widget _miniStat(String label, int val, Color color) => Column(children: [
    AnimatedBuilder(animation: _counterAnim, builder: (_, __) =>
        Text('${(val * _counterAnim.value).round()}',
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800))),
    Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
  ]);

  Widget _buildWaterSection() {
    if (_tabIndex != 0) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('Water Intake', Icons.water_drop, const Color(0xFF3B82F6)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF151F30),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.15)),
          ),
          child: Column(children: [
            const Text('💧', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            const Text('Water is tracked daily', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Switch to Today tab to see your water intake', style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
          ]),
        ),
      ]);
    }
    final progress = (_waterMl / 2500).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Water Intake', Icons.water_drop, const Color(0xFF3B82F6)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151F30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$_waterGlasses glasses · $_waterMl ml',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const Text('Goal: 10 glasses / 2500 ml', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ]),
            Text('${(progress * 100).round()}%',
                style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 20, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 12),
          AnimatedBuilder(animation: _barAnim, builder: (_, __) =>
              ClipRRect(borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress * _barAnim.value, minHeight: 10,
                    backgroundColor: Colors.white.withAlpha(20),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                  ))),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(10, (i) => Container(
                width: 20, height: 26, margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i < _waterGlasses ? const Color(0xFF3B82F6) : Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: i < _waterGlasses ? const Icon(Icons.water_drop, color: Colors.white, size: 12) : null,
              ))),
        ]),
      ),
    ]);
  }

  Widget _buildBMISection() {
    final bmi = _bmi;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('BMI', Icons.monitor_weight_outlined, _bmiColor),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151F30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _bmiColor.withOpacity(0.25)),
        ),
        child: bmi == null
            ? const Center(child: Text('Add weight & height in Profile to see BMI',
            style: TextStyle(color: Colors.white38, fontSize: 13)))
            : Column(children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AnimatedBuilder(animation: _counterAnim, builder: (_, __) =>
                  Text((bmi * _counterAnim.value).toStringAsFixed(1),
                      style: TextStyle(color: _bmiColor, fontSize: 36, fontWeight: FontWeight.w900))),
              Text(_bmiCategory, style: TextStyle(color: _bmiColor, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${_userData!.currentWeightKg!.toStringAsFixed(1)} kg · ${_userData!.heightCm?.round()} cm',
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ])),
            SizedBox(width: 80, height: 80,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(
                    value: (bmi / 40).clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withAlpha(20),
                    valueColor: AlwaysStoppedAnimation(_bmiColor),
                  ),
                  Text(bmi.toStringAsFixed(1),
                      style: TextStyle(color: _bmiColor, fontSize: 15, fontWeight: FontWeight.w800)),
                ])),
          ]),
          const SizedBox(height: 14),
          AnimatedBuilder(animation: _barAnim, builder: (_, __) {
            final pct = ((bmi - 10) / 30).clamp(0.0, 1.0) * _barAnim.value;
            final w = MediaQuery.of(context).size.width - 64;
            return Stack(clipBehavior: Clip.none, children: [
              ClipRRect(borderRadius: BorderRadius.circular(6),
                  child: Container(height: 10, decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2ECC71), Color(0xFFFF9F43), Color(0xFFFF4757)])))),
              Positioned(left: (pct * w).clamp(0, w - 8), top: -4,
                  child: Container(width: 18, height: 18,
                      decoration: BoxDecoration(color: _bmiColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
            ]);
          }),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _bmiLabel('< 18.5', 'Under', const Color(0xFF3B82F6)),
            _bmiLabel('18.5–24.9', 'Normal', const Color(0xFF2ECC71)),
            _bmiLabel('25–29.9', 'Over', const Color(0xFFFF9F43)),
            _bmiLabel('≥ 30', 'Obese', const Color(0xFFFF4757)),
          ]),
        ]),
      ),
    ]);
  }

  Widget _bmiLabel(String range, String label, Color color) => Column(children: [
    Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    Text(range, style: const TextStyle(color: Colors.white24, fontSize: 9)),
  ]);

  Widget _buildBodyStatsSection() {
    double? bmr;
    final d = _userData;
    if (d?.currentWeightKg != null && d?.heightCm != null && d?.age != null && d?.gender != null) {
      bmr = d!.gender == 'Male'
          ? 10 * d.currentWeightKg! + 6.25 * d.heightCm! - 5 * d.age! + 5
          : 10 * d.currentWeightKg! + 6.25 * d.heightCm! - 5 * d.age! - 161;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Body Stats', Icons.accessibility_new, const Color(0xFF10B981)),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5,
        children: [
          _statCard('Weight', d?.currentWeightKg?.round() ?? 0, 'kg',      const Color(0xFF10B981), Icons.monitor_weight_outlined),
          _statCard('Height', d?.heightCm?.round() ?? 0,        'cm',      const Color(0xFF3B82F6), Icons.height),
          _statCard('BMR',    bmr?.round() ?? 0,                'kcal/day',const Color(0xFFF59E0B), Icons.local_fire_department_outlined),
          _statCard('Age',    d?.age ?? 0,                      'years',   const Color(0xFFEC4899), Icons.cake_outlined),
        ],
      ),
    ]);
  }

  Widget _statCard(String title, int value, String suffix, Color color, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, color: color, size: 18),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedBuilder(animation: _counterAnim, builder: (_, __) =>
                Text('${(value * _counterAnim.value).round()}',
                    style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900))),
            if (suffix.isNotEmpty) Text(suffix, style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ]),
        ]),
      );

  Widget _wideStatCard(String title, int value, String suffix, Color color, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.25))),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedBuilder(animation: _counterAnim, builder: (_, __) =>
                Text('${(value * _counterAnim.value).round()} $suffix',
                    style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800))),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        ]),
      );

  Widget _barChart(List<int> data, int maxBar, Color color) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF151F30), borderRadius: BorderRadius.circular(16)),
        child: AnimatedBuilder(animation: _barAnim, builder: (_, __) =>
            SizedBox(height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final val = i < data.length ? data[i] : 0;
                    final frac = maxBar > 0 ? (val / maxBar) * _barAnim.value : 0.0;
                    final isToday = i == 6;
                    final barH = (frac * 80).clamp(4.0, 80.0);
                    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      if (val > 0) Text('$val', style: TextStyle(color: isToday ? color : Colors.white38, fontSize: 8, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Container(width: 26, height: barH, decoration: BoxDecoration(color: isToday ? color : color.withOpacity(0.3), borderRadius: BorderRadius.circular(5))),
                      const SizedBox(height: 5),
                      Text(_weekDays[i], style: TextStyle(color: isToday ? color : Colors.white38, fontSize: 9, fontWeight: isToday ? FontWeight.w700 : FontWeight.normal)),
                    ]);
                  }),
                ))),
      );
}