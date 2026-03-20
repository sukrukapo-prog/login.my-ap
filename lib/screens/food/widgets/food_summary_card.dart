// lib/screens/food/widgets/food_summary_card.dart
// v2: dynamic calorie goal, red ring + alert banner when over goal,
//     water intake tracker with quick-add buttons.

import 'package:flutter/material.dart';
import 'package:fitmetrics/models/food_item.dart';

class FoodSummaryCard extends StatefulWidget {
  final Map<String, int> calories;
  final int total;
  final int goal;
  final int waterMl;
  final VoidCallback onEditGoal;
  final void Function(int ml) onAddWater;
  final VoidCallback onResetWater;

  const FoodSummaryCard({
    super.key,
    required this.calories,
    required this.total,
    required this.goal,
    required this.waterMl,
    required this.onEditGoal,
    required this.onAddWater,
    required this.onResetWater,
  });

  @override
  State<FoodSummaryCard> createState() => _FoodSummaryCardState();
}

class _FoodSummaryCardState extends State<FoodSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic);
    _ringCtrl.forward();
  }

  @override
  void didUpdateWidget(FoodSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-animate whenever calorie data changes
    if (oldWidget.total != widget.total || oldWidget.goal != widget.goal) {
      _ringCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calories = widget.calories;
    final total    = widget.total;
    final goal     = widget.goal;
    final waterMl  = widget.waterMl;
    final progress  = (total / goal).clamp(0.0, 1.0);
    final isOver    = total > goal;
    final remaining = isOver ? 0 : goal - total;
    final overBy    = isOver ? total - goal : 0;

    const waterGoal = 2500; // ml
    final waterProgress = (waterMl / waterGoal).clamp(0.0, 1.0);
    final glasses        = waterMl ~/ 250;
    final waterDone      = waterMl >= waterGoal;

    return Column(
      children: [
        // ── Calorie ring card ──────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOver
                  ? [const Color(0xFF3D1515), const Color(0xFF0F1624)]
                  : [const Color(0xFF1E3A5F), const Color(0xFF0F1624)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isOver
                  ? const Color(0xFFEF4444).withAlpha(100)
                  : Colors.white.withAlpha(20),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Animated progress ring
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 92,
                          height: 92,
                          child: AnimatedBuilder(
                            animation: _ringAnim,
                            builder: (_, __) => CircularProgressIndicator(
                              value: progress * _ringAnim.value,
                              strokeWidth: 10,
                              backgroundColor: Colors.white.withAlpha(18),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isOver ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isOver)
                              const Text('⚠️', style: TextStyle(fontSize: 18))
                            else
                              Text('$total',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900)),
                            Text(
                              isOver ? 'over!' : 'kcal',
                              style: TextStyle(
                                  color: isOver ? const Color(0xFFEF4444) : Colors.white54,
                                  fontSize: 10,
                                  fontWeight: isOver ? FontWeight.w700 : FontWeight.normal),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tappable goal row
                        GestureDetector(
                          onTap: widget.onEditGoal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withAlpha(25)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('🎯 Goal',
                                    style: TextStyle(color: Colors.white60, fontSize: 12)),
                                Row(
                                  children: [
                                    Text('$goal kcal',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit, color: Colors.white38, size: 11),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          label: 'Consumed',
                          value: '$total kcal',
                          color: const Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: 6),
                        _Row(
                          label: isOver ? 'Over by' : 'Remaining',
                          value: '${isOver ? overBy : remaining} kcal',
                          color: isOver ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Over-goal warning banner ─────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: isOver
                    ? Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withAlpha(28),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEF4444).withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        const Text('🚨', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You\'ve exceeded your daily goal by $overBy kcal. Consider lighter options next.',
                            style: const TextStyle(
                                color: Color(0xFFFF8080),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // ── Per-meal mini pills ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: allMealCategories.map((cat) => _MiniPill(
                  emoji: cat.emoji,
                  label: cat.label,
                  cal: calories[cat.id] ?? 0,
                  color: Color(cat.colorValue),
                )).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Water tracker card ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D2137),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: waterDone
                  ? const Color(0xFF22C55E).withAlpha(100)
                  : const Color(0xFF38BDF8).withAlpha(60),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('💧', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Water Intake',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          Text(
                            waterDone ? '✅ Daily goal reached!' : '$glasses / 10 glasses  •  $waterMl / $waterGoal ml',
                            style: TextStyle(
                                color: waterDone ? const Color(0xFF22C55E) : Colors.white38,
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onResetWater,
                    child: const Text('Reset',
                        style: TextStyle(color: Colors.white30, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: waterProgress),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 9,
                    backgroundColor: Colors.white.withAlpha(15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      waterDone ? const Color(0xFF22C55E) : const Color(0xFF38BDF8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Quick-add buttons
              Row(
                children: [
                  _WaterBtn(label: '+ 1 glass\n250 ml', ml: 250, onTap: () => widget.onAddWater(250)),
                  const SizedBox(width: 8),
                  _WaterBtn(label: '+ 500 ml', ml: 500, onTap: () => widget.onAddWater(500)),
                  const SizedBox(width: 8),
                  _WaterBtn(label: '+ 1 L', ml: 1000, onTap: () => widget.onAddWater(1000)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Internal helpers ───────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Row({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
    ],
  );
}

class _MiniPill extends StatelessWidget {
  final String emoji, label;
  final int cal;
  final Color color;
  const _MiniPill({required this.emoji, required this.label, required this.cal, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      const SizedBox(height: 2),
      Text('$cal', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    ],
  );
}

class _WaterBtn extends StatelessWidget {
  final String label;
  final int ml;
  final VoidCallback onTap;
  const _WaterBtn({required this.label, required this.ml, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF38BDF8).withAlpha(22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF38BDF8).withAlpha(70)),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.3)),
      ),
    ),
  );
}