import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class LocationArea {
  final String id;
  final String name;
  final LatLng center;
  final double radius; // メートル単位
  final String? musicPath;
  final bool isActive;

  LocationArea({
    String? id,
    required this.name,
    required this.center,
    required this.radius,
    this.musicPath,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  // 指定された位置がこのエリア内にあるかどうかを判定
  bool containsLocation(LatLng location) {
    final distance = _calculateDistance(center, location);
    return distance <= radius;
  }

  // 2点間の距離を計算（メートル単位）
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // 地球の半径（メートル）
    final lat1 = point1.latitude * (pi / 180);
    final lat2 = point2.latitude * (pi / 180);
    final dLat = (point2.latitude - point1.latitude) * (pi / 180);
    final dLon = (point2.longitude - point1.longitude) * (pi / 180);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // JSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'center': {
        'latitude': center.latitude,
        'longitude': center.longitude,
      },
      'radius': radius,
      'musicPath': musicPath,
      'isActive': isActive,
    };
  }

  // JSONからオブジェクトを生成
  factory LocationArea.fromJson(Map<String, dynamic> json) {
    return LocationArea(
      id: json['id'],
      name: json['name'],
      center: LatLng(
        json['center']['latitude'],
        json['center']['longitude'],
      ),
      radius: json['radius'],
      musicPath: json['musicPath'],
      isActive: json['isActive'],
    );
  }

  // コピーを作成
  LocationArea copyWith({
    String? name,
    LatLng? center,
    double? radius,
    String? musicPath,
    bool? isActive,
  }) {
    return LocationArea(
      id: id,
      name: name ?? this.name,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      musicPath: musicPath ?? this.musicPath,
      isActive: isActive ?? this.isActive,
    );
  }
} 