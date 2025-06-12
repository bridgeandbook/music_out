import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences.dart';
import 'package:music_out/models/music_track.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final _tracksController = StreamController<List<MusicTrack>>.broadcast();
  Stream<List<MusicTrack>> get tracksStream => _tracksController.stream;

  List<MusicTrack> _tracks = [];
  List<MusicTrack> get tracks => List.unmodifiable(_tracks);

  // 音楽ファイルを追加
  Future<void> addMusicFile(File file) async {
    final fileName = file.path.split('/').last;
    final track = MusicTrack(
      title: fileName,
      artist: 'Unknown Artist',
      filePath: file.path,
      duration: const Duration(seconds: 0), // TODO: 実際の長さを取得
    );

    _tracks.add(track);
    await _saveTracks();
    _tracksController.add(_tracks);
  }

  // 音楽ファイルを削除
  Future<void> deleteMusicFile(String trackId) async {
    final track = _tracks.firstWhere((t) => t.id == trackId);
    final file = File(track.filePath);
    if (await file.exists()) {
      await file.delete();
    }

    _tracks.removeWhere((t) => t.id == trackId);
    await _saveTracks();
    _tracksController.add(_tracks);
  }

  // 音楽ファイルを更新
  Future<void> updateMusicTrack(MusicTrack track) async {
    final index = _tracks.indexWhere((t) => t.id == track.id);
    if (index != -1) {
      _tracks[index] = track;
      await _saveTracks();
      _tracksController.add(_tracks);
    }
  }

  // 音楽ファイルを保存
  Future<void> _saveTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final tracksJson = _tracks.map((track) => jsonEncode(track.toJson())).toList();
    await prefs.setStringList('tracks', tracksJson);
  }

  // 音楽ファイルを読み込み
  Future<void> loadTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final tracksJson = prefs.getStringList('tracks') ?? [];
    _tracks = tracksJson
        .map((json) => MusicTrack.fromJson(jsonDecode(json)))
        .toList();
    _tracksController.add(_tracks);
  }

  // 音楽ファイルの保存先ディレクトリを取得
  Future<Directory> getMusicDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final musicDir = Directory('${appDir.path}/music');
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }
    return musicDir;
  }

  // リソースを解放
  void dispose() {
    _tracksController.close();
  }
} 