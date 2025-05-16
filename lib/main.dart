import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final String accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  MapboxOptions.setAccessToken(accessToken);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapbox Marker on Tap')),
      body: MapWidget(
        styleUri: MapboxStyles.MAPBOX_STREETS,
        onMapCreated: _onMapCreated,
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Create the PointAnnotationManager
    _pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();

    // Add tap interaction to the map
    mapboxMap.addInteraction(
      TapInteraction.onMap((MapContentGestureContext context) async {
        print('clicked');
        final point = context.point;
        await _addMarker(point);
      }),
    );
  }

  Future<void> _addMarker(Point point) async {
    if (_pointAnnotationManager == null) return;

    // Optional: clear existing markers
    await _pointAnnotationManager!.deleteAll();

    final ByteData bytes = await rootBundle.load('assets/location.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Add new marker
    await _pointAnnotationManager!.create(PointAnnotationOptions(
      geometry: point,
      iconSize: 1.5,
      image: imageData,
    ));
  }
}
