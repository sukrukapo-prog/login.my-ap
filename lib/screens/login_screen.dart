import 'package:flutter/material.dart';
import 'package:fitmetrics/services/local_storage.dart';
import 'package:fitmetrics/routes.dart';
import 'package:fitmetrics/models/onboarding_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _login() async {
    final savedData = await LocalStorage.getUserData();
    if (savedData == null) {
      setState(() => _errorMessage = 'No registered user found');
      return;
    }

    // Validate input
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Email is required');
      return;
    }
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      setState(() => _errorMessage = 'Invalid email format');
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Password is required');
      return;
    }
    if (_passwordController.text.length < 10) {
      setState(() => _errorMessage = 'Password must be at least 10 characters');
      return;
    }

    // Check against saved
    if (_emailController.text.trim() != savedData.email ||
        _passwordController.text != savedData.password) {
      setState(() => _errorMessage = 'Incorrect email or password');
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.main, arguments: savedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                LocalStorage.clear(); // reset for new registration
                Navigator.pushReplacementNamed(context, AppRoutes.welcome);
              },
              child: const Text('Register New Account'),
            ),
          ],
        ),
      ),
    );
  }
}