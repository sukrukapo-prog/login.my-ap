// lib/models/food_item.dart
// Pure Dart — no Flutter imports.
// v2: added FoodMacros (protein / carbs / fat per base serving)

class FoodMacros {
  final double protein; // grams
  final double carbs;   // grams
  final double fat;     // grams

  const FoodMacros({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  /// Scale macros by quantity
  FoodMacros operator *(int qty) => FoodMacros(
    protein: protein * qty,
    carbs: carbs * qty,
    fat: fat * qty,
  );
}

class FoodItem {
  final String name;
  final int calories;
  final String imagePath;
  final String? unit;
  final FoodMacros macros;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.imagePath,
    required this.macros,
    this.unit,
  });
}

class MealCategory {
  final String id;
  final String label;
  final String emoji;
  final int colorValue;
  final String bannerImage;
  final List<FoodItem> items;

  const MealCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.colorValue,
    required this.bannerImage,
    required this.items,
  });
}

// ── Meal data ─────────────────────────────────────────────────────────────────

const MealCategory breakfastCategory = MealCategory(
  id: 'breakfast',
  label: 'Breakfast',
  emoji: '☀️',
  colorValue: 0xFFF59E0B,
  bannerImage: 'assets/images/food/breakfast_banner.jpg',
  items: [
    FoodItem(name: 'Idli',         calories: 60,  imagePath: 'assets/images/food/breakfast/idli.webp',        unit: 'per piece', macros: FoodMacros(protein: 2.0, carbs: 12.0, fat: 0.4)),
    FoodItem(name: 'Chapati',      calories: 104, imagePath: 'assets/images/food/breakfast/chapati.jpg',      unit: 'per piece', macros: FoodMacros(protein: 3.1, carbs: 18.0, fat: 2.5)),
    FoodItem(name: 'Poha',         calories: 192, imagePath: 'assets/images/food/breakfast/poha.jpg',         unit: 'per bowl',  macros: FoodMacros(protein: 3.5, carbs: 38.0, fat: 3.8)),
    FoodItem(name: 'Samosa',       calories: 262, imagePath: 'assets/images/food/breakfast/samosa.webp',      unit: 'per piece', macros: FoodMacros(protein: 4.2, carbs: 30.0, fat: 14.0)),
    FoodItem(name: 'Patties',      calories: 312, imagePath: 'assets/images/food/breakfast/patties.jpg',      unit: 'per piece', macros: FoodMacros(protein: 14.0, carbs: 22.0, fat: 18.0)),
    FoodItem(name: 'Medu Vada',    calories: 146, imagePath: 'assets/images/food/breakfast/medu_vada.webp',   unit: 'per piece', macros: FoodMacros(protein: 5.0, carbs: 16.0, fat: 7.0)),
    FoodItem(name: 'Mirchi Bajji', calories: 152, imagePath: 'assets/images/food/breakfast/mirchi_bajji.jpg', unit: 'per piece', macros: FoodMacros(protein: 3.0, carbs: 18.0, fat: 7.5)),
  ],
);

const MealCategory lunchCategory = MealCategory(
  id: 'lunch',
  label: 'Lunch',
  emoji: '🍛',
  colorValue: 0xFF10B981,
  bannerImage: 'assets/images/food/lunch_banner.jpg',
  items: [
    FoodItem(name: 'Rajma',         calories: 130, imagePath: 'assets/images/food/lunch/rajma.jpg',         unit: 'per 100 g', macros: FoodMacros(protein: 8.7, carbs: 22.0, fat: 0.5)),
    FoodItem(name: 'Toor Dal',      calories: 115, imagePath: 'assets/images/food/lunch/toor_dal.jpg',      unit: 'per bowl',  macros: FoodMacros(protein: 7.2, carbs: 20.0, fat: 0.4)),
    FoodItem(name: 'Basmati Rice',  calories: 160, imagePath: 'assets/images/food/lunch/basmati_rice.webp', unit: 'per bowl',  macros: FoodMacros(protein: 3.0, carbs: 35.0, fat: 0.4)),
    FoodItem(name: 'Paratha',       calories: 200, imagePath: 'assets/images/food/lunch/paratha.webp',      unit: 'per piece', macros: FoodMacros(protein: 4.0, carbs: 28.0, fat: 8.0)),
    FoodItem(name: 'Puri',          calories: 130, imagePath: 'assets/images/food/lunch/puri.webp',         unit: 'per piece', macros: FoodMacros(protein: 2.5, carbs: 17.0, fat: 6.0)),
    FoodItem(name: 'Mutton Curry',  calories: 243, imagePath: 'assets/images/food/lunch/mutton_curry.jpg',  unit: 'per 100 g', macros: FoodMacros(protein: 18.0, carbs: 6.0, fat: 16.0)),
    FoodItem(name: 'Shrimp Masala', calories: 120, imagePath: 'assets/images/food/lunch/shrimp_masala.jpg', unit: 'per 100 g', macros: FoodMacros(protein: 16.0, carbs: 5.0, fat: 4.0)),
  ],
);

const MealCategory dinnerCategory = MealCategory(
  id: 'dinner',
  label: 'Dinner',
  emoji: '🍲',
  colorValue: 0xFF8B5CF6,
  bannerImage: 'assets/images/food/dinner_banner.jpg',
  items: [
    FoodItem(name: 'Idli',          calories: 60,  imagePath: 'assets/images/food/breakfast/idli.webp',      unit: 'per piece', macros: FoodMacros(protein: 2.0, carbs: 12.0, fat: 0.4)),
    FoodItem(name: 'Rajma',         calories: 130, imagePath: 'assets/images/food/lunch/rajma.jpg',          unit: 'per 100 g', macros: FoodMacros(protein: 8.7, carbs: 22.0, fat: 0.5)),
    FoodItem(name: 'Fish Curry',    calories: 175, imagePath: 'assets/images/food/dinner/fish_curry.webp',   unit: 'per 100 g', macros: FoodMacros(protein: 20.0, carbs: 4.0, fat: 8.0)),
    FoodItem(name: 'Chicken Curry', calories: 200, imagePath: 'assets/images/food/dinner/chicken_curry.jpg', unit: 'per 100 g', macros: FoodMacros(protein: 22.0, carbs: 5.0, fat: 10.0)),
    FoodItem(name: 'Veg Salad',     calories: 50,  imagePath: 'assets/images/food/dinner/veg_salad.jpg',     unit: 'per bowl',  macros: FoodMacros(protein: 2.0, carbs: 8.0, fat: 1.0)),
    FoodItem(name: 'Curd',          calories: 98,  imagePath: 'assets/images/food/dinner/curd.jpg',          unit: 'per 100 g', macros: FoodMacros(protein: 3.4, carbs: 4.7, fat: 4.3)),
  ],
);

const MealCategory drinksCategory = MealCategory(
  id: 'drinks',
  label: 'Drinks',
  emoji: '🥤',
  colorValue: 0xFF3B82F6,
  bannerImage: 'assets/images/food/drinks_banner.jpg',
  items: [
    FoodItem(name: 'Lemon Soda',      calories: 150, imagePath: 'assets/images/food/drinks/lemon_soda.jpeg',     unit: 'per glass',  macros: FoodMacros(protein: 0.2, carbs: 38.0, fat: 0.0)),
    FoodItem(name: 'Apple Juice',     calories: 115, imagePath: 'assets/images/food/drinks/apple_juice.jpg',     unit: 'per 200 ml', macros: FoodMacros(protein: 0.4, carbs: 28.0, fat: 0.2)),
    FoodItem(name: 'Pineapple Juice', calories: 130, imagePath: 'assets/images/food/drinks/pineapple_juice.jpg', unit: 'per 200 ml', macros: FoodMacros(protein: 0.5, carbs: 32.0, fat: 0.1)),
    FoodItem(name: 'Mango Juice',     calories: 90,  imagePath: 'assets/images/food/drinks/mango_juice.jpg',     unit: 'per 200 ml', macros: FoodMacros(protein: 0.5, carbs: 22.0, fat: 0.2)),
    FoodItem(name: 'Sprite',          calories: 150, imagePath: 'assets/images/food/drinks/sprite.webp',         unit: 'per can',    macros: FoodMacros(protein: 0.0, carbs: 39.0, fat: 0.0)),
    FoodItem(name: '7 Up',            calories: 150, imagePath: 'assets/images/food/drinks/7up.webp',            unit: 'per can',    macros: FoodMacros(protein: 0.0, carbs: 39.0, fat: 0.0)),
    FoodItem(name: 'Fanta',           calories: 150, imagePath: 'assets/images/food/drinks/fanta.jpg',           unit: 'per can',    macros: FoodMacros(protein: 0.0, carbs: 40.0, fat: 0.0)),
    FoodItem(name: 'Tea',             calories: 120, imagePath: 'assets/images/food/drinks/tea.webp',            unit: 'per cup',    macros: FoodMacros(protein: 1.5, carbs: 22.0, fat: 3.5)),
    FoodItem(name: 'Green Tea',       calories: 2,   imagePath: 'assets/images/food/drinks/green_tea.jpg',       unit: 'per cup',    macros: FoodMacros(protein: 0.2, carbs: 0.4, fat: 0.0)),
    FoodItem(name: 'Black Tea',       calories: 2,   imagePath: 'assets/images/food/drinks/black_tea.jpg',       unit: 'per cup',    macros: FoodMacros(protein: 0.1, carbs: 0.3, fat: 0.0)),
    FoodItem(name: 'Coffee',          calories: 120, imagePath: 'assets/images/food/drinks/coffee.webp',         unit: 'per cup',    macros: FoodMacros(protein: 2.0, carbs: 18.0, fat: 4.5)),
    FoodItem(name: 'Coconut Water',   calories: 45,  imagePath: 'assets/images/food/drinks/coconut_water.webp',  unit: 'per 200 ml', macros: FoodMacros(protein: 0.4, carbs: 9.0, fat: 0.2)),
    FoodItem(name: 'Lassi',           calories: 160, imagePath: 'assets/images/food/drinks/lassi.webp',          unit: 'per glass',  macros: FoodMacros(protein: 5.0, carbs: 22.0, fat: 6.0)),
  ],
);

const MealCategory fruitsCategory = MealCategory(
  id: 'fruits',
  label: 'Fruits',
  emoji: '🍎',
  colorValue: 0xFFEC4899,
  bannerImage: 'assets/images/food/fruits_banner.jpg',
  items: [
    FoodItem(name: 'Apple',        calories: 52, imagePath: 'assets/images/food/fruits/apple.jpg',      unit: 'per 100 g', macros: FoodMacros(protein: 0.3, carbs: 14.0, fat: 0.2)),
    FoodItem(name: 'Mango',        calories: 60, imagePath: 'assets/images/food/fruits/mango.webp',     unit: 'per 100 g', macros: FoodMacros(protein: 0.8, carbs: 15.0, fat: 0.4)),
    FoodItem(name: 'Chiku',        calories: 83, imagePath: 'assets/images/food/fruits/chiku.webp',     unit: 'per 100 g', macros: FoodMacros(protein: 0.4, carbs: 20.0, fat: 1.1)),
    FoodItem(name: 'Pineapple',    calories: 50, imagePath: 'assets/images/food/fruits/pineapple.jpg',  unit: 'per 100 g', macros: FoodMacros(protein: 0.5, carbs: 13.0, fat: 0.1)),
    FoodItem(name: 'Mixed Fruits', calories: 65, imagePath: 'assets/images/food/fruits/mixed_fruit.jpg',unit: 'per bowl',  macros: FoodMacros(protein: 0.7, carbs: 16.0, fat: 0.3)),
  ],
);

const List<MealCategory> allMealCategories = [
  breakfastCategory,
  lunchCategory,
  dinnerCategory,
  drinksCategory,
  fruitsCategory,
];
