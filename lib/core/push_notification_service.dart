import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

/// Real push notifications that appear outside the app.
/// Shows 2-3 motivational notifications per day.
/// Call PushNotificationService.init() in main.dart once.
class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ── Init ────────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Request permissions (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
    await _scheduleDaily();
  }

  // ── Schedule 3 daily notifications ─────────────────────────────────────────
  static Future<void> _scheduleDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScheduled = prefs.getString('notif_scheduled_date') ?? '';
    final today =
        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';

    // Only schedule once per day
    if (lastScheduled == today) return;
    await prefs.setString('notif_scheduled_date', today);

    await _plugin.cancelAll();

    final now = DateTime.now();

    // Morning — 8:00 AM
    await _scheduleAt(
      id: 1,
      hour: 8,
      minute: 0,
      title: '🌅 Good Morning!',
      body: 'Start your day with 5 minutes of meditation. Your streak is waiting!',
    );

    // Afternoon — 1:00 PM
    await _scheduleAt(
      id: 2,
      hour: 13,
      minute: 0,
      title: '🧘 Midday Reset',
      body: 'Take a mindful break. A quick session recharges your focus.',
    );

    // Evening — 8:00 PM
    await _scheduleAt(
      id: 3,
      hour: 20,
      minute: 0,
      title: '🌙 Evening Wind Down',
      body: 'Don\'t break your streak! A 5 min session keeps you on track.',
    );
  }

  static Future<void> _scheduleAt({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduled, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'fitmetrics_daily',
            'Daily Reminders',
            channelDescription: 'FitMetrics daily meditation reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF3B82F6),
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime, // ← fix added
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Silently fail if exact alarms not permitted
    }
  }

  // ── Manual trigger for testing ──────────────────────────────────────────────
  static Future<void> showTestNotification() async {
    await _plugin.show(
      99,
      '🔥 FitMetrics Test',
      'Push notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fitmetrics_test',
          'Test Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ── Cancel all ──────────────────────────────────────────────────────────────
  static Future<void> cancelAll() async => _plugin.cancelAll();
}