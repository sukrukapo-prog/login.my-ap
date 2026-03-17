import 'package:flutter/material.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/core/haptic_service.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});
  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> with SingleTickerProviderStateMixin {
  OnboardingData? _data;
  bool _loading = true;

  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _load();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final data = await LocalStorage.getUserData();
    if (mounted) {
      setState(() { _data = data; _loading = false; });
      _ctrl.forward(from: 0);
    }
  }

  double? get _bmi {
    final d = _data;
    if (d?.currentWeightKg == null || d?.heightCm == null) return null;
    final hm = d!.heightCm! / 100;
    return d.currentWeightKg! / (hm * hm);
  }

  String get _category {
    final b = _bmi;
    if (b == null) return '—';
    if (b < 18.5) return 'Underweight';
    if (b < 25)   return 'Normal';
    if (b < 30)   return 'Overweight';
    return 'Obese';
  }

  Color get _color {
    final b = _bmi;
    if (b == null) return Colors.white38;
    if (b < 18.5) return const Color(0xFF3B82F6);
    if (b < 25)   return const Color(0xFF2ECC71);
    if (b < 30)   return const Color(0xFFFF9F43);
    return const Color(0xFFFF4757);
  }

  String get _tip {
    final b = _bmi;
    if (b == null) return 'Update your weight and height in Profile settings.';
    if (b < 18.5) return 'You are underweight. Consider increasing calorie intake with nutrient-rich foods and consult a doctor.';
    if (b < 25)   return 'Great job! You are in the healthy weight range. Keep maintaining your current lifestyle.';
    if (b < 30)   return 'You are slightly overweight. Regular exercise and a balanced diet can help you reach a healthy BMI.';
    return 'Your BMI is in the obese range. We recommend consulting a healthcare professional for a personalised plan.';
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _bmi;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () { HapticService.light(); Navigator.pop(context); },
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('BMI Calculator', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              ]),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Main BMI card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_color.withOpacity(0.2), const Color(0xFF0F1624)],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _color.withOpacity(0.3)),
                      ),
                      child: Column(children: [
                        // Big ring
                        SizedBox(width: 160, height: 160,
                            child: Stack(alignment: Alignment.center, children: [
                              AnimatedBuilder(animation: _anim, builder: (_, __) =>
                                  CircularProgressIndicator(
                                    value: bmi != null ? ((bmi / 40) * _anim.value).clamp(0.0, 1.0) : 0,
                                    strokeWidth: 14,
                                    backgroundColor: Colors.white.withAlpha(15),
                                    valueColor: AlwaysStoppedAnimation(_color),
                                  )),
                              Column(mainAxisSize: MainAxisSize.min, children: [
                                AnimatedBuilder(animation: _anim, builder: (_, __) =>
                                    Text(
                                      bmi != null ? (bmi * _anim.value).toStringAsFixed(1) : '—',
                                      style: TextStyle(color: _color, fontSize: 40, fontWeight: FontWeight.w900),
                                    )),
                                Text('BMI', style: TextStyle(color: _color.withOpacity(0.7), fontSize: 14)),
                              ]),
                            ])),
                        const SizedBox(height: 16),
                        Text(_category, style: TextStyle(color: _color, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        if (_data?.currentWeightKg != null && _data?.heightCm != null)
                          Text(
                            '${_data!.currentWeightKg!.toStringAsFixed(1)} kg  ·  ${_data!.heightCm!.round()} cm',
                            style: const TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                      ]),
                    ),

                    const SizedBox(height: 20),

                    // Scale
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF151F30), borderRadius: BorderRadius.circular(16)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('BMI Scale', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        AnimatedBuilder(animation: _anim, builder: (_, __) {
                          final pct = bmi != null ? ((bmi - 10) / 30).clamp(0.0, 1.0) * _anim.value : 0.0;
                          final w = MediaQuery.of(context).size.width - 72.0;
                          return Stack(clipBehavior: Clip.none, children: [
                            ClipRRect(borderRadius: BorderRadius.circular(8),
                                child: Container(height: 16, decoration: const BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Color(0xFF3B82F6), Color(0xFF2ECC71),
                                      Color(0xFFFF9F43), Color(0xFFFF4757),
                                    ])))),
                            if (bmi != null) Positioned(
                                left: (pct * w).clamp(0, w - 8), top: -4,
                                child: Container(width: 24, height: 24,
                                  decoration: BoxDecoration(color: _color, shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [BoxShadow(color: _color.withOpacity(0.5), blurRadius: 8)]),
                                )),
                          ]);
                        }),
                        const SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          _scaleLabel('< 18.5', 'Underweight', const Color(0xFF3B82F6)),
                          _scaleLabel('18.5–24.9', 'Normal', const Color(0xFF2ECC71)),
                          _scaleLabel('25–29.9', 'Overweight', const Color(0xFFFF9F43)),
                          _scaleLabel('≥ 30', 'Obese', const Color(0xFFFF4757)),
                        ]),
                      ]),
                    ),

                    const SizedBox(height: 16),

                    // Stats row
                    Row(children: [
                      Expanded(child: _infoCard('Weight', _data?.currentWeightKg != null ? '${_data!.currentWeightKg!.toStringAsFixed(1)} kg' : '—', Icons.monitor_weight_outlined, const Color(0xFF10B981))),
                      const SizedBox(width: 10),
                      Expanded(child: _infoCard('Height', _data?.heightCm != null ? '${_data!.heightCm!.round()} cm' : '—', Icons.height, const Color(0xFF3B82F6))),
                    ]),

                    const SizedBox(height: 16),

                    // Tip card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _color.withOpacity(0.25)),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.lightbulb_outline, color: _color, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_tip, style: TextStyle(color: _color.withOpacity(0.9), fontSize: 13, height: 1.6))),
                      ]),
                    ),

                    const SizedBox(height: 16),

                    // Healthy range
                    if (_data?.heightCm != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF151F30), borderRadius: BorderRadius.circular(16)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Healthy Weight Range for Your Height', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Builder(builder: (_) {
                            final hm = _data!.heightCm! / 100;
                            final low  = (18.5 * hm * hm).toStringAsFixed(1);
                            final high = (24.9 * hm * hm).toStringAsFixed(1);
                            return Text('$low kg  –  $high kg',
                                style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 22, fontWeight: FontWeight.w900));
                          }),
                          const SizedBox(height: 4),
                          const Text('Based on BMI 18.5–24.9', style: TextStyle(color: Colors.white38, fontSize: 11)),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scaleLabel(String range, String label, Color color) => Column(children: [
    Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
    Text(range, style: const TextStyle(color: Colors.white24, fontSize: 8)),
  ]);

  Widget _infoCard(String label, String value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF151F30), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
        ]),
      );
}