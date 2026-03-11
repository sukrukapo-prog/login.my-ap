// lib/screens/food/widgets/food_item_tile.dart
//
// Single selectable food item row used inside MealDetailScreen.
// Shows image, name, unit, calories × qty, and a qty stepper when selected.

import 'package:flutter/material.dart';
import 'package:fitmetrics/models/food_item.dart';
import 'package:fitmetrics/constants/colors.dart';

class FoodItemTile extends StatelessWidget {
  final FoodItem item;
  final bool isSelected;
  final int quantity;
  final Color accentColor;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onQtyChanged;

  const FoodItemTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.quantity,
    required this.accentColor,
    required this.onToggle,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayCal = item.calories * quantity;

    return GestureDetector(
      onTap: () => onToggle(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withAlpha(25) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor.withAlpha(120)
                : Colors.white.withAlpha(15),
          ),
        ),
        child: Row(
          children: [
            // Food image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.imagePath,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.fastfood,
                      color: accentColor.withAlpha(150), size: 28),
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
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  if (item.unit != null)
                    Text(item.unit!,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    '$displayCal kcal',
                    style: TextStyle(
                        color: accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            // Qty stepper (visible only when selected)
            if (isSelected) ...[
              _QtyStepper(
                qty: quantity,
                color: accentColor,
                onDecrement:
                quantity > 1 ? () => onQtyChanged(quantity - 1) : null,
                onIncrement: () => onQtyChanged(quantity + 1),
              ),
              const SizedBox(width: 8),
            ],
            // Checkbox circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : Colors.white38,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Qty stepper ───────────────────────────────────────────────────────────────

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

  Widget _btn(IconData icon, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: onTap != null
            ? color.withAlpha(40)
            : Colors.white.withAlpha(10),
        shape: BoxShape.circle,
      ),
      child: Icon(icon,
          color: onTap != null ? color : Colors.white24, size: 14),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(Icons.remove, onDecrement),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '$qty',
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
        _btn(Icons.add, onIncrement),
      ],
    );
  }
}