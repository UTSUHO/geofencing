import 'dart:developer';

import 'package:geofencing_service/geofencing_service.dart';

import '../models/geofence_model.dart';
import 'notification_service.dart';

// Top-level callback invoked by the OS when a geofence event occurs.
// Must be static/top-level and annotated with vm:entry-point.
@pragma('vm:entry-point')
void geofenceCallback(
    List<String> ids, Location location, GeofenceEvent event) {
  log('Geofence callback: ids=$ids event=$event location=$location');
  if (event == GeofenceEvent.enter) {
    // Since the app may be killed, we cannot rely on in-memory state.
    // Initialize the notification plugin directly in this isolate context.
    final notificationService = NotificationService();
    notificationService.initialize().then((_) {
      for (final id in ids) {
        notificationService.showGeofenceEntryNotification(id);
      }
    });
  }
}

class GeofencingServiceManager {
  static final GeofencingServiceManager _instance =
      GeofencingServiceManager._internal();
  factory GeofencingServiceManager() => _instance;
  GeofencingServiceManager._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await GeofencingManager.initialize();
    _initialized = true;
  }

  Future<void> registerGeofences(List<GeofenceModel> geofences) async {
    if (!_initialized) await initialize();

    // Remove all existing geofences first to avoid duplicates.
    await GeofencingManager.removeAllGeofences();

    final activeGeofences = geofences.where((g) => g.isEnabled).toList();

    // iOS limits the number of monitored regions to ~20.
    final limitedGeofences = activeGeofences.length > GeofencingManager.maxGeofences
        ? activeGeofences.sublist(0, GeofencingManager.maxGeofences)
        : activeGeofences;

    log('Registering ${limitedGeofences.length} geofences with OS');
    for (final geofence in limitedGeofences) {
      log('Register geofence: id=${geofence.id} lat=${geofence.latitude} lng=${geofence.longitude} radius=${geofence.radius}m');
      await GeofencingManager.registerGeofence(
        GeofenceRegion(
          geofence.id,
          geofence.latitude,
          geofence.longitude,
          geofence.radius,
          [GeofenceEvent.enter],
          AndroidGeofencingSettings(),
        ),
        geofenceCallback,
      );
    }
  }

  Future<void> removeAll() async {
    if (!_initialized) return;
    await GeofencingManager.removeAllGeofences();
  }
}
