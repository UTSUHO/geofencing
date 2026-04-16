import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:amap_map/amap_map.dart';
import 'package:x_amap_base/x_amap_base.dart';

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

void _initAmap(BuildContext context) {
  AMapInitializer.init(
    context,
    apiKey: const AMapApiKey(
      androidKey: 'e26568e364f15cb982f0f62851feb4ec',
      iosKey: 'YOUR_AMAP_IOS_KEY',
    ),
  );
  AMapInitializer.updatePrivacyAgree(
    const AMapPrivacyStatement(
      hasContains: true,
      hasShow: true,
      hasAgree: true,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _initAmap(context);
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
