import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service wrapping `flutter_local_notifications` for persistent
/// medication reminders.
///
/// This is local-only with no backend. When a medication event is within
/// its scheduled window and remains pending, the app can show repeated local
/// notifications while the app is alive.
class ReminderService {
  ReminderService();

  static const int fallbackIntervalMinutes = 30;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _available = false;

  bool get isAvailable => _available;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(settings);
      _available = true;
    } catch (e) {
      debugPrint(
        'ReminderService: init failed, continuing without notifications. $e',
      );
      _available = false;
    } finally {
      _initialized = true;
    }
  }

  Future<void> showReminder({
    required String eventId,
    required String title,
    required String body,
  }) async {
    if (!_initialized || !_available) {
      debugPrint('ReminderService: not available, skipping showReminder');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'medtrack_medication_reminders',
          'Medication Reminders',
          channelDescription: 'Persistent reminders for pending medications',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _plugin.show(_notificationId(eventId), title, body, details);
    } catch (e) {
      debugPrint('ReminderService: showReminder failed, continuing safely. $e');
    }
  }

  Future<void> cancelReminder(String eventId) async {
    if (!_initialized || !_available) {
      return;
    }

    try {
      await _plugin.cancel(_notificationId(eventId));
    } catch (e) {
      debugPrint(
        'ReminderService: cancelReminder failed, continuing safely. $e',
      );
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized || !_available) {
      return;
    }

    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('ReminderService: cancelAll failed, continuing safely. $e');
    }
  }

  int _notificationId(String eventId) => eventId.hashCode & 0x7FFFFFFF;
}
