import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Owns the playback engine (`just_audio`) and exposes it through
/// `audio_service` so audio keeps playing in the background with
/// lock-screen / notification controls (architecture.md §5).
///
/// UI never talks to this directly — only through `PlayerController`.
class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  AudioPlayerHandler() {
    _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object e, StackTrace _) {
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            errorMessage: e.toString(),
          ),
        );
      },
    );
    _player.playerStateStream.listen(
      (_) => _broadcastState(_player.playbackEvent),
    );
    _player.currentIndexStream.listen(_broadcastItem);
    _player.durationStream.listen(
      (_) => _broadcastState(_player.playbackEvent),
    );
  }

  final AudioPlayer _player = AudioPlayer();

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedStream => _player.bufferedPositionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Duration get position => _player.position;

  /// Loads [items] and starts playback at [initialIndex].
  Future<void> setAudioQueue({
    required List<MediaItem> items,
    required int initialIndex,
    bool autoplay = true,
  }) async {
    await _player.stop();
    queue.add(items);

    final sources = items.map((item) {
      final url = item.extras?['stream_url'] as String? ?? '';
      final cachePath = item.extras?['cache_file_path'] as String?;
      final file = cachePath == null ? null : File(cachePath);
      if (file != null && file.existsSync()) {
        return AudioSource.uri(Uri.file(file.path), tag: item);
      }
      if (file != null) {
        // Cache bytes in the app's private files while the user streams.
        // ignore: experimental_member_use
        return LockCachingAudioSource(
          Uri.parse(url),
          cacheFile: file,
          tag: item,
        );
      }
      return AudioSource.uri(Uri.parse(url), tag: item);
    }).toList();

    try {
      await _player.setAudioSources(
        sources,
        initialIndex: initialIndex.clamp(0, items.length - 1),
        initialPosition: Duration.zero,
      );
    } catch (e) {
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }

    _broadcastItem(_player.currentIndex);
    if (autoplay) {
      await play();
    } else {
      _broadcastState(_player.playbackEvent);
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> fastForward() =>
      _player.seek(_player.position + const Duration(seconds: 10));

  @override
  Future<void> rewind() async {
    final target = _player.position - const Duration(seconds: 10);
    await _player.seek(target.isNegative ? Duration.zero : target);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      // At the start of the queue, keep the previous control useful by
      // restarting the current item.
      await _player.seek(Duration.zero);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    await super.setSpeed(speed);
    _broadcastState(_player.playbackEvent);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
    }
    await super.setRepeatMode(repeatMode);
    _broadcastState(_player.playbackEvent);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(enabled);
    await super.setShuffleMode(shuffleMode);
    _broadcastState(_player.playbackEvent);
  }

  void _broadcastItem(int? index) {
    final items = queue.value;
    if (index == null || index < 0 || index >= items.length) return;
    mediaItem.add(items[index]);
  }

  void _broadcastState(PlaybackEvent event) {
    final processing = event.processingState;
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 2, 4],
        processingState: switch (processing) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: _player.playing && processing != ProcessingState.completed,
        updatePosition: _player.position,
        bufferedPosition: event.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  Future<void> dispose() => _player.dispose();
}
