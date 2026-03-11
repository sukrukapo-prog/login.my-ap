// lib/screens/food/food_screen.dart
//
// Entry point for the Food tab.
// Replaces the old "Coming soon" stub in main_tab_screen.dart.
// No new routes needed — MealDetailScreen is pushed inline.

import 'package:flutter/material.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await FoodStorageService.getAllCalories();
    if (mounted) {
      setState(() {
        _calories = data;
        _loading = false;
      });
    }
  }

  int get _total => _calories.values.fold(0, (a, b) => a + b);

  Future<void> _confirmReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Day?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text(
          'This will clear all food calories and logs for today.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset',
                style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FoodStorageService.resetAll();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1624),
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
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
              // ── Header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Food Tracker',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900),
                              ),
                              Text(
                                'Log your meals & calories',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 13),
                              ),
                            ],
                          ),
                          // Reset button
                          GestureDetector(
                            onTap: _confirmReset,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                const Color(0xFFEF4444).withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFEF4444)
                                        .withAlpha(80)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.refresh,
                                      color: Color(0xFFEF4444), size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Reset',
                                    style: TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Daily summary ring
                      FoodSummaryCard(calories: _calories, total: _total),
                      const SizedBox(height: 24),
                      const Text(
                        'Meal Categories',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // ── Category cards ───────────────────────────────────────
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
                                builder: (_) =>
                                    MealDetailScreen(category: cat),
                              ),
                            );
                            _load(); // refresh after returning
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