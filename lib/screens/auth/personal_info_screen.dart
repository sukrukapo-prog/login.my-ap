import 'package:flutter/material.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/routes.dart';

class PersonalInfoScreen extends StatefulWidget {
  final OnboardingData data;
  const PersonalInfoScreen({super.key, required this.data});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _ageController = TextEditingController();
  final _fullNameController = TextEditingController();
  String? _gender;
  double _heightCm = 170;
  double _weightKg = 70;
  bool _heightInFeet = false;
  bool _weightInLbs = false;

  static const int totalSteps = 6;
  static const int currentStep = 2;

  @override
  void initState() {
    super.initState();
    if (widget.data.age != null) _ageController.text = widget.data.age.toString();
    if (widget.data.gender != null) _gender = widget.data.gender;
    if (widget.data.heightCm != null) _heightCm = widget.data.heightCm!;
    if (widget.data.currentWeightKg != null) _weightKg = widget.data.currentWeightKg!;
    // Pre-fill full name if already set, else use preferred name
    _fullNameController.text = widget.data.fullName ?? widget.data.name ?? '';
  }

  @override
  void dispose() {
    _ageController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _next() {
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your age')));
      return;
    }
    final age = int.tryParse(ageText);
    if (age == null || age < 5 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid age (5–120)')));
      return;
    }
    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your gender')));
      return;
    }
    widget.data.age = age;
    widget.data.gender = _gender;
    widget.data.heightCm = _heightCm;
    widget.data.currentWeightKg = _weightKg;
    // Save full name separately
    final fullName = _fullNameController.text.trim();
    if (fullName.isNotEmpty) widget.data.fullName = fullName;

    Navigator.pushNamed(context, AppRoutes.personalize, arguments: widget.data);
  }

  String _formatHeight() {
    if (_heightInFeet) {
      final totalInches = _heightCm / 2.54;
      final feet = (totalInches ~/ 12);
      final inches = (totalInches % 12).round();
      return "$feet'$inches\"";
    }
    return '${_heightCm.round()} cm';
  }

  String _formatWeight() {
    if (_weightInLbs) {
      return '${(_weightKg * 2.20462).toStringAsFixed(1)} lbs';
    }
    return '${_weightKg.toStringAsFixed(1)} kg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ProgressBar(current: currentStep, total: totalSteps),
                    const SizedBox(height: 32),
                    const Text(
                      'Personal Details',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Let's get to know you better to personalize your plan.",
                      style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 28),

                    // Preferred Name (display only)
                    const Text('Preferred Name',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        widget.data.name ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Full Name (editable, different from preferred name)
                    const Text('Full Name',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Your real full name (can be different from preferred name)',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _fullNameController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g. John Michael Smith',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.07),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Age + Gender row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Age',
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              const Text('5 – 120',
                                  style: TextStyle(color: Colors.white38, fontSize: 11)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: '25',
                                  hintStyle: const TextStyle(color: Colors.white30),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Gender',
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _gender,
                                    hint: const Text('Select', style: TextStyle(color: Colors.white30)),
                                    dropdownColor: const Color(0xFF1A2540),
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
                                    items: ['Male', 'Female', 'Other'].map((g) =>
                                        DropdownMenuItem(value: g, child: Text(g))).toList(),
                                    onChanged: (v) => setState(() => _gender = v),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Height
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Height',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            _UnitToggle(label: 'cm', active: !_heightInFeet, onTap: () => setState(() => _heightInFeet = false)),
                            const SizedBox(width: 6),
                            _UnitToggle(label: 'ft/in', active: _heightInFeet, onTap: () => setState(() => _heightInFeet = true)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(_formatHeight(),
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF3B82F6),
                              inactiveTrackColor: Colors.white12,
                              thumbColor: const Color(0xFF3B82F6),
                              overlayShape: SliderComponentShape.noOverlay,
                              trackHeight: 3,
                            ),
                            child: Slider(
                              value: _heightCm,
                              min: 100,
                              max: 250,
                              onChanged: (v) => setState(() => _heightCm = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Weight
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Weight',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            _UnitToggle(label: 'kg', active: !_weightInLbs, onTap: () => setState(() => _weightInLbs = false)),
                            const SizedBox(width: 6),
                            _UnitToggle(label: 'lbs', active: _weightInLbs, onTap: () => setState(() => _weightInLbs = true)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('10 – 200 kg',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(_formatWeight(),
                              style: const TextStyle(
                                  color: Color(0xFF3B82F6), fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF3B82F6),
                              inactiveTrackColor: Colors.white12,
                              thumbColor: const Color(0xFF3B82F6),
                              overlayShape: SliderComponentShape.noOverlay,
                              trackHeight: 3,
                            ),
                            child: Slider(
                              value: _weightKg,
                              min: 10,   // ← realistic minimum
                              max: 200,  // ← realistic maximum
                              onChanged: (v) => setState(() => _weightKg = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Continue',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _UnitToggle({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i < current;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isActive ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.15),
            ),
          ),
        );
      }),
    );
  }
}