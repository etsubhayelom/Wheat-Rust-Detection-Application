import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPreviewPlayer extends StatefulWidget {
  final String audioFilePath;
  final VoidCallback onDelete;

  const AudioPreviewPlayer({
    super.key,
    required this.audioFilePath,
    required this.onDelete,
  });

  @override
  State<AudioPreviewPlayer> createState() => _AudioPreviewPlayerState();
}

class _AudioPreviewPlayerState extends State<AudioPreviewPlayer> {
  late AudioPlayer _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setFilePath(widget.audioFilePath);
    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.green),
            onPressed: _togglePlayPause,
          ),
          const SizedBox(width: 8),
          const Text("Voice message",
              style: TextStyle(fontWeight: FontWeight.w500)),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}
