import 'package:uuid/uuid.dart';

class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String filePath;
  final Duration duration;

  MusicTrack({
    String? id,
    required this.title,
    required this.artist,
    required this.filePath,
    required this.duration,
  }) : id = id ?? const Uuid().v4();

  // JSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'filePath': filePath,
      'duration': duration.inSeconds,
    };
  }

  // JSONからオブジェクトを生成
  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      filePath: json['filePath'],
      duration: Duration(seconds: json['duration']),
    );
  }

  // コピーを作成
  MusicTrack copyWith({
    String? title,
    String? artist,
    String? filePath,
    Duration? duration,
  }) {
    return MusicTrack(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
    );
  }
} 