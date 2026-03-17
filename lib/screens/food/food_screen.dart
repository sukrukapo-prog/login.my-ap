// lib/screens/food/food_screen.dart
// v2: loads calorie goal + water; goal editable via bottom-sheet dialog.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitmetrics/models/food_item.dart';
import 'package:fitmetrics/services/food_storage_service.dart';
import 'package:fitmetrics/screens/food/meal_detail_screen.dart';
import 'package:fitmetrics/screens/food/widgets/food_summary_card.dart';
import 'package:fitmetrics/screens/food/widgets/food_category_card.dart';
import 'package:fitmetrics/constants/colors.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  Map<String, int> _calories = {};
  int  _goal    = 2000;
  int  _waterMl = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await FoodStorageService.checkAndResetIfNewDay();
    final data  = await FoodStorageService.getAllCalories();
    final goal  = await FoodStorageService.getCalorieGoal();
    final water = await FoodStorageService.getWaterMl();
    if (mounted) {
      setState(() {
        _calories = data;
        _goal     = goal;
        _waterMl  = water;
        _loading  = false;
      });
    }
  }

  int get _total => _calories.values.fold(0, (a, b) => a + b);

  // ── Goal editor dialog ────────────────────────────────────────────────────────

  Future<void> _editGoal() async {
    final ctrl = TextEditingController(text: '$_goal');
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎯 Set Daily Calorie Goal',
                style: TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Your goal will be used across the food tracker.',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '2000',
                hintStyle: const TextStyle(color: Colors.white30),
                suffixText: 'kcal',
                suffixStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withAlpha(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withAlpha(40)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withAlpha(40)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Preset quick-picks
            Wrap(
              spacing: 8,
              children: [1200, 1500, 1800, 2000, 2200, 2500].map((v) {
                return GestureDetector(
                  onTap: () => ctrl.text = '$v',
                  child: Chip(
                    label: Text('$v',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    backgroundColor: Colors.white.withAlpha(15),
                    side: BorderSide(color: Colors.white.withAlpha(30)),
                    padding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () async {
                  final val = int.tryParse(ctrl.text.trim()) ?? 2000;
                  await FoodStorageService.setCalorieGoal(val);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                },
                child: const Text('Save Goal',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Water helpers ─────────────────────────────────────────────────────────────

  Future<void> _addWater(int ml) async {
    await FoodStorageService.addWaterMl(ml);
    final w = await FoodStorageService.getWaterMl();
    if (mounted) setState(() => _waterMl = w);
  }

  Future<void> _resetWater() async {
    await FoodStorageService.resetWater();
    if (mounted) setState(() => _waterMl = 0);
  }

  // ── Reset day ─────────────────────────────────────────────────────────────────

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Day?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text(
          'This clears all food calories, logs, and water for today.\nYour calorie goal and favourites are kept.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset',
                  style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok == true) {
      await FoodStorageService.resetAll();
      _load();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1624),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF3B82F6),
          backgroundColor: AppColors.surface,
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Food Tracker',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900)),
                              Text('Log your meals & calories',
                                  style: TextStyle(color: Colors.white54, fontSize: 13)),
                            ],
                          ),
                          GestureDetector(
                            onTap: _confirmReset,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFEF4444).withAlpha(80)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.refresh, color: Color(0xFFEF4444), size: 16),
                                  SizedBox(width: 4),
                                  Text('Reset',
                                      style: TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Summary + water card
                      FoodSummaryCard(
                        calories: _calories,
                        total: _total,
                        goal: _goal,
                        waterMl: _waterMl,
                        onEditGoal: _editGoal,
                        onAddWater: _addWater,
                        onResetWater: _resetWater,
                      ),

                      const SizedBox(height: 24),
                      const Text('Meal Categories',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // Category cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final cat = allMealCategories[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: FoodCategoryCard(
                          category: cat,
                          loggedCalories: _calories[cat.id] ?? 0,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MealDetailScreen(category: cat)),
                            );
                            _load();
                          },
                        ),
                      );
                    },
                    childCount: allMealCategories.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}