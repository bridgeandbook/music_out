import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_out/models/location_area.dart';
import 'package:music_out/services/area_service.dart';
import 'package:music_out/services/location_service.dart';

class AddAreaScreen extends StatefulWidget {
  final LatLng initialPosition;

  const AddAreaScreen({
    super.key,
    required this.initialPosition,
  });

  @override
  State<AddAreaScreen> createState() => _AddAreaScreenState();
}

class _AddAreaScreenState extends State<AddAreaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _radiusController = TextEditingController(text: '100');
  final _areaService = AreaService();
  final _locationService = LocationService();

  LatLng _center = const LatLng(35.6812, 139.7671);
  double _radius = 100;
  GoogleMapController? _mapController;
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _center = widget.initialPosition;
    _updateCircle();
  }

  void _updateCircle() {
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId('new_area'),
          center: _center,
          radius: _radius,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      };
    });
  }

  Future<void> _saveArea() async {
    if (_formKey.currentState?.validate() ?? false) {
      final area = LocationArea(
        name: _nameController.text,
        center: _center,
        radius: _radius,
      );

      await _areaService.addArea(area);
      if (mounted) {
        Navigator.pop(context, area);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エリアを追加'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              final position = await _locationService.getCurrentLocation();
              if (position != null) {
                setState(() {
                  _center = LatLng(position.latitude, position.longitude);
                  _updateCircle();
                });
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(_center),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15,
              ),
              onMapCreated: (controller) => _mapController = controller,
              circles: _circles,
              onTap: (position) {
                setState(() {
                  _center = position;
                  _updateCircle();
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'エリア名',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'エリア名を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _radiusController,
                    decoration: const InputDecoration(
                      labelText: '半径（メートル）',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '半径を入力してください';
                      }
                      final radius = double.tryParse(value);
                      if (radius == null || radius <= 0) {
                        return '有効な数値を入力してください';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final radius = double.tryParse(value);
                      if (radius != null && radius > 0) {
                        setState(() {
                          _radius = radius;
                          _updateCircle();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveArea,
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _radiusController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
} 