import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/screens/auth/avatar_selection_screen.dart';
import 'package:fitmetrics/services/auth_service.dart';

class SuccessScreen extends StatefulWidget {
  final OnboardingData data;
  const SuccessScreen({super.key, required this.data});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _isRegistering = true;
  bool _isCheckingVerification = false;
  bool _emailSent = false;
  String? _error;
  Timer? _checkTimer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  static const int totalSteps = 6;
  static const int currentStep = 6;

  @override
  void initState() {
    super.initState();
    _registerAndSendVerification();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  /// Step 1: Create Firebase account, then send verification email
  Future<void> _registerAndSendVerification() async {
    setState(() { _isRegistering = true; _error = null; });

    final result = await AuthService.register(widget.data);

    if (!mounted) return;

    if (!result.success) {
      setState(() { _isRegistering = false; _error = result.error; });
      return;
    }

    // Send verification email
    await _sendVerificationEmail();
    setState(() { _isRegistering = false; _emailSent = true; });

    // Start polling for email verification every 3 seconds
    _startVerificationPolling();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      // Ignore — will retry on resend
    }
  }

  void _startVerificationPolling() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkVerification(silent: true);
    });
  }

  /// Check if user clicked the link in email
  Future<void> _checkVerification({bool silent = false}) async {
    if (!silent) setState(() => _isCheckingVerification = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await user.reload(); // force refresh from Firebase
      final refreshed = FirebaseAuth.instance.currentUser;

      if (refreshed?.emailVerified == true) {
        _checkTimer?.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AvatarSelectionScreen(data: widget.data)),
          );
        }
      } else {
        if (!silent && mounted) {
          setState(() { _isCheckingVerification = false; _error = 'Email not verified yet. Please click the link in your email.'; });
        }
      }
    } catch (e) {
      if (!silent && mounted) {
        setState(() { _isCheckingVerification = false; _error = 'Could not check verification. Please try again.'; });
      }
    }
  }

  /// Resend verification email with cooldown
  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;
    try {
      await _sendVerificationEmail();
      setState(() { _error = null; _resendCooldown = 60; });
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) t.cancel();
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: Color(0xFF3B82F6),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to resend. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(children: [
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

                  // Progress bar
                  Row(
                    children: List.generate(totalSteps, (i) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: i < currentStep ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.15),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 40),

                  // Icon
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.mark_email_read_outlined,
                        color: Color(0xFF3B82F6), size: 36),
                  ),
                  const SizedBox(height: 24),

                  if (_isRegistering) ...[
                    const Text('Creating your account...',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
                  ] else ...[
                    const Text('Verify your email',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                        children: [
                          const TextSpan(text: 'We sent a verification link to\n'),
                          TextSpan(
                            text: widget.data.email ?? '',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: '\n\nClick the link in the email, then tap the button below.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Steps guide
                    _StepItem(number: '1', text: 'Open your email inbox'),
                    const SizedBox(height: 12),
                    _StepItem(number: '2', text: 'Find the email from FitMetrics'),
                    const SizedBox(height: 12),
                    _StepItem(number: '3', text: 'Click the verification link'),
                    const SizedBox(height: 12),
                    _StepItem(number: '4', text: 'Come back and tap "I\'ve Verified"'),
                    const SizedBox(height: 24),

                    // Resend
                    Row(children: [
                      const Text("Didn't receive the email? ",
                          style: TextStyle(color: Colors.white54, fontSize: 13)),
                      GestureDetector(
                        onTap: _resendCooldown > 0 ? null : _resendEmail,
                        child: Text(
                          _resendCooldown > 0 ? 'Resend in ${_resendCooldown}s' : 'Resend',
                          style: TextStyle(
                            color: _resendCooldown > 0 ? Colors.white38 : const Color(0xFF3B82F6),
                            fontSize: 13, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                      ),
                    ],
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom button
          if (!_isRegistering)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isCheckingVerification ? null : () => _checkVerification(silent: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isCheckingVerification
                      ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("I've Verified My Email",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number, text;
  const _StepItem({required this.number, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(number,
            style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.w700))),
      ),
      const SizedBox(width: 12),
      Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    ]);
  }
}