import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const linuxInit = LinuxInitializationSettings(defaultActionName: 'Open');
    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      linux: linuxInit,
    );
    await _plugin.initialize(settings);

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    await _scheduleDailyReminder();
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'taskflow_channel',
        'TaskFlow Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );
  }

  Future<void> notifyTaskCompleted(String title) async {
    await _plugin.show(
      title.hashCode,
      'Task completed',
      '"$title" has been marked as done.',
      _details(),
    );
  }

  Future<void> notifyDueSoon(String title, DateTime dueDate) async {
    final oneDayBefore = dueDate.subtract(const Duration(days: 1));
    if (oneDayBefore.isBefore(DateTime.now())) return;

    if (!Platform.isAndroid && !Platform.isIOS) return;

    final scheduled = tz.TZDateTime(
      tz.local,
      oneDayBefore.year,
      oneDayBefore.month,
      oneDayBefore.day,
      9,
    );

    await _plugin.zonedSchedule(
      dueDate.millisecondsSinceEpoch ~/ 1000,
      'Task due tomorrow',
      '"$title" is due on ${dueDate.day}/${dueDate.month}.',
      scheduled,
      _details(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _scheduleDailyReminder() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final now = tz.TZDateTime.now(tz.local);
    var nextNine = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    if (nextNine.isBefore(now)) {
      nextNine = nextNine.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      99999,
      'TaskFlow Reminder',
      'Review your tasks for today.',
      nextNine,
      _details(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
