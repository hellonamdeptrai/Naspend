import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Khởi tạo cài đặt cho Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon');

    // Khởi tạo cài đặt cho iOS (cần yêu cầu quyền)
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification tapped: ${response.payload}');
      },
    );

    // Khởi tạo timezone
    tz.initializeTimeZones();
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final DateTime now = DateTime.now();

    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return tz.TZDateTime.from(scheduledDate, tz.local);
  }

  Future<void> requestAndroidPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // Yêu cầu quyền hiển thị thông báo (cho Android 13+)
      await androidImplementation?.requestNotificationsPermission();

      // Yêu cầu quyền đặt báo thức chính xác
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID của thông báo
      'Đừng quên ghi chép nhé!',
      'Hôm nay bạn đã chi tiêu những gì? Hãy ghi lại ngay.',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel_id',
          'Nhắc nhở hàng ngày',
          channelDescription: 'Kênh thông báo nhắc nhở ghi chép chi tiêu hàng ngày',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Lặp lại hàng ngày vào đúng giờ này
    );
  }

  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<bool> arePermissionsGranted() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? notificationsEnabled =
      await androidImplementation?.areNotificationsEnabled();
      final bool? exactAlarmsEnabled =
      await androidImplementation?.canScheduleExactNotifications();

      return (notificationsEnabled ?? false) && (exactAlarmsEnabled ?? false);
    }
    return true;
  }

}