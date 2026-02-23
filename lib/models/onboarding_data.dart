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
}