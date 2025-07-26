import 'dart:async';
import 'dart:io';

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
  late StreamSubscription<PlayerState> _playerStateSub;
  late StreamSubscription<Duration> _durationSub;
  late StreamSubscription<Duration> _positionSub;

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() {
        duration = d;
      });
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() {
        position = p;
      });
    });
  }

  @override
  void dispose() {
    _playerStateSub.cancel();
    _durationSub.cancel();
    _positionSub.cancel();
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
      debugPrint('Trying to play: ${widget.audioFilePath}');
      if (isNetwork) {
        await _audioPlayer.play(UrlSource(widget.audioFilePath));
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.audioFilePath));
      }
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // Placeholder waveform painter
  Widget _buildWaveform() {
    return SizedBox(
      height: 24,
      width: 120,
      child: CustomPaint(
        painter: _WaveformPainter(),
      ),
    );
  }

  // For demo: get file size if local, else show dummy value
  Future<String> _getFileSize() async {
    if (isNetwork) {
      // For network, you would need to fetch headers or metadata
      return "903.3 KB";
    } else {
      final file = File(widget.audioFilePath);
      if (await file.exists()) {
        final bytes = await file.length();
        final kb = bytes / 1024;
        return "${kb.toStringAsFixed(1)} KB";
      }
      return "0 KB";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _getFileSize(),
        builder: (context, snapshot) {
          return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF4C9EEB), // Telegram blue
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(mainAxisSize: MainAxisSize.max, children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: const Color(0xFF4C9EEB),
                    ),
                    onPressed: _playPause,
                  ),
                ),
                const SizedBox(width: 8),
                // Waveform
                _buildWaveform(),
                const SizedBox(width: 8),
                // Duration and file size
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDuration(
                          duration > Duration.zero ? duration : position),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (widget.onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: widget.onDelete,
                      ),
                  ],
                ),
                const Spacer(),
              ]));
        });
  }
}

class _WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const barCount = 22;
    final barWidth = size.width / barCount;
    final heights = [
      0.5,
      0.8,
      0.3,
      0.7,
      0.4,
      0.9,
      0.6,
      0.8,
      0.5,
      0.7,
      0.3,
      0.8,
      0.5,
      0.6,
      0.9,
      0.4,
      0.7,
      0.8,
      0.5,
      0.6,
      0.7,
      0.5
    ];
    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      final h = heights[i % heights.length] * size.height;
      canvas.drawLine(
        Offset(x, size.height / 2 - h / 2),
        Offset(x, size.height / 2 + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
