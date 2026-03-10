import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmetrics/models/onboarding_data.dart';
import 'package:fitmetrics/routes.dart';
import 'package:fitmetrics/screens/auth/avatar_selection_screen.dart';
import 'package:fitmetrics/services/auth_service.dart';

class SuccessScreen extends StatefulWidget {
  final OnboardingData data;
  const SuccessScreen({super.key, required this.data});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  // States: 'registering' | 'verify_email' | 'account_exists' | 'error'
  String _state = 'registering';
  bool _isLoading = false;
  String? _error;
  Timer? _checkTimer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  // For account-already-exists flow
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerAndSendVerification() async {
    setState(() { _state = 'registering'; _error = null; });

    final result = await AuthService.register(widget.data);
    if (!mounted) return;

    if (!result.success) {
      // Account already exists — show login with password
      if (result.error?.contains('already exists') == true) {
        setState(() { _state = 'account_exists'; });
        return;
      }
      setState(() { _state = 'error'; _error = result.error; });
      return;
    }

    await _sendVerificationEmail();
    if (!mounted) return;
    setState(() { _state = 'verify_email'; });
    _startPolling();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(
          ActionCodeSettings(
            url: 'https://fitmetrics-kapil.firebaseapp.com',
            handleCodeInApp: false,
          ),
        );
      }
    } catch (e) {
      // fallback without ActionCodeSettings
      try {
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      } catch (_) {}
    }
  }

  void _startPolling() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkVerification(silent: true);
    });
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified == true) {
        _checkTimer?.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AvatarSelectionScreen(data: widget.data)),
          );
        }
      } else {
        if (!silent && mounted) {
          setState(() {
            _isLoading = false;
            _error = 'Email not verified yet. Please click the link sent to ${widget.data.email}';
          });
        }
      }
    } catch (e) {
      if (!silent && mounted) {
        setState(() { _isLoading = false; _error = 'Could not check. Please try again.'; });
      }
    }
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;
    try {
      await _sendVerificationEmail();
      setState(() { _error = null; _resendCooldown = 60; });
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() { _resendCooldown--; if (_resendCooldown <= 0) t.cancel(); });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent!'), backgroundColor: Color(0xFF3B82F6)),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Failed to resend. Try again.');
    }
  }

  // ── Account exists: login with existing password ───────────────────────────

  Future<void> _loginExistingAccount() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = 'Please enter your password.');
      return;
    }
    setState(() { _isLoading = true; _error = null; });

    final result = await AuthService.login(widget.data.email!, password);
    if (!mounted) return;

    if (!result.success) {
      setState(() { _isLoading = false; _error = result.error; });
      return;
    }

    setState(() => _isLoading = false);
    // Go straight to main app
    Navigator.pushReplacementNamed(context, AppRoutes.main, arguments: result.userData);
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                Row(children: List.generate(totalSteps, (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 4), height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i < currentStep ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.15),
                    ),
                  ),
                ))),
                const SizedBox(height: 40),

                if (_state == 'registering') _buildRegistering(),
                if (_state == 'verify_email') _buildVerifyEmail(),
                if (_state == 'account_exists') _buildAccountExists(),
                if (_state == 'error') _buildError(),

                const SizedBox(height: 32),
              ]),
            ),
          ),

          // Bottom button
          if (_state == 'verify_email')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _checkVerification(silent: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("I've Verified My Email", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),

          if (_state == 'account_exists')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginExistingAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Continue to My Account', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  // ── State builders ─────────────────────────────────────────────────────────

  Widget _buildRegistering() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _iconBox(Icons.person_add_outlined),
    const SizedBox(height: 24),
    const Text('Creating your account...', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
    const SizedBox(height: 24),
    const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
  ]);

  Widget _buildVerifyEmail() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _iconBox(Icons.mark_email_read_outlined),
    const SizedBox(height: 24),
    const Text('Verify your email', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    RichText(text: TextSpan(
      style: const TextStyle(color: Colors.white54, fontSize: 14, height: 1.6),
      children: [
        const TextSpan(text: 'We sent a verification link to\n'),
        TextSpan(text: widget.data.email ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const TextSpan(text: '\n\nClick the link in the email, then tap the button below.'),
      ],
    )),
    const SizedBox(height: 28),
    _StepItem(number: '1', text: 'Open your email inbox'),
    const SizedBox(height: 12),
    _StepItem(number: '2', text: 'Find the email from FitMetrics / Firebase'),
    const SizedBox(height: 12),
    _StepItem(number: '3', text: 'Click the verification link'),
    const SizedBox(height: 12),
    _StepItem(number: '4', text: 'Come back and tap "I\'ve Verified"'),
    const SizedBox(height: 24),
    Row(children: [
      const Text("Didn't get it? ", style: TextStyle(color: Colors.white54, fontSize: 13)),
      GestureDetector(
        onTap: _resendCooldown > 0 ? null : _resendEmail,
        child: Text(
          _resendCooldown > 0 ? 'Resend in ${_resendCooldown}s' : 'Resend email',
          style: TextStyle(
            color: _resendCooldown > 0 ? Colors.white38 : const Color(0xFF3B82F6),
            fontSize: 13, fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ]),
    if (_error != null) _errorBox(_error!),
  ]);

  Widget _buildAccountExists() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _iconBox(Icons.person_outline, color: const Color(0xFF10B981)),
    const SizedBox(height: 24),
    const Text('Account already exists', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    RichText(text: TextSpan(
      style: const TextStyle(color: Colors.white54, fontSize: 14, height: 1.6),
      children: [
        const TextSpan(text: 'An account with '),
        TextSpan(text: widget.data.email ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const TextSpan(text: ' already exists.\n\nEnter your password to continue.'),
      ],
    )),
    const SizedBox(height: 28),
    const Text('Password', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      onSubmitted: (_) => _loginExistingAccount(),
      decoration: InputDecoration(
        hintText: 'Enter your password',
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.white38, size: 20),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    ),
    const SizedBox(height: 8),
    Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () async {
          final email = widget.data.email;
          if (email == null) return;
          final result = await AuthService.sendPasswordReset(email);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result.success ? 'Reset email sent to $email' : result.error ?? 'Failed'),
              backgroundColor: result.success ? const Color(0xFF3B82F6) : Colors.red,
            ));
          }
        },
        child: const Text('Forgot password?', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 13)),
      ),
    ),
    if (_error != null) _errorBox(_error!),
  ]);

  Widget _buildError() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _iconBox(Icons.error_outline, color: Colors.redAccent),
    const SizedBox(height: 24),
    const Text('Something went wrong', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
    const SizedBox(height: 16),
    if (_error != null) _errorBox(_error!),
    const SizedBox(height: 24),
    SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: _registerAndSendVerification,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Try Again', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    ),
  ]);

  Widget _iconBox(IconData icon, {Color color = const Color(0xFF3B82F6)}) => Container(
    width: 72, height: 72,
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
    child: Icon(icon, color: color, size: 36),
  );

  Widget _errorBox(String msg) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Text(msg, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
    ),
  );
}

class _StepItem extends StatelessWidget {
  final String number, text;
  const _StepItem({required this.number, required this.text});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.2), shape: BoxShape.circle),
      child: Center(child: Text(number, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.w700))),
    ),
    const SizedBox(width: 12),
    Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
  ]);
} 