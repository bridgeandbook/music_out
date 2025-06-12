import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:music_out/config/app_config.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final _locationController = StreamController<LatLng>.broadcast();
  Stream<LatLng> get locationStream => _locationController.stream;

  Timer? _locationTimer;
  bool _isTracking = false;

  // 位置情報の取得を開始
  Future<void> startTracking() async {
    if (_isTracking) return;

    // 位置情報の権限を確認
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    _isTracking = true;
    _locationTimer = Timer.periodic(
      Duration(milliseconds: AppConfig.locationUpdateInterval),
      (_) => _updateLocation(),
    );

    // 初回の位置情報を取得
    await _updateLocation();
  }

  // 位置情報の取得を停止
  void stopTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isTracking = false;
  }

  // 位置情報を更新
  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _locationController.add(LatLng(position.latitude, position.longitude));
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // 現在の位置情報を取得
  Future<LatLng?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // 2点間の距離を計算（メートル単位）
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }
} 