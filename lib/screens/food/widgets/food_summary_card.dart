// lib/screens/food/widgets/food_summary_card.dart
//
// Shows the daily calorie progress ring + per-meal mini breakdown.
// Used at the top of FoodScreen.

import 'package:flutter/material.dart';
import 'package:fitmetrics/models/food_item.dart';

const int kDailyCalorieGoal = 2000;

class FoodSummaryCard extends StatelessWidget {
  final Map<String, int> calories; // mealId → kcal
  final int total;

  const FoodSummaryCard({
    super.key,
    required this.calories,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (total / kDailyCalorieGoal).clamp(0.0, 1.0);
    final remaining = (kDailyCalorieGoal - total).clamp(0, kDailyCalorieGoal);
    final isOver = total > kDailyCalorieGoal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF0F1624)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Progress ring
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withAlpha(20),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOver
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'kcal',
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Stats column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(
                      label: 'Goal',
                      value: '$kDailyCalorieGoal kcal',
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Consumed',
                      value: '$total kcal',
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: isOver ? 'Over by' : 'Remaining',
                      value: '${isOver ? total - kDailyCalorieGoal : remaining} kcal',
                      color: isOver
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF22C55E),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Per-meal mini bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: allMealCategories.map((cat) {
              return _MiniMealPill(
                emoji: cat.emoji,
                label: cat.label,
                cal: calories[cat.id] ?? 0,
                color: Color(cat.colorValue),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _MiniMealPill extends StatelessWidget {
  final String emoji, label;
  final int cal;
  final Color color;
  const _MiniMealPill(
      {required this.emoji,
        required this.label,
        required this.cal,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 9)),
        const SizedBox(height: 2),
        Text('$cal',
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}