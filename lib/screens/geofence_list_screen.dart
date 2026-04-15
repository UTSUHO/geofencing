import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/geofence_list_provider.dart';
import 'geofence_form_screen.dart';

class GeofenceListScreen extends ConsumerWidget {
  const GeofenceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geofencesAsync = ref.watch(geofenceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo-fences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              // Optional: open settings or permission check
            },
          ),
        ],
      ),
      body: geofencesAsync.when(
        data: (geofences) {
          if (geofences.isEmpty) {
            return const Center(
              child: Text('No geo-fences yet. Tap + to create one.'),
            );
          }
          return ListView.builder(
            itemCount: geofences.length,
            itemBuilder: (context, index) {
              final g = geofences[index];
              return ListTile(
                title: Text(g.name),
                subtitle: Text(
                  'Lat: ${g.latitude.toStringAsFixed(5)}, '
                  'Lng: ${g.longitude.toStringAsFixed(5)} | '
                  'Radius: ${g.radius.toStringAsFixed(0)}m',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: g.isEnabled,
                      onChanged: (value) {
                        ref
                            .read(geofenceListProvider.notifier)
                            .toggleEnabled(g.id, value);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ref.read(geofenceListProvider.notifier).delete(g.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GeofenceFormScreen(geofence: g),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GeofenceFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
