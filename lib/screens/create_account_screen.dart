import 'package:flutter/material.dart';
import 'package:fitmetrics_app/models/onboarding_data.dart';
import 'package:fitmetrics_app/widgets/progress_dots.dart';

class CreateAccountScreen extends StatefulWidget {
  final OnboardingData data;
  const CreateAccountScreen({super.key, required this.data});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.data.email ?? '';
    _passwordController.text = widget.data.password ?? '';
  }

  bool get _isValid {
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    return email.contains('@') && email.contains('.') && pass.length >= 10;
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
              const ProgressDots(current: 5),
              const SizedBox(height: 32),
              const Text(
                "Almost done! Create your account.",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              const Text('Email Address'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'your@email.com',
                ),
              ),
              const SizedBox(height: 24),
              const Text('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'At least 10 characters',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('10 characters minimum', style: TextStyle(fontSize: 14, color: Colors.white60)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValid
                      ? () {
                    widget.data.email = _emailController.text.trim();
                    widget.data.password = _passwordController.text;
                    // Here you would normally call sign-up API
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Account created for ${widget.data.name}!'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    // Navigator.pushReplacement to home/dashboard
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Create Account', style: TextStyle(fontSize: 18)),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}