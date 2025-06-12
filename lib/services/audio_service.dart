import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:music_out/models/music_track.dart';
import 'package:music_out/config/app_config.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final _player = AudioPlayer();
  final _playbackStateController = StreamController<PlaybackState>.broadcast();
  Stream<PlaybackState> get playbackStateStream => _playbackStateController.stream;

  MusicTrack? _currentTrack;
  MusicTrack? get currentTrack => _currentTrack;

  bool _isFading = false;

  // 音楽を再生
  Future<void> play(MusicTrack track) async {
    if (_isFading) return;

    try {
      if (_currentTrack != null) {
        await _fadeOut();
      }

      _currentTrack = track;
      await _player.setAsset(track.sourceId); // ローカルファイルの場合
      // TODO: ストリーミングサービスの場合は別の処理を実装

      await _player.play();
      _updatePlaybackState();
    } catch (e) {
      print('Error playing track: $e');
    }
  }

  // 再生を一時停止
  Future<void> pause() async {
    if (_isFading) return;
    await _player.pause();
    _updatePlaybackState();
  }

  // 再生を再開
  Future<void> resume() async {
    if (_isFading) return;
    await _player.play();
    _updatePlaybackState();
  }

  // 再生を停止
  Future<void> stop() async {
    if (_isFading) return;
    await _player.stop();
    _currentTrack = null;
    _updatePlaybackState();
  }

  // フェードアウト
  Future<void> _fadeOut() async {
    if (_isFading) return;
    _isFading = true;

    try {
      await _player.setVolume(1.0);
      await _player.setSpeed(1.0);

      // フェードアウト
      final steps = 20;
      final stepDuration = AppConfig.musicFadeOutDuration ~/ steps;
      final volumeStep = 1.0 / steps;

      for (var i = 0; i < steps; i++) {
        await Future.delayed(Duration(milliseconds: stepDuration));
        await _player.setVolume(1.0 - (volumeStep * (i + 1)));
      }

      await _player.stop();
    } finally {
      _isFading = false;
    }
  }

  // 再生状態を更新
  void _updatePlaybackState() {
    _playbackStateController.add(PlaybackState(
      isPlaying: _player.playing,
      currentTrack: _currentTrack,
      position: _player.position,
      duration: _player.duration,
    ));
  }

  // リソースを解放
  Future<void> dispose() async {
    await _player.dispose();
    await _playbackStateController.close();
  }
}

class PlaybackState {
  final bool isPlaying;
  final MusicTrack? currentTrack;
  final Duration position;
  final Duration? duration;

  PlaybackState({
    required this.isPlaying,
    this.currentTrack,
    required this.position,
    this.duration,
  });
} 