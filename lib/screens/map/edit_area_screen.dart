import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_out/models/location_area.dart';
import 'package:music_out/models/music_track.dart';
import 'package:music_out/services/area_service.dart';
import 'package:music_out/services/location_service.dart';
import 'package:music_out/screens/music/music_selection_screen.dart';

class EditAreaScreen extends StatefulWidget {
  final LocationArea area;

  const EditAreaScreen({
    super.key,
    required this.area,
  });

  @override
  State<EditAreaScreen> createState() => _EditAreaScreenState();
}

class _EditAreaScreenState extends State<EditAreaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _radiusController = TextEditingController();
  final _areaService = AreaService();
  final _locationService = LocationService();

  late LatLng _center;
  late double _radius;
  GoogleMapController? _mapController;
  Set<Circle> _circles = {};
  String? _musicPath;

  @override
  void initState() {
    super.initState();
    _center = widget.area.center;
    _radius = widget.area.radius;
    _nameController.text = widget.area.name;
    _radiusController.text = _radius.toString();
    _updateCircle();
  }

  void _updateCircle() {
    setState(() {
      _circles = {
        Circle(
          circleId: CircleId(widget.area.id),
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
      final updatedArea = widget.area.copyWith(
        name: _nameController.text,
        center: _center,
        radius: _radius,
        musicPath: _musicPath,
      );

      await _areaService.updateArea(updatedArea);
      if (mounted) {
        Navigator.pop(context, updatedArea);
      }
    }
  }

  Future<void> _deleteArea() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エリアを削除'),
        content: const Text('このエリアを削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _areaService.deleteArea(widget.area.id);
      Navigator.pop(context, 'deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エリアを編集'),
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
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteArea,
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
                  ListTile(
                    leading: const Icon(Icons.music_note),
                    title: const Text('音楽ファイル'),
                    subtitle: widget.area.musicPath != null
                        ? Text(widget.area.musicPath!)
                        : const Text('音楽ファイルを選択'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final track = await Navigator.push<MusicTrack>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MusicSelectionScreen(
                            selectedTrackId: widget.area.musicPath,
                          ),
                        ),
                      );
                      if (track != null) {
                        setState(() {
                          _musicPath = track.filePath;
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