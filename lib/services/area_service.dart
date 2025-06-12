import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences.dart';
import 'package:music_out/models/location_area.dart';
import 'package:music_out/models/music_track.dart';

class AreaService {
  static final AreaService _instance = AreaService._internal();
  factory AreaService() => _instance;
  AreaService._internal();

  final _areasController = StreamController<List<LocationArea>>.broadcast();
  Stream<List<LocationArea>> get areasStream => _areasController.stream;

  List<LocationArea> _areas = [];
  List<LocationArea> get areas => List.unmodifiable(_areas);

  // エリアを追加
  Future<void> addArea(LocationArea area) async {
    _areas.add(area);
    await _saveAreas();
    _areasController.add(_areas);
  }

  // エリアを更新
  Future<void> updateArea(LocationArea area) async {
    final index = _areas.indexWhere((a) => a.id == area.id);
    if (index != -1) {
      _areas[index] = area;
      await _saveAreas();
      _areasController.add(_areas);
    }
  }

  // エリアを削除
  Future<void> deleteArea(String areaId) async {
    _areas.removeWhere((area) => area.id == areaId);
    await _saveAreas();
    _areasController.add(_areas);
  }

  // 現在位置が含まれるエリアを取得
  LocationArea? getAreaForLocation(LatLng location) {
    for (final area in _areas) {
      if (area.containsLocation(location)) {
        return area;
      }
    }
    return null;
  }

  // エリアを保存
  Future<void> _saveAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final areasJson = _areas.map((area) => jsonEncode(area.toJson())).toList();
    await prefs.setStringList('areas', areasJson);
  }

  // エリアを読み込み
  Future<void> loadAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final areasJson = prefs.getStringList('areas') ?? [];
    _areas = areasJson
        .map((json) => LocationArea.fromJson(jsonDecode(json)))
        .toList();
    _areasController.add(_areas);
  }

  // リソースを解放
  void dispose() {
    _areasController.close();
  }
} 