// lib/screens/food/widgets/food_category_card.dart
//
// Tappable card shown in the FoodScreen category list.
// Shows banner image, emoji, item count, and logged calories.

import 'package:flutter/material.dart';
import 'package:fitmetrics/models/food_item.dart';
import 'package:fitmetrics/constants/colors.dart';

class FoodCategoryCard extends StatelessWidget {
  final MealCategory category;
  final int loggedCalories;
  final VoidCallback onTap;

  const FoodCategoryCard({
    super.key,
    required this.category,
    required this.loggedCalories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Right-side banner image
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 130,
                child: Image.asset(
                  category.bannerImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: color.withAlpha(40),
                    child: Icon(Icons.restaurant,
                        color: color.withAlpha(120), size: 40),
                  ),
                ),
              ),
              // Left-to-right gradient overlay (hides image edge)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 130,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [AppColors.surface, AppColors.surface.withAlpha(0)],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14 ),
                child: Row(
                  children: [
                    // Emoji circle
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withAlpha(80)),
                      ),
                      child: Center(
                          child: Text(category.emoji,
                              style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    // Text block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.label,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${category.items.length} items',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          loggedCalories > 0
                              ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$loggedCalories kcal logged',
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          )
                              : const Text(
                            'Tap to log',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: color.withAlpha(180), size: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}