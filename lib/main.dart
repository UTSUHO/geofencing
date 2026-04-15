import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/geofence_repository.dart';
import 'models/geofence_model.dart';
import 'providers/geofence_list_provider.dart';
import 'screens/geofence_list_screen.dart';
import 'services/geofencing_service.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(GeofenceModelAdapter());
  final box = await Hive.openBox<GeofenceModel>('geofences');
  final repository = GeofenceRepository(box);

  await NotificationService().initialize();
  await GeofencingServiceManager().initialize();

  // Re-register active geofences on startup.
  final activeGeofences = repository.getAll();
  await GeofencingServiceManager().registerGeofences(activeGeofences);

  // Request permissions on first launch.
  await PermissionService.requestLocationPermissions();

  runApp(
    ProviderScope(
      overrides: [
        geofenceRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo-fencing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GeofenceListScreen(),
    );
  }
}
