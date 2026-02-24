import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/widgets/progress_dots.dart';
import 'package:fitmetrics_app/routes.dart'; // ← for named navigation

class PersonalInfoScreen extends StatefulWidget {
  final OnboardingData data;

  const PersonalInfoScreen({super.key, required this.data});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  String? _gender;
  late TextEditingController _ageController;
  String? _country;

  final List<String> _countries = [
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.data.age?.toString() ?? '');
    _gender = widget.data.gender;
    _country = widget.data.country;

    // Update UI when age changes (real-time validation)
    _ageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _gender != null &&
          _ageController.text.trim().isNotEmpty &&
          int.tryParse(_ageController.text) != null &&
          int.parse(_ageController.text) > 0 &&
          _country != null;

  String? get _ageError {
    final text = _ageController.text.trim();
    if (text.isEmpty) return 'Age is required';
    final age = int.tryParse(text);
    if (age == null || age <= 0) return 'Enter a valid age';
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

              const ProgressDots(current: 3),

              const SizedBox(height: 32),

              const Text(
                "Tell us a little bit about yourself",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),

              const Text('Please select which sex we should use to calculate your calorie needs'),

              const SizedBox(height: 16),

              // Modern gender selection (no deprecated RadioListTile)
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Male'),
                      leading: Radio<String>(
                        value: 'Male',
                        groupValue: _gender,
                        activeColor: const Color(0xFF3B82F6),
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Female'),
                      leading: Radio<String>(
                        value: 'Female',
                        groupValue: _gender,
                        activeColor: const Color(0xFF3B82F6),
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              // Show error if gender not selected
              if (_gender == null)
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    'Please select gender',
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 24),

              const Text('How old are you?'),
              const SizedBox(height: 8),

              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Your age',
                  errorText: _ageError, // shows under field
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 24),

              const Text('Where do you live?'),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _country,
                hint: const Text('Select Country'),
                items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _country = v),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorText: _country == null ? 'Please select country' : null,
                ),
              ),

              const Spacer(),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValid
                      ? () {
                    widget.data.gender = _gender;
                    widget.data.age = int.tryParse(_ageController.text);
                    widget.data.country = _country;

                    // Use named route (recommended)
                    Navigator.pushNamed(
                      context,
                      AppRoutes.measurements,
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