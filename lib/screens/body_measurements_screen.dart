import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/widgets/progress_dots.dart';
import 'package:fitmetrics_app/routes.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  final OnboardingData data;

  const BodyMeasurementsScreen({super.key, required this.data});

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  late TextEditingController _heightController;     // cm
  late TextEditingController _feetController;
  late TextEditingController _inchesController;
  late TextEditingController _weightController;
  late TextEditingController _goalWeightController;

  bool _useMetric = true; // true = cm, false = ft/in

  @override
  void initState() {
    super.initState();

    _heightController = TextEditingController(text: widget.data.heightCm?.toString() ?? '');
    _weightController = TextEditingController(text: widget.data.currentWeightKg?.toString() ?? '');
    _goalWeightController = TextEditingController(text: widget.data.goalWeightKg?.toString() ?? '');

    // Convert saved cm to feet/inches if available
    if (widget.data.heightCm != null && widget.data.heightCm! > 0) {
      final fi = _cmToFeetInches(widget.data.heightCm!);
      _feetController = TextEditingController(text: fi[0].toString());
      _inchesController = TextEditingController(text: fi[1].toString());
    } else {
      _feetController = TextEditingController();
      _inchesController = TextEditingController();
    }

    // Real-time validation update
    void listener() => setState(() {});
    _heightController.addListener(listener);
    _feetController.addListener(listener);
    _inchesController.addListener(listener);
    _weightController.addListener(listener);
    _goalWeightController.addListener(listener);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  // Convert cm → [feet, inches]
  List<int> _cmToFeetInches(double cm) {
    final totalInches = (cm / 2.54).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return [feet, inches];
  }

  // Convert feet + inches → cm
  double _feetInchesToCm(int feet, int inches) {
    return (feet * 12 + inches) * 2.54;
  }

  // ==================== ONLY ONE _currentHeightCm ====================
  double get _currentHeightCm {
    if (_useMetric) {
      return double.tryParse(_heightController.text.trim()) ?? 0;
    } else {
      final feet = int.tryParse(_feetController.text.trim()) ?? 0;
      final inches = int.tryParse(_inchesController.text.trim()) ?? 0;
      return _feetInchesToCm(feet, inches);
    }
  }

  bool get _isValid {
    final h = _currentHeightCm;
    final w = double.tryParse(_weightController.text.trim()) ?? 0;
    final g = double.tryParse(_goalWeightController.text.trim()) ?? 0;
    return h > 50 && w > 20 && g > 20 && g >= w;
  }

  String? get _heightError {
    final h = _currentHeightCm;
    if (h <= 0) return 'Height is required';
    if (h <= 50) return 'Enter realistic height (>50 cm)';
    return null;
  }

  String? get _weightError {
    final text = _weightController.text.trim();
    if (text.isEmpty) return 'Weight is required';
    final w = double.tryParse(text);
    if (w == null || w <= 20) return 'Enter realistic weight (>20 kg)';
    return null;
  }

  String? get _goalWeightError {
    final text = _goalWeightController.text.trim();
    if (text.isEmpty) return 'Goal weight is required';
    final g = double.tryParse(text);
    final w = double.tryParse(_weightController.text.trim()) ?? 0;
    if (g == null || g <= 20) return 'Enter realistic goal (>20 kg)';
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
                icon: const Icon(Icons.arrow_back_rounded, size: 28),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 8),

              const ProgressDots(current: 4),

              const SizedBox(height: 32),

              const Text(
                "Just a few more questions",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              const Text('How tall are you?'),

              const SizedBox(height: 12),

              // Unit Toggle
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(value: true, label: Text('cm')),
                  ButtonSegment<bool>(value: false, label: Text('ft/in')),
                ],
                selected: {_useMetric},
                onSelectionChanged: (Set<bool> selection) {
                  setState(() {
                    _useMetric = selection.first;

                    if (_useMetric) {
                      // ft/in → cm
                      final feet = int.tryParse(_feetController.text.trim()) ?? 0;
                      final inches = int.tryParse(_inchesController.text.trim()) ?? 0;
                      final cm = _feetInchesToCm(feet, inches);
                      _heightController.text = cm.toStringAsFixed(1);
                    } else {
                      // cm → ft/in
                      final cm = double.tryParse(_heightController.text.trim()) ?? 0;
                      if (cm > 0) {
                        final fi = _cmToFeetInches(cm);
                        _feetController.text = fi[0].toString();
                        _inchesController.text = fi[1].toString();
                      }
                    }
                  });
                },
              ),

              const SizedBox(height: 16),

              // Height Input
              if (_useMetric)
                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withAlpha(20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    hintText: 'Height',
                    suffixText: 'cm',
                    errorText: _heightError,
                  ),
                  style: const TextStyle(color: Colors.white),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _feetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withAlpha(20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          hintText: 'Feet',
                          suffixText: 'ft',
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _inchesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withAlpha(20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          hintText: 'Inches',
                          suffixText: 'in',
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Goal weight',
                  suffixText: 'kg',
                  errorText: _goalWeightError,
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 12),

              const Text(
                "It's OK to estimate — you can update later.\n"
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
                    widget.data.heightCm = _currentHeightCm;
                    widget.data.currentWeightKg = double.tryParse(_weightController.text.trim());
                    widget.data.goalWeightKg = double.tryParse(_goalWeightController.text.trim());

                    Navigator.pushNamed(
                      context,
                      AppRoutes.createAccount,
                      arguments: widget.data,
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
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