import 'package:flutter/material.dart';
import 'package:fitmetrics/services/firestore_service.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await FirestoreService.getNotificationHistory();
    if (mounted) setState(() { _notifications = data; _isLoading = false; });
  }

  Future<void> _markAllRead() async {
    await FirestoreService.markNotificationsRead();
    setState(() {
      for (final n in _notifications) n['read'] = true;
    });
  }

  Future<void> _markRead(String id) async {
    await FirestoreService.markSingleNotificationRead(id);
    setState(() {
      final idx = _notifications.indexWhere((n) => n['id'] == id);
      if (idx != -1) _notifications[idx]['read'] = true;
    });
  }

  void _delete(String id) {
    setState(() => _notifications.removeWhere((n) => n['id'] == id));
    FirestoreService.deleteNotification(id);
  }

  int get _unreadCount => _notifications.where((n) => n['read'] != true).length;

  Map<String, List<Map<String, dynamic>>> get _grouped {
    final now = DateTime.now();
    final today = <Map<String, dynamic>>[];
    final yesterday = <Map<String, dynamic>>[];
    final earlier = <Map<String, dynamic>>[];
    for (final n in _notifications) {
      final createdAt = DateTime.tryParse(n['createdAt'] ?? '') ?? now;
      final diff = now.difference(createdAt).inDays;
      if (diff == 0) today.add(n);
      else if (diff == 1) yesterday.add(n);
      else earlier.add(n);
    }
    return {
      if (today.isNotEmpty)     'Today': today,
      if (yesterday.isNotEmpty) 'Yesterday': yesterday,
      if (earlier.isNotEmpty)   'Earlier': earlier,
    };
  }

  String _timeLabel(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays == 1)    return 'Yesterday ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    return '${diff.inDays} days ago';
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'community': return Icons.people_alt_outlined;
      case 'streak':    return Icons.local_fire_department;
      case 'session':   return Icons.check_circle_outline;
      case 'reminder':  return Icons.alarm;
      case 'rank':      return Icons.emoji_events;
      default:          return Icons.notifications_outlined;
    }
  }

  Color _colorFor(String? type) {
    switch (type) {
      case 'community': return const Color(0xFF8B5CF6);
      case 'streak':    return const Color(0xFFF59E0B);
      case 'session':   return const Color(0xFF10B981);
      case 'reminder':  return const Color(0xFF3B82F6);
      case 'rank':      return const Color(0xFFFFD700);
      default:          return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
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

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                  : _notifications.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none, color: Colors.white24, size: 64),
                    const SizedBox(height: 12),
                    const Text('No notifications yet',
                        style: TextStyle(color: Colors.white38, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('Activity notifications will appear here',
                        style: TextStyle(color: Colors.white24, fontSize: 13)),
                  ],
                ),
              )
                  : RefreshIndicator(
                color: const Color(0xFF3B82F6),
                backgroundColor: const Color(0xFF1A2540),
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: _grouped.entries.expand((group) => [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(group.key,
                          style: const TextStyle(color: Colors.white54, fontSize: 12,
                              fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ),
                    ...group.value.map((n) {
                      final isRead = n['read'] == true;
                      final type = n['type'] as String?;
                      final color = _colorFor(type);
                      final id = n['id'] as String? ?? '';
                      return Dismissible(
                        key: Key(id),
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
                        onDismissed: (_) => _delete(id),
                        child: GestureDetector(
                          onTap: () => _markRead(id),
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
                                  decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
                                  child: Icon(_iconFor(type), color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Expanded(
                                          child: Text(n['title'] ?? '',
                                              style: TextStyle(color: Colors.white, fontSize: 14,
                                                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w700)),
                                        ),
                                        if (!isRead)
                                          Container(width: 8, height: 8,
                                              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                      ]),
                                      const SizedBox(height: 4),
                                      Text(n['body'] ?? '',
                                          style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4)),
                                      const SizedBox(height: 6),
                                      Text(_timeLabel(n['createdAt']),
                                          style: TextStyle(color: color.withAlpha(180), fontSize: 11, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ]).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}