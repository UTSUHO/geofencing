import 'package:flutter/material.dart';
import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerScreen({super.key, this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ??
        const LatLng(39.9042, 116.4074); // Default: Beijing
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _confirm() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirm,
          ),
        ],
      ),
      body: AMapWidget(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation!,
          zoom: 15,
        ),
        markers: _selectedLocation == null
            ? {}
            : {
                Marker(
                  position: _selectedLocation!,
                ),
              },
        onTap: _onMapTap,
      ),
    );
  }
}
