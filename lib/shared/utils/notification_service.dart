import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId      = 'omnigarden_alerts';
  static const _channelName    = 'Garden Alerts';
  static const _channelDesc    = 'Planting and harvest reminders';

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const linux   = LinuxInitializationSettings(defaultActionName: 'Open');
    const ios   = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: ios,
        macOS: ios,
        linux: linux,
      ),
    );
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ── Schedule a single notification ───────────────────────
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Skip if date is in the past
    if (scheduledDate.isBefore(DateTime.now())) return;

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: const AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          linux: const LinuxNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Fall back to inexact if exact alarms not permitted
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: const AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          linux: const LinuxNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // ── Show immediate notification ───────────────────────────
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        linux: LinuxNotificationDetails(),
      ),
    );
  }

  // ── Cancel all notifications ──────────────────────────────
  Future<void> cancelAll() async => _plugin.cancelAll();

  Future<void> cancel(int id) async => _plugin.cancel(id);
}
