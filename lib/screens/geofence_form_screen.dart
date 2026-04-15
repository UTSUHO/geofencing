import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/geofence_model.dart';
import '../providers/geofence_list_provider.dart';
import 'map_picker_screen.dart';

class GeofenceFormScreen extends ConsumerStatefulWidget {
  final GeofenceModel? geofence;

  const GeofenceFormScreen({super.key, this.geofence});

  @override
  ConsumerState<GeofenceFormScreen> createState() => _GeofenceFormScreenState();
}

class _GeofenceFormScreenState extends ConsumerState<GeofenceFormScreen> {
  final _nameController = TextEditingController();
  double _radius = 500;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.geofence != null) {
      _nameController.text = widget.geofence!.name;
      _radius = widget.geofence!.radius;
      _selectedLocation = LatLng(
        widget.geofence!.latitude,
        widget.geofence!.longitude,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialLocation: _selectedLocation),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name and pick a location.')),
      );
      return;
    }

    final geofence = GeofenceModel(
      id: widget.geofence?.id ?? const Uuid().v4(),
      name: name,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      radius: _radius,
      isEnabled: widget.geofence?.isEnabled ?? true,
    );

    if (widget.geofence != null) {
      ref.read(geofenceListProvider.notifier).updateGeofence(geofence);
    } else {
      ref.read(geofenceListProvider.notifier).add(geofence);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.geofence == null ? 'New Geo-fence' : 'Edit Geo-fence'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Radius:'),
                Expanded(
                  child: Slider(
                    value: _radius,
                    min: 100,
                    max: 5000,
                    divisions: 49,
                    label: '${_radius.toStringAsFixed(0)} m',
                    onChanged: (value) {
                      setState(() {
                        _radius = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text('${_radius.toStringAsFixed(0)}m'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map),
              label: Text(
                _selectedLocation == null
                    ? 'Pick Location on Map'
                    : 'Change Location',
              ),
            ),
            if (_selectedLocation != null) ...[
              const SizedBox(height: 8),
              Text(
                'Lat: ${_selectedLocation!.latitude.toStringAsFixed(5)}, '
                'Lng: ${_selectedLocation!.longitude.toStringAsFixed(5)}',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation!,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: _selectedLocation!,
                      ),
                    },
                    circles: {
                      Circle(
                        circleId: const CircleId('radius'),
                        center: _selectedLocation!,
                        radius: _radius,
                        fillColor: Colors.blue.withValues(alpha: 0.2),
                        strokeColor: Colors.blue,
                        strokeWidth: 2,
                      ),
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
