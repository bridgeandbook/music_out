import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_out/services/area_service.dart';
import 'package:music_out/services/location_service.dart';
import 'package:music_out/models/location_area.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AreaService _areaService = AreaService();
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  Set<Circle> _circles = {};
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _areaService.loadAreas();
    await _locationService.initialize();
    _locationService.locationStream.listen((position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _updateMarkers();
      });
    });
    _updateCircles();
    setState(() => _isLoading = false);
  }

  void _updateCircles() {
    setState(() {
      _circles = _areaService.areas.map((area) {
        return Circle(
          circleId: CircleId(area.id),
          center: area.center,
          radius: area.radius,
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        );
      }).toSet();
    });
  }

  void _updateMarkers() {
    if (_currentLocation != null) {
      _markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      };
    }
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 設定画面への遷移
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 地図部分
            Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _currentLocation ?? const LatLng(35.6812, 139.7671),
                            zoom: 15,
                          ),
                          myLocationEnabled: false,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          circles: _circles,
                          markers: _markers,
                          onMapCreated: (controller) => _mapController = controller,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        mini: true,
                        heroTag: 'location',
                        onPressed: _moveToCurrentLocation,
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 再生情報カード
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black, width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Now playing', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Song Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Artist Name', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            // プレーヤー部分
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // シークバー
                  Row(
                    children: const [
                      Text('0:45'),
                      Expanded(
                        child: Slider(
                          value: 0.3,
                          onChanged: null, // TODO: 実装
                        ),
                      ),
                      Text('-2:30'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // コントロールボタン
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 36),
                        onPressed: null, // TODO: 実装
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: CircleAvatar(
                          radius: 32,
                          child: Icon(Icons.play_arrow, size: 40),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 36),
                        onPressed: null, // TODO: 実装
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _locationService.dispose();
    _areaService.dispose();
    super.dispose();
  }
} 