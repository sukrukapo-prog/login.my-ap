import 'package:flutter/material.dart';
import 'package:fitmetrics/services/firestore_service.dart';
import 'package:fitmetrics/models/onboarding_data.dart';

class FeedbackScreen extends StatefulWidget {
  final OnboardingData? userData;

  const FeedbackScreen({super.key, this.userData});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  final _msgCtrl = TextEditingController();
  String _type = 'General';
  int _rating = 0;
  bool _submitted = false;
  bool _isLoading = false;

  late AnimationController _successAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _types = [
    {'label': 'General', 'icon': Icons.chat_bubble_outline},
    {'label': 'Bug Report', 'icon': Icons.bug_report_outlined},
    {'label': 'Feature Request', 'icon': Icons.lightbulb_outline},
    {'label': 'Meditation', 'icon': Icons.self_improvement},
    {'label': 'Workout', 'icon': Icons.fitness_center},
  ];

  // Resolved user details (read-only)
  String get _userName =>
      widget.userData?.fullName ??
          widget.userData?.name ??
          'User';

  String get _userEmail => widget.userData?.email ?? '';

  @override
  void initState() {
    super.initState();
    _successAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _successAnim, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _successAnim, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _successAnim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_msgCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please write your feedback before submitting'),
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirestoreService.submitFeedback(
        name: _userName,
        email: _userEmail,
        type: _type,
        rating: _rating,
        message: _msgCtrl.text,
      );
      if (mounted) {
        setState(() {
          _submitted = true;
          _isLoading = false;
        });
        _successAnim.forward();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // ── Static launcher ────────────────────────────────────────────────────────
  static void show(BuildContext context, {OnboardingData? userData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FeedbackScreen(userData: userData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: _submitted ? _buildSuccess() : _buildForm(scrollCtrl),
      ),
    );
  }

  // ── Success state ──────────────────────────────────────────────────────────
  Widget _buildSuccess() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated checkmark circle
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 28),

              // Thank you heading
              const Text(
                'Thank You! 🙏',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 16),

              // Primary message
              const Text(
                'We received your feedback!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              // Secondary message
              Text(
                'Thanks for taking the time to share your thoughts. '
                    'Our team will carefully review your feedback and work on making '
                    'FitMetrics even better for you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 14,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 24),

              // Subtle closing note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Text(
                  'This window will close automatically',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Form ───────────────────────────────────────────────────────────────────
  Widget _buildForm(ScrollController scrollCtrl) {
    return ListView(
      controller: scrollCtrl,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Header row
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
              ),
              child: const Icon(Icons.rate_review_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Send Feedback',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                Text('Help us improve FitMetrics',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child:
                const Icon(Icons.close, color: Colors.white54, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ── Name (read-only, pre-filled) ──────────────────────────────────
        _label('Your Name'),
        const SizedBox(height: 8),
        _readOnlyField(value: _userName, icon: Icons.person_outline_rounded),
        const SizedBox(height: 18),

        // ── Email (read-only, pre-filled) ─────────────────────────────────
        _label('Email'),
        const SizedBox(height: 8),
        _readOnlyField(
          value: _userEmail.isNotEmpty ? _userEmail : 'Not provided',
          icon: Icons.mail_outline_rounded,
          faded: _userEmail.isEmpty,
        ),
        const SizedBox(height: 22),

        // ── Feedback type ─────────────────────────────────────────────────
        _label('Feedback Type'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _types.map((t) {
            final selected = _type == t['label'];
            return GestureDetector(
              onTap: () => setState(() => _type = t['label'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)])
                      : null,
                  color: selected ? null : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t['icon'] as IconData,
                        size: 14,
                        color: selected ? Colors.white : Colors.white38),
                    const SizedBox(width: 6),
                    Text(t['label'] as String,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white54,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // ── Star rating ───────────────────────────────────────────────────
        _label('Rate Your Experience'),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (i) {
            final filled = i < _rating;
            return GestureDetector(
              onTap: () => setState(() => _rating = i + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: filled ? const Color(0xFFF59E0B) : Colors.white24,
                  size: filled ? 38 : 32,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // ── Message ───────────────────────────────────────────────────────
        _label('Your Feedback *'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: TextField(
            controller: _msgCtrl,
            maxLines: 5,
            maxLength: 500,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Tell us what you think...',
              hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.25)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle:
              const TextStyle(color: Colors.white24, fontSize: 11),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 30),

        // ── Submit button ─────────────────────────────────────────────────
        GestureDetector(
          onTap: _isLoading ? null : _submit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isLoading
                    ? [
                  const Color(0xFF3B82F6).withOpacity(0.5),
                  const Color(0xFF8B5CF6).withOpacity(0.5),
                ]
                    : const [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isLoading
                  ? []
                  : [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : const Text(
                'Submit Feedback',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600),
  );

  /// A styled non-editable display row for name / email.
  Widget _readOnlyField({
    required String value,
    required IconData icon,
    bool faded = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: faded
                    ? Colors.white.withOpacity(0.25)
                    : Colors.white.withOpacity(0.75),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Lock badge
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 10, color: Colors.white.withOpacity(0.3)),
                const SizedBox(width: 4),
                Text(
                  'auto-filled',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}