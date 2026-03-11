// lib/models/food_item.dart
// Data models for the Food section.
// No dependencies on Flutter — pure Dart.

class FoodItem {
  final String name;
  final int calories;
  final String imagePath;
  final String? unit;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.imagePath,
    this.unit,
  });
}

class MealCategory {
  final String id;       // used as SharedPreferences key suffix
  final String label;
  final String emoji;
  final int colorValue;  // stored as int so this file stays Flutter-free
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

// ── All meal data ──────────────────────────────────────────────────────────────

const MealCategory breakfastCategory = MealCategory(
  id: 'breakfast',
  label: 'Breakfast',
  emoji: '☀️',
  colorValue: 0xFFF59E0B,
  bannerImage: 'assets/images/food/breakfast_banner.jpg',
  items: [
    FoodItem(name: 'Idli',         calories: 60,  imagePath: 'assets/images/food/breakfast/idli.webp',        unit: 'per piece'),
    FoodItem(name: 'Chapati',      calories: 104, imagePath: 'assets/images/food/breakfast/chapati.jpg',      unit: 'per piece'),
    FoodItem(name: 'Poha',         calories: 192, imagePath: 'assets/images/food/breakfast/poha.jpg',         unit: 'per bowl'),
    FoodItem(name: 'Samosa',       calories: 262, imagePath: 'assets/images/food/breakfast/samosa.webp',      unit: 'per piece'),
    FoodItem(name: 'Patties',      calories: 312, imagePath: 'assets/images/food/breakfast/patties.jpg',      unit: 'per piece'),
    FoodItem(name: 'Medu Vada',    calories: 146, imagePath: 'assets/images/food/breakfast/medu_vada.webp',   unit: 'per piece'),
    FoodItem(name: 'Mirchi Bajji', calories: 152, imagePath: 'assets/images/food/breakfast/mirchi_bajji.jpg', unit: 'per piece'),
  ],
);

const MealCategory lunchCategory = MealCategory(
  id: 'lunch',
  label: 'Lunch',
  emoji: '🍛',
  colorValue: 0xFF10B981,
  bannerImage: 'assets/images/food/lunch_banner.jpg',
  items: [
    FoodItem(name: 'Rajma',          calories: 130, imagePath: 'assets/images/food/lunch/rajma.jpg',         unit: 'per 100 g'),
    FoodItem(name: 'Toor Dal',       calories: 115, imagePath: 'assets/images/food/lunch/toor_dal.jpg',      unit: 'per bowl'),
    FoodItem(name: 'Basmati Rice',   calories: 160, imagePath: 'assets/images/food/lunch/basmati_rice.webp', unit: 'per bowl'),
    FoodItem(name: 'Paratha',        calories: 200, imagePath: 'assets/images/food/lunch/paratha.webp',      unit: 'per piece'),
    FoodItem(name: 'Puri',           calories: 130, imagePath: 'assets/images/food/lunch/puri.webp',         unit: 'per piece'),
    FoodItem(name: 'Mutton Curry',   calories: 243, imagePath: 'assets/images/food/lunch/mutton_curry.jpg',  unit: 'per 100 g'),
    FoodItem(name: 'Shrimp Masala',  calories: 120, imagePath: 'assets/images/food/lunch/shrimp_masala.jpg', unit: 'per 100 g'),
  ],
);

const MealCategory dinnerCategory = MealCategory(
  id: 'dinner',
  label: 'Dinner',
  emoji: '🍲',
  colorValue: 0xFF8B5CF6,
  bannerImage: 'assets/images/food/dinner_banner.jpg',
  items: [
    FoodItem(name: 'Idli',          calories: 60,  imagePath: 'assets/images/food/breakfast/idli.webp',       unit: 'per piece'),
    FoodItem(name: 'Rajma',         calories: 130, imagePath: 'assets/images/food/lunch/rajma.jpg',           unit: 'per 100 g'),
    FoodItem(name: 'Fish Curry',    calories: 175, imagePath: 'assets/images/food/dinner/fish_curry.webp',    unit: 'per 100 g'),
    FoodItem(name: 'Chicken Curry', calories: 200, imagePath: 'assets/images/food/dinner/chicken_curry.jpg',  unit: 'per 100 g'),
    FoodItem(name: 'Veg Salad',     calories: 50,  imagePath: 'assets/images/food/dinner/veg_salad.jpg',      unit: 'per bowl'),
    FoodItem(name: 'Curd',          calories: 98,  imagePath: 'assets/images/food/dinner/curd.jpg',           unit: 'per 100 g'),
  ],
);

const MealCategory drinksCategory = MealCategory(
  id: 'drinks',
  label: 'Drinks',
  emoji: '🥤',
  colorValue: 0xFF3B82F6,
  bannerImage: 'assets/images/food/drinks_banner.jpg',
  items: [
    FoodItem(name: 'Lemon Soda',      calories: 150, imagePath: 'assets/images/food/drinks/lemon_soda.jpeg',     unit: 'per glass'),
    FoodItem(name: 'Apple Juice',     calories: 115, imagePath: 'assets/images/food/drinks/apple_juice.jpg',     unit: 'per 200 ml'),
    FoodItem(name: 'Pineapple Juice', calories: 130, imagePath: 'assets/images/food/drinks/pineapple_juice.jpg', unit: 'per 200 ml'),
    FoodItem(name: 'Mango Juice',     calories: 90,  imagePath: 'assets/images/food/drinks/mango_juice.jpg',     unit: 'per 200 ml'),
    FoodItem(name: 'Sprite',          calories: 150, imagePath: 'assets/images/food/drinks/sprite.webp',         unit: 'per can'),
    FoodItem(name: '7 Up',            calories: 150, imagePath: 'assets/images/food/drinks/7up.webp',            unit: 'per can'),
    FoodItem(name: 'Fanta',           calories: 150, imagePath: 'assets/images/food/drinks/fanta.jpg',           unit: 'per can'),
    FoodItem(name: 'Tea',             calories: 120, imagePath: 'assets/images/food/drinks/tea.webp',            unit: 'per cup'),
    FoodItem(name: 'Green Tea',       calories: 2,   imagePath: 'assets/images/food/drinks/green_tea.jpg',       unit: 'per cup'),
    FoodItem(name: 'Black Tea',       calories: 2,   imagePath: 'assets/images/food/drinks/black_tea.jpg',       unit: 'per cup'),
    FoodItem(name: 'Coffee',          calories: 120, imagePath: 'assets/images/food/drinks/coffee.webp',         unit: 'per cup'),
    FoodItem(name: 'Coconut Water',   calories: 45,  imagePath: 'assets/images/food/drinks/coconut_water.webp',  unit: 'per 200 ml'),
    FoodItem(name: 'Lassi',           calories: 160, imagePath: 'assets/images/food/drinks/lassi.webp',          unit: 'per glass'),
  ],
);

const MealCategory fruitsCategory = MealCategory(
  id: 'fruits',
  label: 'Fruits',
  emoji: '🍎',
  colorValue: 0xFFEC4899,
  bannerImage: 'assets/images/food/fruits_banner.jpg',
  items: [
    FoodItem(name: 'Apple',        calories: 52, imagePath: 'assets/images/food/fruits/apple.jpg',     unit: 'per 100 g'),
    FoodItem(name: 'Mango',        calories: 60, imagePath: 'assets/images/food/fruits/mango.webp',    unit: 'per 100 g'),
    FoodItem(name: 'Chiku',        calories: 83, imagePath: 'assets/images/food/fruits/chiku.webp',    unit: 'per 100 g'),
    FoodItem(name: 'Pineapple',    calories: 50, imagePath: 'assets/images/food/fruits/pineapple.jpg', unit: 'per 100 g'),
    FoodItem(name: 'Mixed Fruits', calories: 65, imagePath: 'assets/images/food/fruits/mixed_fruit.jpg', unit: 'per bowl'),
  ],
);

/// Master list — used by FoodScreen and FoodStorageService
const List<MealCategory> allMealCategories = [
  breakfastCategory,
  lunchCategory,
  dinnerCategory,
  drinksCategory,
  fruitsCategory,
];