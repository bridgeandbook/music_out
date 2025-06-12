import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:music_out/services/location_service.dart';
import 'package:music_out/services/area_service.dart';
import 'package:music_out/services/audio_service.dart';
import 'package:music_out/services/settings_service.dart';
import 'package:music_out/models/location_area.dart';
import 'package:music_out/screens/map/add_area_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final AreaService _areaService = AreaService();
  final AudioService _audioService = AudioService();
  final SettingsService _settingsService = SettingsService();

  GoogleMapController? _mapController;
  Set<Circle> _circles = {};
  LocationArea? _currentArea;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _settingsService.init();
    await _areaService.loadAreas();
    await _locationService.initialize();
    _updateMapCircles();
    _startLocationTracking();
    setState(() => _isLoading = false);
  }

  void _updateMapCircles() {
    _circles = _areaService.areas.map((area) {
      return Circle(
        circleId: CircleId(area.id),
        center: area.center,
        radius: area.radius,
        fillColor: area.isActive
            ? Colors.blue.withOpacity(0.3)
            : Colors.grey.withOpacity(0.3),
        strokeColor: area.isActive ? Colors.blue : Colors.grey,
        strokeWidth: 2,
      );
    }).toSet();
  }

  void _startLocationTracking() {
    _locationService.locationStream.listen((position) {
      final location = LatLng(position.latitude, position.longitude);
      _updateCurrentLocation(location);
      _checkAreaTransition(location);
    });
  }

  void _updateCurrentLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(location),
    );
  }

  void _checkAreaTransition(LatLng location) {
    final newArea = _areaService.getAreaForLocation(location);
    if (newArea != _currentArea) {
      _currentArea = newArea;
      if (newArea != null && newArea.musicPath != null) {
        _audioService.playMusic(newArea.musicPath!);
      } else {
        _audioService.stopMusic();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Out'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 設定画面への遷移
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(35.6812, 139.7671), // 東京駅
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            circles: _circles,
          ),
          if (_currentArea != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentArea!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (_currentArea!.musicPath != null)
                        Text(
                          'Now Playing: ${_currentArea!.musicPath}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final position = await _locationService.getCurrentLocation();
          if (position != null && mounted) {
            final result = await Navigator.push<LocationArea>(
              context,
              MaterialPageRoute(
                builder: (context) => AddAreaScreen(
                  initialPosition: LatLng(
                    position.latitude,
                    position.longitude,
                  ),
                ),
              ),
            );
            if (result != null) {
              _updateMapCircles();
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _locationService.dispose();
    _areaService.dispose();
    _audioService.dispose();
    _settingsService.dispose();
    super.dispose();
  }
} 