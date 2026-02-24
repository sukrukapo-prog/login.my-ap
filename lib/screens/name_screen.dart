import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/screens/goals_screen.dart';
import 'package:fitmetrics_app/widgets/progress_dots.dart';
import 'package:fitmetrics_app/routes.dart'; // import your routes file

class NameScreen extends StatefulWidget {
  final OnboardingData data;

  const NameScreen({super.key, required this.data});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  late TextEditingController _controller;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.data.name ?? '');

    // Enable/disable button in real time as user types
    _controller.addListener(() {
      setState(() {
        _isButtonEnabled = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 8),

              // Progress dots
              const ProgressDots(current: 1),

              const SizedBox(height: 32),

              const Text(
                'Welcome',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "First, what can we call you?\nWe'd like to get to know you.",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),

              const SizedBox(height: 40),

              const Text('Preferred first name', style: TextStyle(fontSize: 16)),

              const SizedBox(height: 12),

              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Enter your name',
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 8),

              // Show error message if name is empty (only when user tries to submit)
              if (!_isButtonEnabled && _controller.text.trim().isNotEmpty == false)
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    'Please enter your name',
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),

              const Spacer(),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () {
                    final name = _controller.text.trim();

                    widget.data.name = name;

                    // Navigate to next screen using named route
                    Navigator.pushNamed(
                      context,
                      AppRoutes.goals,
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