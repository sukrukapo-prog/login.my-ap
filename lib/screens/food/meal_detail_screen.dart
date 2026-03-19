// lib/screens/food/meal_detail_screen.dart
// v4: Search bar + Manual Add Item button. No Goan badges.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Map<int, int>   _quantities    = {};
  final Set<int>        _selected      = {};
  Set<String>           _favourites    = {};
  int                   _selectedTotal = 0;
  int                   _savedTotal    = 0;
  List<Map<String, dynamic>> _log      = [];
  bool                  _justSaved     = false;

  // Search
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // Custom items added manually this session
  final List<_CustomItem> _customItems = [];

  late List<_IndexedItem> _sortedItems;
  List<_IndexedItem>      _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase().trim();
        _applyFilter();
      });
    });
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final saved = await FoodStorageService.getCalories(widget.category.id);
    final log   = await FoodStorageService.getLog(widget.category.id);
    final favs  = await FoodStorageService.getFavourites();
    if (!mounted) return;
    setState(() {
      _savedTotal = saved;
      _log        = log;
      _favourites = favs;
      _rebuildSorted();
    });
  }

  void _rebuildSorted() {
    final items = widget.category.items;
    final catId = widget.category.id;
    final favItems  = <_IndexedItem>[];
    final restItems = <_IndexedItem>[];
    for (int i = 0; i < items.length; i++) {
      final isFav = _favourites.contains('$catId::${items[i].name}');
      (isFav ? favItems : restItems).add(_IndexedItem(index: i, item: items[i], isCustom: false));
    }
    _sortedItems = [...favItems, ...restItems];
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_sortedItems);
    } else {
      _filteredItems = _sortedItems
          .where((e) => e.item.name.toLowerCase().contains(_searchQuery))
          .toList();
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
      final qty  = _quantities[idx] ?? 1;
      final cal  = item.calories * qty;
      await FoodStorageService.addCalories(widget.category.id, cal);
      await FoodStorageService.appendLog(widget.category.id, item.name, qty, cal);
    }
    await _load();
    setState(() {
      _selected.clear();
      _quantities.clear();
      _selectedTotal = 0;
      _justSaved     = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justSaved = false);
    });
  }

  Future<void> _clearLog() async {
    await FoodStorageService.clearMealLog(widget.category.id);
    _load();
  }

  Future<void> _toggleFav(String name) async {
    await FoodStorageService.toggleFavourite(widget.category.id, name);
    final favs = await FoodStorageService.getFavourites();
    if (!mounted) return;
    setState(() {
      _favourites = favs;
      _rebuildSorted();
    });
  }

  // ── Manual Add Item bottom sheet ──────────────────────────────────────────

  Future<void> _showManualAddSheet() async {
    final color = Color(widget.category.colorValue);
    final nameCtrl    = TextEditingController();
    final calCtrl     = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbsCtrl   = TextEditingController();
    final fatCtrl     = TextEditingController();
    final unitCtrl    = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          bool nameEmpty = false;
          bool calEmpty  = false;

          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: color.withAlpha(30),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.add_circle_outline, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Add Custom Item',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800)),
                          Text('to ${widget.category.label}',
                              style: TextStyle(color: color, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Food name
                  _SheetField(
                    label: 'Food Name *',
                    hint: 'e.g. Goan Xacuti',
                    controller: nameCtrl,
                    accentColor: color,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 12),

                  // Calories (required) + Unit (optional) side by side
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _SheetField(
                          label: 'Calories *',
                          hint: 'e.g. 250',
                          controller: calCtrl,
                          accentColor: color,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          suffix: 'kcal',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: _SheetField(
                          label: 'Unit (optional)',
                          hint: 'e.g. per bowl',
                          controller: unitCtrl,
                          accentColor: color,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Macros label
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8),
                    child: Row(
                      children: [
                        const Text('Macros',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('optional',
                              style: TextStyle(color: Colors.white38, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),

                  // Macros row
                  Row(
                    children: [
                      Expanded(
                        child: _SheetField(
                          label: 'Protein',
                          hint: '0',
                          controller: proteinCtrl,
                          accentColor: const Color(0xFF3B82F6),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          suffix: 'g',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SheetField(
                          label: 'Carbs',
                          hint: '0',
                          controller: carbsCtrl,
                          accentColor: const Color(0xFFF59E0B),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          suffix: 'g',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SheetField(
                          label: 'Fat',
                          hint: '0',
                          controller: fatCtrl,
                          accentColor: const Color(0xFFEF4444),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          suffix: 'g',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add to Log',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final cal  = int.tryParse(calCtrl.text.trim()) ?? 0;
                        if (name.isEmpty || cal <= 0) return;

                        final protein = double.tryParse(proteinCtrl.text.trim()) ?? 0.0;
                        final carbs   = double.tryParse(carbsCtrl.text.trim()) ?? 0.0;
                        final fat     = double.tryParse(fatCtrl.text.trim()) ?? 0.0;
                        final unit    = unitCtrl.text.trim().isEmpty ? null : unitCtrl.text.trim();

                        // Save directly to log (qty = 1)
                        await FoodStorageService.addCalories(widget.category.id, cal);
                        await FoodStorageService.appendLog(widget.category.id, name, 1, cal);

                        if (ctx.mounted) Navigator.pop(ctx);
                        await _load();
                        if (mounted) {
                          setState(() => _justSaved = true);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) setState(() => _justSaved = false);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );

    nameCtrl.dispose();
    calCtrl.dispose();
    proteinCtrl.dispose();
    carbsCtrl.dispose();
    fatCtrl.dispose();
    unitCtrl.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cat   = widget.category;
    final color = Color(cat.colorValue);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
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
                          color: Colors.white.withAlpha(15), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('${cat.emoji}  ${cat.label}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  if (_savedTotal > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withAlpha(60)),
                      ),
                      child: Text('$_savedTotal kcal today',
                          style: TextStyle(
                              color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),

            // ── Search bar + Add button ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withAlpha(20)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search, color: Colors.white38, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search ${cat.label.toLowerCase()}...',
                                hintStyle:
                                const TextStyle(color: Colors.white38, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _applyFilter();
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.close, color: Colors.white38, size: 16),
                              ),
                            )
                          else
                            const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // + Add custom button
                  GestureDetector(
                    onTap: _showManualAddSheet,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color.withAlpha(80)),
                      ),
                      child: Icon(Icons.add, color: color, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Row(
                children: [
                  Text(
                    _searchQuery.isEmpty
                        ? '${_filteredItems.length} items'
                        : '${_filteredItems.length} result${_filteredItems.length == 1 ? '' : 's'}',
                    style: TextStyle(color: Colors.white.withAlpha(60), fontSize: 11),
                  ),
                  const Spacer(),
                  if (_sortedItems.any(
                          (e) => _favourites.contains('${cat.id}::${e.item.name}')))
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Color(0xFFEF4444), size: 12),
                        const SizedBox(width: 4),
                        Text('Favourites pinned',
                            style: TextStyle(
                                color: Colors.white.withAlpha(60), fontSize: 11)),
                      ],
                    ),
                ],
              ),
            ),

            // ── Saved banner ─────────────────────────────────────────────
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
                  border:
                  Border.all(color: const Color(0xFF22C55E).withAlpha(80)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: Color(0xFF22C55E), size: 18),
                    SizedBox(width: 8),
                    Text('Calories saved ✅',
                        style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),

            // ── Empty search state ────────────────────────────────────────
            if (_filteredItems.isEmpty && _searchQuery.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off, color: Colors.white24, size: 48),
                      const SizedBox(height: 12),
                      Text('No items found for "$_searchQuery"',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text('Tap  +  to add it manually',
                          style: TextStyle(
                              color: Colors.white.withAlpha(40), fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, si) {
                    final entry = _filteredItems[si];
                    final i     = entry.index;
                    final isFav =
                    _favourites.contains('${cat.id}::${entry.item.name}');
                    return FoodItemTile(
                      item: entry.item,
                      isSelected: _selected.contains(i),
                      quantity: _quantities[i] ?? 1,
                      accentColor: color,
                      isFavourite: isFav,
                      onFavouriteToggle: () => _toggleFav(entry.item.name),
                      onToggle: (val) {
                        setState(
                                () => val ? _selected.add(i) : _selected.remove(i));
                        _recalculate();
                      },
                      onQtyChanged: (q) {
                        setState(() => _quantities[i] = q);
                        _recalculate();
                      },
                    );
                  },
                ),
              ),

            // ── Log strip ────────────────────────────────────────────────
            if (_log.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's log",
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    GestureDetector(
                      onTap: _clearLog,
                      child: const Text('Clear',
                          style: TextStyle(
                              color: Color(0xFFEF4444), fontSize: 12)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _log.length,
                  itemBuilder: (_, i) {
                    final e = _log[i];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withAlpha(60)),
                      ),
                      child: Text(
                        '${e['name']} ×${e['qty']} = ${e['cal']} kcal',
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

            // ── Bottom bar ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selected: $_selectedTotal kcal',
                            style: TextStyle(
                                color: _selected.isEmpty
                                    ? Colors.white38
                                    : color,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        if (_savedTotal > 0)
                          Text('Total today: $_savedTotal kcal',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11)),
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
                      disabledBackgroundColor: Colors.white.withAlpha(20),
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

// ── Sheet input field widget ──────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Color accentColor;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffix;

  const _SheetField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.accentColor,
    required this.keyboardType,
    this.inputFormatters,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            suffixText: suffix,
            suffixStyle: TextStyle(color: accentColor.withAlpha(180), fontSize: 12),
            filled: true,
            fillColor: Colors.white.withAlpha(8),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withAlpha(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withAlpha(20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Internal types ────────────────────────────────────────────────────────────

class _IndexedItem {
  final int      index;
  final FoodItem item;
  final bool     isCustom;
  _IndexedItem({required this.index, required this.item, required this.isCustom});
}

class _CustomItem {
  final String name;
  final int    calories;
  _CustomItem({required this.name, required this.calories});
}
