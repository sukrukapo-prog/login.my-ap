import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/screens/create_account_screen.dart';
import 'package:fitmetrics_app/widgets/progress_dots.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  final OnboardingData data;
  const BodyMeasurementsScreen({super.key, required this.data});

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _heightController.text = widget.data.heightCm?.toString() ?? '';
    _weightController.text = widget.data.currentWeightKg?.toString() ?? '';
    _goalWeightController.text = widget.data.goalWeightKg?.toString() ?? '';
  }

  bool get _isValid {
    final h = double.tryParse(_heightController.text) ?? 0;
    final w = double.tryParse(_weightController.text) ?? 0;
    final g = double.tryParse(_goalWeightController.text) ?? 0;
    return h > 50 && w > 20 && g > 20;
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
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Height',
                  suffixText: 'cm',
                ),
              ),
              const SizedBox(height: 24),
              const Text('How much do you weigh?'),
              const SizedBox(height: 8),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Weight',
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: 24),
              const Text("What's your goal weight?"),
              const SizedBox(height: 8),
              TextField(
                controller: _goalWeightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Goal weight',
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "It's OK to estimate, you can update later.\n"
                    "This doesn't affect your daily calorie goal and you can always change it later.",
                style: TextStyle(fontSize: 14, color: Colors.white60),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValid
                      ? () {
                    widget.data.heightCm = double.tryParse(_heightController.text);
                    widget.data.currentWeightKg = double.tryParse(_weightController.text);
                    widget.data.goalWeightKg = double.tryParse(_goalWeightController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateAccountScreen(data: widget.data),
                      ),
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

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }
}