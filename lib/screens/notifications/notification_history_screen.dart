import 'package:flutter/material.dart';

// ── Model ──────────────────────────────────────────────────────────────────────
enum NotifType { rankBeaten, streak, sessionComplete, dailyReminder, streakBreak }

class AppNotification {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}

// ── Dummy notifications ────────────────────────────────────────────────────────
final List<AppNotification> dummyNotifications = [
  AppNotification(id: '1', type: NotifType.rankBeaten, title: 'You\'ve been overtaken!', body: 'ZenMaster just passed you. You\'re now #5 on the leaderboard.', time: DateTime.now().subtract(const Duration(minutes: 5))),
  AppNotification(id: '2', type: NotifType.sessionComplete, title: 'Session Complete! 🎉', body: 'Great job! 15 mins of meditation added to your score.', time: DateTime.now().subtract(const Duration(hours: 1)), isRead: true),
  AppNotification(id: '3', type: NotifType.streak, title: '5 Day Streak! 🔥', body: 'You\'re on fire! Keep going to maintain your streak.', time: DateTime.now().subtract(const Duration(hours: 3)), isRead: true),
  AppNotification(id: '4', type: NotifType.dailyReminder, title: 'Time to meditate! 🧘', body: 'You haven\'t meditated today. Start a quick 5-min session.', time: DateTime.now().subtract(const Duration(days: 1, hours: 2))),
  AppNotification(id: '5', type: NotifType.sessionComplete, title: 'Session Complete! 🎉', body: 'Amazing! 20 mins of movement meditation logged.', time: DateTime.now().subtract(const Duration(days: 1, hours: 5)), isRead: true),
  AppNotification(id: '6', type: NotifType.streakBreak, title: 'Don\'t break your streak!', body: 'You\'re about to lose your 4-day streak. Meditate now!', time: DateTime.now().subtract(const Duration(days: 2, hours: 1))),
  AppNotification(id: '7', type: NotifType.rankBeaten, title: 'New personal best! 🏆', body: 'You moved up to #3 on this week\'s leaderboard!', time: DateTime.now().subtract(const Duration(days: 3)), isRead: true),
  AppNotification(id: '8', type: NotifType.dailyReminder, title: 'Good morning! 🌅', body: 'Start your day with a 10-min meditation session.', time: DateTime.now().subtract(const Duration(days: 4)), isRead: true),
];

// ── Screen ─────────────────────────────────────────────────────────────────────
class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  final List<AppNotification> _notifications = List.from(dummyNotifications);

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) n.isRead = true;
    });
  }

  void _markRead(String id) {
    setState(() {
      final n = _notifications.firstWhere((n) => n.id == id);
      n.isRead = true;
    });
  }

  void _deleteNotification(String id) {
    setState(() => _notifications.removeWhere((n) => n.id == id));
  }

  Map<String, List<AppNotification>> get _grouped {
    final now = DateTime.now();
    final today = <AppNotification>[];
    final yesterday = <AppNotification>[];
    final earlier = <AppNotification>[];

    for (final n in _notifications) {
      final diff = now.difference(n.time).inDays;
      if (diff == 0) today.add(n);
      else if (diff == 1) yesterday.add(n);
      else earlier.add(n);
    }

    return {
      if (today.isNotEmpty) 'Today': today,
      if (yesterday.isNotEmpty) 'Yesterday': yesterday,
      if (earlier.isNotEmpty) 'Earlier': earlier,
    };
  }

  IconData _iconFor(NotifType type) {
    switch (type) {
      case NotifType.rankBeaten: return Icons.emoji_events;
      case NotifType.streak: return Icons.local_fire_department;
      case NotifType.sessionComplete: return Icons.check_circle_outline;
      case NotifType.dailyReminder: return Icons.alarm;
      case NotifType.streakBreak: return Icons.warning_amber_outlined;
    }
  }

  Color _colorFor(NotifType type) {
    switch (type) {
      case NotifType.rankBeaten: return const Color(0xFFFFD700);
      case NotifType.streak: return const Color(0xFFF59E0B);
      case NotifType.sessionComplete: return const Color(0xFF10B981);
      case NotifType.dailyReminder: return const Color(0xFF3B82F6);
      case NotifType.streakBreak: return const Color(0xFFEF4444);
    }
  }

  String _timeLabel(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays == 1)    return 'Yesterday ${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1624),
      body: SafeArea(
        child: Column(
          children: [

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withAlpha(35)),
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notifications',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        if (_unreadCount > 0)
                          Text('$_unreadCount unread',
                              style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllRead,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF3B82F6).withAlpha(60)),
                        ),
                        child: const Text('Mark all read',
                            style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none, color: Colors.white24, size: 64),
                    const SizedBox(height: 12),
                    const Text('No notifications yet',
                        style: TextStyle(color: Colors.white38, fontSize: 16)),
                  ],
                ),
              )
                  : ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: grouped.entries.expand((group) {
                  return [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(group.key,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12,
                              fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ),
                    ...group.value.map((n) => _NotifTile(
                      notification: n,
                      icon: _iconFor(n.type),
                      color: _colorFor(n.type),
                      timeLabel: _timeLabel(n.time),
                      onTap: () => _markRead(n.id),
                      onDelete: () => _deleteNotification(n.id),
                    )),
                  ];
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification tile ──────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final Color color;
  final String timeLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotifTile({
    required this.notification,
    required this.icon,
    required this.color,
    required this.timeLabel,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.redAccent.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? Colors.white.withAlpha(8) : color.withAlpha(15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead ? Colors.white.withAlpha(15) : color.withAlpha(50),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notification.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                              )),
                        ),
                        if (!isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notification.body,
                        style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4)),
                    const SizedBox(height: 6),
                    Text(timeLabel,
                        style: TextStyle(color: color.withAlpha(180), fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
