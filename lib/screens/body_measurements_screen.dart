import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/widgets/progress_dots.dart';
import 'package:fitmetrics_app/routes.dart'; // ← for named navigation

class BodyMeasurementsScreen extends StatefulWidget {
  final OnboardingData data;

  const BodyMeasurementsScreen({super.key, required this.data});

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _goalWeightController;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(text: widget.data.heightCm?.toString() ?? '');
    _weightController = TextEditingController(text: widget.data.currentWeightKg?.toString() ?? '');
    _goalWeightController = TextEditingController(text: widget.data.goalWeightKg?.toString() ?? '');

    // Real-time validation update
    void listener() => setState(() {});
    _heightController.addListener(listener);
    _weightController.addListener(listener);
    _goalWeightController.addListener(listener);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final h = double.tryParse(_heightController.text.trim()) ?? 0;
    final w = double.tryParse(_weightController.text.trim()) ?? 0;
    final g = double.tryParse(_goalWeightController.text.trim()) ?? 0;
    return h > 50 && w > 20 && g > 20 && g >= w; // goal weight >= current weight
  }

  String? get _heightError {
    final text = _heightController.text.trim();
    if (text.isEmpty) return 'Height is required';
    final h = double.tryParse(text);
    if (h == null || h <= 50) return 'Enter a realistic height (>50 cm)';
    return null;
  }

  String? get _weightError {
    final text = _weightController.text.trim();
    if (text.isEmpty) return 'Weight is required';
    final w = double.tryParse(text);
    if (w == null || w <= 20) return 'Enter a realistic weight (>20 kg)';
    return null;
  }

  String? get _goalWeightError {
    final text = _goalWeightController.text.trim();
    if (text.isEmpty) return 'Goal weight is required';
    final g = double.tryParse(text);
    final w = double.tryParse(_weightController.text.trim()) ?? 0;
    if (g == null || g <= 20) return 'Enter a realistic goal (>20 kg)';
    if (g < w) return 'Goal should be ≥ current weight';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 8),

              const ProgressDots(current: 4),

              const SizedBox(height: 32),

              const Text(
                "Just few more questions",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),

              const Text('How tall are you?'),
              const SizedBox(height: 8),

              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Height',
                  suffixText: 'cm',
                  errorText: _heightError,
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 24),

              const Text('How much do you weigh?'),
              const SizedBox(height: 8),

              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Weight',
                  suffixText: 'kg',
                  errorText: _weightError,
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 24),

              const Text("What's your goal weight?"),
              const SizedBox(height: 8),

              TextField(
                controller: _goalWeightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Goal weight',
                  suffixText: 'kg',
                  errorText: _goalWeightError,
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 12),

              const Text(
                "It's OK to estimate, you can update later.\n"
                    "This doesn't affect your daily calorie goal and you can always change it later.",
                style: TextStyle(fontSize: 14, color: Colors.white60),
              ),

              const Spacer(),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValid
                      ? () {
                    widget.data.heightCm = double.tryParse(_heightController.text.trim());
                    widget.data.currentWeightKg = double.tryParse(_weightController.text.trim());
                    widget.data.goalWeightKg = double.tryParse(_goalWeightController.text.trim());

                    // Go to next screen using named route
                    Navigator.pushNamed(
                      context,
                      AppRoutes.createAccount,
                      arguments: widget.data,
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Next', style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}