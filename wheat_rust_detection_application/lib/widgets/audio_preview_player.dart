import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPreviewPlayer extends StatefulWidget {
  final String audioFilePath; // can be local path or URL
  final VoidCallback? onDelete;

  const AudioPreviewPlayer(
      {super.key, required this.audioFilePath, this.onDelete});

  @override
  State<AudioPreviewPlayer> createState() => _AudioPreviewPlayerState();
}

class _AudioPreviewPlayerState extends State<AudioPreviewPlayer> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        position = p;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  bool get isNetwork =>
      widget.audioFilePath.startsWith('http://') ||
      widget.audioFilePath.startsWith('https://');

  Future<void> _playPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (isNetwork) {
        await _audioPlayer.play(UrlSource(widget.audioFilePath));
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.audioFilePath));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _playPause,
          ),
          Expanded(
            child: Slider(
              min: 0,
              max: duration.inMilliseconds.toDouble(),
              value: position.inMilliseconds
                  .clamp(0, duration.inMilliseconds)
                  .toDouble(),
              onChanged: (value) async {
                final seekPosition = Duration(milliseconds: value.toInt());
                await _audioPlayer.seek(seekPosition);
              },
            ),
          ),
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onDelete,
            ),
        ],
      ),
    );
  }
}
