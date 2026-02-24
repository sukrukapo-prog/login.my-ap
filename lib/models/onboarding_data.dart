class OnboardingData {
  String? name;
  Set<String> goals = {};
  String? gender; // 'Male' or 'Female'
  int? age;
  String? country;
  double? heightCm;
  double? currentWeightKg;
  double? goalWeightKg;
  String? email;
  String? password;

  OnboardingData(); // explicit empty constructor

  // Validation getters (your original code is perfect)
  bool get hasName => name != null && name!.trim().isNotEmpty;
  bool get hasGoals => goals.isNotEmpty;
  bool get hasGender => gender != null;
  bool get hasAge => age != null && age! > 0;
  bool get hasCountry => country != null && country!.isNotEmpty;
  bool get hasMeasurements =>
      heightCm != null && heightCm! > 0 &&
          currentWeightKg != null && currentWeightKg! > 0 &&
          goalWeightKg != null && goalWeightKg! > 0;
  bool get hasCredentials =>
      email != null && email!.contains('@') &&
          password != null && password!.length >= 10;

  bool get isComplete =>
      hasName &&
          hasGoals &&
          hasGender &&
          hasAge &&
          hasCountry &&
          hasMeasurements &&
          hasCredentials;

  // ──────────────────────────────────────────────────────────────
  // JSON serialization (for shared_preferences, backend, etc.)
  // ──────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'goals': goals.toList(),
      'gender': gender,
      'age': age,
      'country': country,
      'heightCm': heightCm,
      'currentWeightKg': currentWeightKg,
      'goalWeightKg': goalWeightKg,
      'email': email,
      // password → NEVER save in plain text in production!
      // If you really need to persist credentials → use secure storage (flutter_secure_storage)
    };
  }

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData()
      ..name = json['name'] as String?
      ..goals = (json['goals'] as List<dynamic>?)?.cast<String>().toSet() ?? {}
      ..gender = json['gender'] as String?
      ..age = json['age'] as int?
      ..country = json['country'] as String?
      ..heightCm = (json['heightCm'] as num?)?.toDouble()
      ..currentWeightKg = (json['currentWeightKg'] as num?)?.toDouble()
      ..goalWeightKg = (json['goalWeightKg'] as num?)?.toDouble()
      ..email = json['email'] as String?;
  }

  // Optional: copyWith for easy updates (very useful in forms)
  OnboardingData copyWith({
    String? name,
    Set<String>? goals,
    String? gender,
    int? age,
    String? country,
    double? heightCm,
    double? currentWeightKg,
    double? goalWeightKg,
    String? email,
    String? password,
  }) {
    return OnboardingData()
      ..name = name ?? this.name
      ..goals = goals ?? this.goals
      ..gender = gender ?? this.gender
      ..age = age ?? this.age
      ..country = country ?? this.country
      ..heightCm = heightCm ?? this.heightCm
      ..currentWeightKg = currentWeightKg ?? this.currentWeightKg
      ..goalWeightKg = goalWeightKg ?? this.goalWeightKg
      ..email = email ?? this.email
      ..password = password ?? this.password;
  }

  // Optional: clear / reset method
  void clear() {
    name = null;
    goals.clear();
    gender = null;
    age = null;
    country = null;
    heightCm = null;
    currentWeightKg = null;
    goalWeightKg = null;
    email = null;
    password = null;
  }
}