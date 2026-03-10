import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ── Background handler (top-level, required by FCM) ───────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('[FCM] Background message: ${message.messageId}');
}

// ── Notification Service ───────────────────────────────────────────────────────
class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();
  static final _db   = FirebaseFirestore.instance;

  // In-app overlay key — set this from main.dart
  static final navigatorKey = GlobalKey<NavigatorState>();

  // Android notification channel
  static const _channel = AndroidNotificationChannel(
    'fitmetrics_mentions',
    'Mentions',
    description: 'Notifications when someone mentions you in Community',
    importance: Importance.high,
    playSound: true,
  );

  // ── Init ────────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    developer.log('[FCM] Permission: ${settings.authorizationStatus}');

    // Init local notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android channel
    await _local
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Save token & listen for refresh
    await _saveToken();
    _fcm.onTokenRefresh.listen(_saveTokenString);
  }

  // ── Save FCM token to Firestore ─────────────────────────────────────────────
  static Future<void> _saveToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final token = await _fcm.getToken();
      if (token != null) await _saveTokenString(token);
    } catch (e) {
      developer.log('[FCM] Token save error: $e');
    }
  }

  static Future<void> _saveTokenString(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('tokens')
          .doc('fcm')
          .set({'token': token, 'updatedAt': FieldValue.serverTimestamp()});
      developer.log('[FCM] Token saved');
    } catch (e) {
      developer.log('[FCM] Token save error: $e');
    }
  }

  // ── Foreground message → show local notification ────────────────────────────
  static void _onForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _local.show(
      message.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Navigate to community tab when notification tapped
    developer.log('[FCM] Notification tapped: ${response.payload}');
  }

  // ── Send in-app mention notification via Firestore ──────────────────────────
  // Called when a message with @mentions is sent.
  // Writes to users/{uid}/notifications/{auto-id} — the target user's app
  // listens to this collection and shows an in-app banner.
  static Future<void> sendMentionNotification({
    required String mentionedUid,
    required String senderName,
    required String messageText,
    required String messageId,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(mentionedUid)
          .collection('notifications')
          .add({
        'type': 'mention',
        'senderName': senderName,
        'messageText': messageText,
        'messageId': messageId,
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('[Notification] sendMention error: $e');
    }
  }

  // ── Show local in-app notification banner ───────────────────────────────────
  static void showInAppBanner({
    required BuildContext context,
    required String senderName,
    required String messageText,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _MentionBanner(
        senderName: senderName,
        messageText: messageText,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }
}

// ── In-App Banner Widget ───────────────────────────────────────────────────────
class _MentionBanner extends StatefulWidget {
  final String senderName;
  final String messageText;
  final VoidCallback onDismiss;

  const _MentionBanner({
    required this.senderName,
    required this.messageText,
    required this.onDismiss,
  });

  @override
  State<_MentionBanner> createState() => _MentionBannerState();
}

class _MentionBannerState extends State<_MentionBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
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
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2540),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3B82F6).withAlpha(80)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.alternate_email_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.senderName} mentioned you',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(widget.messageText,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _dismiss,
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white38, size: 18),
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