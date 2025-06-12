import 'dart:async';
import 'package:shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final _settingsController = StreamController<AppSettings>.broadcast();
  Stream<AppSettings> get settingsStream => _settingsController.stream;

  late SharedPreferences _prefs;
  AppSettings _settings = AppSettings();

  // 設定を初期化
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  // 設定を取得
  AppSettings get settings => _settings;

  // 自動再生の設定
  Future<void> setAutoPlay(bool value) async {
    _settings = _settings.copyWith(autoPlay: value);
    await _saveSettings();
  }

  // バックグラウンド再生の設定
  Future<void> setBackgroundPlay(bool value) async {
    _settings = _settings.copyWith(backgroundPlay: value);
    await _saveSettings();
  }

  // 位置情報の許可状態を設定
  Future<void> setLocationPermission(bool value) async {
    _settings = _settings.copyWith(locationPermission: value);
    await _saveSettings();
  }

  // 設定を保存
  Future<void> _saveSettings() async {
    await _prefs.setBool('autoPlay', _settings.autoPlay);
    await _prefs.setBool('backgroundPlay', _settings.backgroundPlay);
    await _prefs.setBool('locationPermission', _settings.locationPermission);
    _settingsController.add(_settings);
  }

  // 設定を読み込み
  Future<void> _loadSettings() async {
    _settings = AppSettings(
      autoPlay: _prefs.getBool('autoPlay') ?? true,
      backgroundPlay: _prefs.getBool('backgroundPlay') ?? true,
      locationPermission: _prefs.getBool('locationPermission') ?? false,
    );
    _settingsController.add(_settings);
  }

  // リソースを解放
  void dispose() {
    _settingsController.close();
  }
}

class AppSettings {
  final bool autoPlay;
  final bool backgroundPlay;
  final bool locationPermission;

  AppSettings({
    this.autoPlay = true,
    this.backgroundPlay = true,
    this.locationPermission = false,
  });

  AppSettings copyWith({
    bool? autoPlay,
    bool? backgroundPlay,
    bool? locationPermission,
  }) {
    return AppSettings(
      autoPlay: autoPlay ?? this.autoPlay,
      backgroundPlay: backgroundPlay ?? this.backgroundPlay,
      locationPermission: locationPermission ?? this.locationPermission,
    );
  }
} 