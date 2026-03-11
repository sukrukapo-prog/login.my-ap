// lib/screens/food/meal_detail_screen.dart
//
// Pushed from FoodScreen when user taps a category card.
// Lets user select items, set quantity, and save to SharedPreferences.

import 'package:flutter/material.dart';
import 'package:fitmetrics/models/food_item.dart';
import 'package:fitmetrics/services/food_storage_service.dart';
import 'package:fitmetrics/screens/food/widgets/food_item_tile.dart';
import 'package:fitmetrics/constants/colors.dart';

class MealDetailScreen extends StatefulWidget {
  final MealCategory category;
  const MealDetailScreen({super.key, required this.category});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final Map<int, int> _quantities = {};   // item index → qty
  final Set<int> _selected = {};           // selected item indices
  int _selectedTotal = 0;
  int _savedTotal = 0;
  List<Map<String, dynamic>> _log = [];
  bool _justSaved = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await FoodStorageService.getCalories(widget.category.id);
    final log = await FoodStorageService.getLog(widget.category.id);
    if (mounted) {
      setState(() {
        _savedTotal = saved;
        _log = log;
      });
    }
  }

  void _recalculate() {
    int total = 0;
    for (final idx in _selected) {
      total += widget.category.items[idx].calories * (_quantities[idx] ?? 1);
    }
    setState(() => _selectedTotal = total);
  }

  Future<void> _saveSelected() async {
    if (_selected.isEmpty) return;

    for (final idx in _selected) {
      final item = widget.category.items[idx];
      final qty = _quantities[idx] ?? 1;
      final cal = item.calories * qty;
      await FoodStorageService.addCalories(widget.category.id, cal);
      await FoodStorageService.appendLog(widget.category.id, item.name, qty, cal);
    }

    await _loadSaved();

    setState(() {
      _selected.clear();
      _quantities.clear();
      _selectedTotal = 0;
      _justSaved = true;
    });

    Future.delayed(
        const Duration(seconds: 2), () => setState(() => _justSaved = false));
  }

  Future<void> _clearLog() async {
    await FoodStorageService.clearMealLog(widget.category.id);
    _loadSaved();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final color = Color(cat.colorValue);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${cat.emoji}  ${cat.label}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  if (_savedTotal > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withAlpha(60)),
                      ),
                      child: Text(
                        '$_savedTotal kcal today',
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),

            // ── Saved confirmation banner ──────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _justSaved
                  ? Container(
                key: const ValueKey('saved'),
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF22C55E).withAlpha(80)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: Color(0xFF22C55E), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Calories saved ✅',
                      style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),

            // ── Food item list ─────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: cat.items.length,
                itemBuilder: (context, i) {
                  return FoodItemTile(
                    item: cat.items[i],
                    isSelected: _selected.contains(i),
                    quantity: _quantities[i] ?? 1,
                    accentColor: color,
                    onToggle: (val) {
                      setState(() {
                        val ? _selected.add(i) : _selected.remove(i);
                      });
                      _recalculate();
                    },
                    onQtyChanged: (newQty) {
                      setState(() => _quantities[i] = newQty);
                      _recalculate();
                    },
                  );
                },
              ),
            ),

            // ── Today's log strip ──────────────────────────────────────
            if (_log.isNotEmpty) ...[
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's log",
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: _clearLog,
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                            color: Color(0xFFEF4444), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _log.length,
                  itemBuilder: (_, i) {
                    final entry = _log[i];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                        border:
                        Border.all(color: color.withAlpha(60)),
                      ),
                      child: Text(
                        '${entry['name']} ×${entry['qty']} = ${entry['cal']} kcal',
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
            ],

            // ── Bottom action bar ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border:
                Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected: $_selectedTotal kcal',
                          style: TextStyle(
                              color: _selected.isEmpty
                                  ? Colors.white38
                                  : color,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        if (_savedTotal > 0)
                          Text(
                            'Total today: $_savedTotal kcal',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _selected.isEmpty ? null : _saveSelected,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selected.isEmpty
                          ? Colors.white.withAlpha(20)
                          : color,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      Colors.white.withAlpha(20),
                      disabledForegroundColor: Colors.white38,
                      minimumSize: const Size(140, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add & Save',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}