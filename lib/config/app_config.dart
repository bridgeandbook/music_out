import 'package:flutter/material.dart';

class AppConfig {
  // アプリケーションのテーマ設定
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  // 位置情報の取得間隔（ミリ秒）
  static const int locationUpdateInterval = 30000; // 30秒

  // 音楽のフェードアウト時間（ミリ秒）
  static const int musicFadeOutDuration = 2000; // 2秒

  // エリアのデフォルト半径（メートル）
  static const double defaultAreaRadius = 1000; // 1km

  // 地図の初期ズームレベル
  static const double initialMapZoom = 15.0;

  // 地図の最小ズームレベル
  static const double minMapZoom = 5.0;

  // 地図の最大ズームレベル
  static const double maxMapZoom = 18.0;
} 