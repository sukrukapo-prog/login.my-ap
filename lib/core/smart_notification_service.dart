import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitmetrics/services/local_storage.dart';

/// Smart in-app notification banners.
/// Triggers: streak at risk, daily goal not reached, milestone hit.
/// When Firebase is added, swap _showBanner with push notifications.
class SmartNotificationService {
  static final SmartNotificationService _instance =
  SmartNotificationService._internal();
  factory SmartNotificationService() => _instance;
  SmartNotificationService._internal();

  static OverlayEntry? _currentBanner;

  Future<void> checkAndNotify(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';

    final streakEnabled = prefs.getBool('notif_streak_protection') ?? true;
    final reminderEnabled = prefs.getBool('notif_daily_reminder') ?? true;
    final milestoneEnabled = prefs.getBool('notif_milestone') ?? true;

    final stats = await LocalStorage.getAllTimeStats();
    final minsToday = await LocalStorage.getMeditationMinutes(now);
    final goalMins = await LocalStorage.getDailyGoalMinutes();
    final streakDays = stats['streakDays'] ?? 0;

    // 1. Milestone celebration (check first — most exciting)
    if (milestoneEnabled) {
      final lastMilestone = prefs.getInt('last_milestone_notif') ?? 0;
      for (final m in [3, 7, 14, 30, 60, 100]) {
        if (streakDays == m && lastMilestone != m) {
          await prefs.setInt('last_milestone_notif', m);
          if (context.mounted) {
            _showBanner(
              context: context,
              emoji: '🏆',
              title: '$m Day Streak!',
              message: 'Amazing! $m days in a row — you\'re unstoppable!',
              color: const Color(0xFF8B5CF6),
            );
          }
          return;
        }
      }
    }

    // 2. Streak protection — after 7pm, streak > 0, no session today
    if (streakEnabled &&
        streakDays > 0 &&
        minsToday == 0 &&
        now.hour >= 19 &&
        prefs.getString('last_streak_notif') != todayKey) {
      await prefs.setString('last_streak_notif', todayKey);
      if (context.mounted) {
        _showBanner(
          context: context,
          emoji: '🔥',
          title: 'Protect your $streakDays day streak!',
          message: 'No session yet today — meditate before midnight!',
          color: const Color(0xFFF59E0B),
        );
      }
      return;
    }

    // 3. Daily goal reminder — after 8pm, goal not reached
    if (reminderEnabled &&
        minsToday < goalMins &&
        now.hour >= 20 &&
        prefs.getString('last_reminder_notif') != todayKey) {
      await prefs.setString('last_reminder_notif', todayKey);
      final remaining = goalMins - minsToday;
      if (context.mounted) {
        _showBanner(
          context: context,
          emoji: '🎯',
          title: 'Daily goal not reached',
          message: 'Just $remaining more minutes to hit your goal today!',
          color: const Color(0xFF3B82F6),
        );
      }
    }
  }

  static void _showBanner({
    required BuildContext context,
    required String emoji,
    required String title,
    required String message,
    required Color color,
  }) {
    _currentBanner?.remove();
    _currentBanner = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _NotifBanner(
        emoji: emoji,
        title: title,
        message: message,
        color: color,
        onDismiss: () {
          entry.remove();
          _currentBanner = null;
        },
      ),
    );

    _currentBanner = entry;
    Overlay.of(context).insert(entry);

    // Auto-dismiss after 6s
    Future.delayed(const Duration(seconds: 6), () {
      if (_currentBanner == entry) {
        try { entry.remove(); } catch (_) {}
        _currentBanner = null;
      }
    });
  }

  // ── Settings helpers ───────────────────────────────────────────────────────
  static Future<bool> isStreakProtectionEnabled() async =>
      (await SharedPreferences.getInstance()).getBool('notif_streak_protection') ?? true;

  static Future<void> setStreakProtection(bool v) async =>
      (await SharedPreferences.getInstance()).setBool('notif_streak_protection', v);

  static Future<bool> isDailyReminderEnabled() async =>
      (await SharedPreferences.getInstance()).getBool('notif_daily_reminder') ?? true;

  static Future<void> setDailyReminder(bool v) async =>
      (await SharedPreferences.getInstance()).setBool('notif_daily_reminder', v);

  static Future<bool> isMilestoneEnabled() async =>
      (await SharedPreferences.getInstance()).getBool('notif_milestone') ?? true;

  static Future<void> setMilestone(bool v) async =>
      (await SharedPreferences.getInstance()).setBool('notif_milestone', v);
}

// ── Banner widget ──────────────────────────────────────────────────────────────
class _NotifBanner extends StatefulWidget {
  final String emoji, title, message;
  final Color color;
  final VoidCallback onDismiss;

  const _NotifBanner({
    required this.emoji,
    required this.title,
    required this.message,
    required this.color,
    required this.onDismiss,
  });

  @override
  State<_NotifBanner> createState() => _NotifBannerState();
}

class _NotifBannerState extends State<_NotifBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16, right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onVerticalDragEnd: (d) {
                if (d.velocity.pixelsPerSecond.dy < -100) _dismiss();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2540),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: widget.color.withAlpha(100)),
                  boxShadow: [
                    BoxShadow(color: widget.color.withAlpha(50), blurRadius: 20),
                    const BoxShadow(color: Colors.black54, blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: widget.color.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(widget.emoji,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(widget.message,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11),
                              maxLines: 2),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Icon(Icons.close,
                          color: Colors.white.withAlpha(80), size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
