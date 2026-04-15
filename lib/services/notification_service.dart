import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await _plugin.initialize(initSettings);

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'geofence_entry_channel',
          'Geofence Entry Alerts',
          description: 'Notifications triggered when entering a geofence',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alert'),
        ),
      );
    }
  }

  Future<void> showGeofenceEntryNotification(String geofenceName) async {
    const androidDetails = AndroidNotificationDetails(
      'geofence_entry_channel',
      'Geofence Entry Alerts',
      channelDescription: 'Notifications triggered when entering a geofence',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alert'),
      ticker: 'Geofence Alert',
    );

    const darwinDetails = DarwinNotificationDetails(
      sound: 'alert.caf',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.show(
      geofenceName.hashCode,
      'Entered Geofence',
      'You have entered "$geofenceName"',
      details,
    );
  }
}
