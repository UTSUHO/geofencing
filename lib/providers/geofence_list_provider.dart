import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_amap_base/x_amap_base.dart';

import '../data/geofence_repository.dart';
import '../models/geofence_model.dart';
import '../services/geofencing_service.dart';

final geofenceRepositoryProvider = Provider<GeofenceRepository>((ref) {
  throw UnimplementedError('Override this provider in main.dart');
});

final geofenceListProvider =
    AsyncNotifierProvider<GeofenceListNotifier, List<GeofenceModel>>(
  GeofenceListNotifier.new,
);

class GeofenceListNotifier extends AsyncNotifier<List<GeofenceModel>> {
  @override
  Future<List<GeofenceModel>> build() async {
    final repo = ref.read(geofenceRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(GeofenceModel geofence) async {
    final repo = ref.read(geofenceRepositoryProvider);
    await repo.add(geofence);
    await _refreshAndSync();
  }

  Future<void> updateGeofence(GeofenceModel geofence) async {
    final repo = ref.read(geofenceRepositoryProvider);
    await repo.update(geofence);
    await _refreshAndSync();
  }

  Future<void> delete(String id) async {
    final repo = ref.read(geofenceRepositoryProvider);
    await repo.delete(id);
    await _refreshAndSync();
  }

  Future<void> toggleEnabled(String id, bool isEnabled) async {
    final repo = ref.read(geofenceRepositoryProvider);
    await repo.toggleEnabled(id, isEnabled);
    await _refreshAndSync();
  }

  Future<void> _refreshAndSync() async {
    final repo = ref.read(geofenceRepositoryProvider);
    final list = repo.getAll();
    state = AsyncData(list);
    log('Syncing ${list.length} geofences to OS (enabled: ${list.where((g) => g.isEnabled).length})');
    await GeofencingServiceManager().registerGeofences(list);
  }
}

final selectedLocationProvider = StateProvider<LatLng?>((ref) => null);
