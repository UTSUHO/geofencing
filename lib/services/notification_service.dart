import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
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
      final initResult = await _plugin.initialize(initSettings);
      log('Notification plugin initialized: $initResult');

      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final hasAlert = await _hasRawResource('alert');
        log('Custom alert sound present: $hasAlert');
        await androidPlugin?.createNotificationChannel(
          AndroidNotificationChannel(
            'geofence_entry_channel_v2',
            'Geofence Entry Alerts',
            description: 'Notifications triggered when entering a geofence',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
            sound: hasAlert ? const RawResourceAndroidNotificationSound('alert') : null,
          ),
        );
        log('Notification channel created');
      }
    } catch (e, st) {
      log('Notification initialization failed', error: e, stackTrace: st);
    }
  }

  Future<bool> _hasRawResource(String name) async {
    // For now, assume custom sound is not bundled. Place alert.mp3 in
    // android/app/src/main/res/raw/ and change this to true to use it.
    return false;
  }

  Future<void> showGeofenceEntryNotification(String geofenceName) async {
    try {
      final bool hasAlertSound = await _hasRawResource('alert');
      final androidDetails = AndroidNotificationDetails(
        'geofence_entry_channel',
        'Geofence Entry Alerts',
        channelDescription: 'Notifications triggered when entering a geofence',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        sound: hasAlertSound ? const RawResourceAndroidNotificationSound('alert') : null,
        ticker: 'Geofence Alert',
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );

      const darwinDetails = DarwinNotificationDetails(
        sound: 'alert.caf',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _plugin.show(
        geofenceName.hashCode,
        'Entered Geofence',
        'You have entered "$geofenceName"',
        details,
      );
      log('Notification shown for $geofenceName');
    } catch (e, st) {
      log('Failed to show notification', error: e, stackTrace: st);
    }
  }
}
