import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music_out/models/music_track.dart';
import 'package:music_out/services/music_service.dart';

class MusicSelectionScreen extends StatefulWidget {
  final String? selectedTrackId;

  const MusicSelectionScreen({
    super.key,
    this.selectedTrackId,
  });

  @override
  State<MusicSelectionScreen> createState() => _MusicSelectionScreenState();
}

class _MusicSelectionScreenState extends State<MusicSelectionScreen> {
  final _musicService = MusicService();
  List<MusicTrack> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    await _musicService.loadTracks();
    _musicService.tracksStream.listen((tracks) {
      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
    });
  }

  Future<void> _pickMusicFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final musicDir = await _musicService.getMusicDirectory();
        final newFile = await file.copy('${musicDir.path}/${file.path.split('/').last}');
        await _musicService.addMusicFile(newFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('音楽ファイルの追加に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _deleteMusicFile(MusicTrack track) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('音楽ファイルを削除'),
        content: const Text('この音楽ファイルを削除してもよろしいですか？'),
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

    if (confirmed == true) {
      await _musicService.deleteMusicFile(track.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('音楽ファイルを選択'),
      ),
      body: _tracks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('音楽ファイルがありません'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickMusicFile,
                    child: const Text('音楽ファイルを追加'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                final track = _tracks[index];
                final isSelected = track.id == widget.selectedTrackId;

                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(track.title),
                  subtitle: Text(track.artist),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Icon(Icons.check, color: Colors.blue),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteMusicFile(track),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context, track);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickMusicFile,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _musicService.dispose();
 