import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() => _notificationService;

  NotificationService._internal();

  Future<void> initNotification() async {
    await AwesomeNotifications().initialize(
      // Set to null to use app icon by default
      null,
      [
        NotificationChannel(
          channelKey: 'default_channel',
          channelName: 'Notificaciones generales',
          channelDescription: 'Avisos y recordatorios generales',
          defaultColor: const Color(0xFF3879B8),
          ledColor: const Color(0xFF3879B8),
          importance: NotificationImportance.Max,
          channelShowBadge: true,
        ),
      ],
      debug: false,
    );

    // Request permissions when not granted
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // Schedules a notification for today at the given hour (0-23).
  // Returns the notification id on success, or -1 if the time is in the past.
  Future<int> zonedScheduleNotification(
      int id, int hour, String title, String body) async {
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, hour, 0, 2);

    if (scheduled.isBefore(now)) {
      return -1;
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'default_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          year: scheduled.year,
          month: scheduled.month,
          day: scheduled.day,
          hour: scheduled.hour,
          minute: scheduled.minute,
          second: scheduled.second,
          millisecond: 0,
          repeats: false,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );
      return id;
    } catch (_) {
      return -1;
    }
  }
}
