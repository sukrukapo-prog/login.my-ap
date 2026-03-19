// lib/screens/food/widgets/food_item_tile.dart
// v4: Goan badges fully removed. Clean tile with macros + favourite heart.

import 'package:flutter/material.dart';
import 'package:fitmetrics/models/food_item.dart';
import 'package:fitmetrics/constants/colors.dart';

class FoodItemTile extends StatelessWidget {
  final FoodItem item;
  final bool isSelected;
  final int quantity;
  final Color accentColor;
  final bool isFavourite;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onFavouriteToggle;

  const FoodItemTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.quantity,
    required this.accentColor,
    required this.isFavourite,
    required this.onToggle,
    required this.onQtyChanged,
    required this.onFavouriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final displayCal = item.calories * quantity;
    final m = item.macros * quantity;

    return GestureDetector(
      onTap: () => onToggle(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withAlpha(25) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor.withAlpha(120) : Colors.white.withAlpha(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Food image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    item.imagePath,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: accentColor.withAlpha(40),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.fastfood, color: accentColor.withAlpha(150), size: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name / unit / calories
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      if (item.unit != null)
                        Text(item.unit!,
                            style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      const SizedBox(height: 3),
                      Text('$displayCal kcal',
                          style: TextStyle(
                              color: accentColor, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),

                // ❤️ Favourite
                GestureDetector(
                  onTap: onFavouriteToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isFavourite ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFavourite),
                        color: isFavourite ? const Color(0xFFEF4444) : Colors.white30,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Qty stepper (only when selected)
                if (isSelected) ...[
                  _QtyStepper(
                    qty: quantity,
                    color: accentColor,
                    onDecrement: quantity > 1 ? () => onQtyChanged(quantity - 1) : null,
                    onIncrement: () => onQtyChanged(quantity + 1),
                  ),
                  const SizedBox(width: 8),
                ],

                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected ? accentColor : Colors.white38, width: 2),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),

            // Macros row
            const SizedBox(height: 8),
            Row(
              children: [
                _MacroPill(label: 'P', value: m.protein, color: const Color(0xFF3B82F6)),
                const SizedBox(width: 6),
                _MacroPill(label: 'C', value: m.carbs,   color: const Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                _MacroPill(label: 'F', value: m.fat,     color: const Color(0xFFEF4444)),
                const Spacer(),
                if (quantity > 1)
                  Text('× $quantity',
                      style: TextStyle(
                          color: accentColor.withAlpha(180),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MacroPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withAlpha(22),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withAlpha(60)),
    ),
    child: Text('$label ${value.toStringAsFixed(1)}g',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final Color color;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _QtyStepper({
    required this.qty,
    required this.color,
    required this.onDecrement,
    required this.onIncrement,
  });

  Widget _btn(IconData icon, VoidCallback? fn) => GestureDetector(
    onTap: fn,
    child: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: fn != null ? color.withAlpha(40) : Colors.white.withAlpha(10),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: fn != null ? color : Colors.white24, size: 14),
    ),
  );

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _btn(Icons.remove, onDecrement),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('$qty',
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
      ),
      _btn(Icons.add, onIncrement),
    ],
  );
}
