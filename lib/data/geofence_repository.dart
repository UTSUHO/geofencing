import 'package:hive/hive.dart';
import '../models/geofence_model.dart';

class GeofenceRepository {
  final Box<GeofenceModel> _box;

  GeofenceRepository(this._box);

  List<GeofenceModel> getAll() => _box.values.toList();

  Future<void> add(GeofenceModel geofence) async {
    await _box.put(geofence.id, geofence);
  }

  Future<void> update(GeofenceModel geofence) async {
    await _box.put(geofence.id, geofence);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleEnabled(String id, bool isEnabled) async {
    final item = _box.get(id);
    if (item != null) {
      item.isEnabled = isEnabled;
      await item.save();
    }
  }
}
