import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // For debugPrint


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // FIX: Explicitly using 'settings:' (Named Parameter)
    await _notificationsPlugin.initialize(
      settings: initializationSettings, 
    );
    debugPrint("✅ Notifications Initialized Successfully!");
    
    // Request permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // Play Sound
    FlutterRingtonePlayer().playNotification();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'aura_timer_channel',
      'Timer Alerts',
      channelDescription: 'Notifications for Pomodoro Timer',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    // FIX: Using named parameters for show()
    await _notificationsPlugin.show(
      id: 0, 
      title: title, 
      body: body, 
      notificationDetails: details,
    );
  }
}
