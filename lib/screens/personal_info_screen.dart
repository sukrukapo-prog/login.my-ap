import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/screens/body_measurements_screen.dart';
import 'package:fitmetrics_app/widgets/progress_dots.dart';

class PersonalInfoScreen extends StatefulWidget {
  final OnboardingData data;
  const PersonalInfoScreen({super.key, required this.data});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  String? _gender;
  final _ageController = TextEditingController();
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
    _gender = widget.data.gender;
    _ageController.text = widget.data.age?.toString() ?? '';
    _country = widget.data.country;
  }

  bool get _isValid =>
      _gender != null &&
          _ageController.text.trim().isNotEmpty &&
          int.tryParse(_ageController.text) != null &&
          _country != null;

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
              const SizedBox(height: 24),
              const Text('How old are you?'),
              const SizedBox(height: 8),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Your age',
                ),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValid
                      ? () {
                    widget.data.gender = _gender;
                    widget.data.age = int.tryParse(_ageController.text);
                    widget.data.country = _country;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BodyMeasurementsScreen(data: widget.data),
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
    _ageController.dispose();
    super.dispose();
  }
}