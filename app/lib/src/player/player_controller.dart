import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../data/catalog_providers.dart';
import '../data/models/catalog_models.dart';
import 'audio_player_handler.dart';
import 'audio_library.dart';

/// Created in `main()` via `AudioService.init` and overridden into the tree.
final audioPlayerHandlerProvider = Provider<AudioPlayerHandler>(
  (ref) => throw UnimplementedError(
    'AudioPlayerHandler must be initialized in main()',
  ),
);

enum PlayerRepeatMode { off, all, one }

class PlayerUiState {
  const PlayerUiState({
    this.queue = const [],
    this.current,
    this.playing = false,
    this.buffering = false,
    this.position = Duration.zero,
    this.duration,
    this.speed = 1.0,
    this.repeatMode = PlayerRepeatMode.off,
    this.shuffle = false,
    this.errorMessage,
  });

  final List<Audio> queue;
  final Audio? current;
  final bool playing;
  final bool buffering;
  final Duration position;
  final Duration? duration;
  final double speed;
  final PlayerRepeatMode repeatMode;
  final bool shuffle;
  final String? errorMessage;

  bool get hasItem => current != null;
  bool get isCompleted =>
      duration != null && position >= duration! && duration!.inSeconds > 0;

  double? get progress {
    final d = duration;
    if (d == null || d.inMilliseconds == 0) return null;
    final value = position.inMilliseconds / d.inMilliseconds;
    return value.clamp(0.0, 1.0);
  }

  PlayerUiState copyWith({
    List<Audio>? queue,
    Audio? Function()? current,
    bool? playing,
    bool? buffering,
    Duration? position,
    Duration? Function()? duration,
    double? speed,
    PlayerRepeatMode? repeatMode,
    bool? shuffle,
    String? Function()? errorMessage,
  }) => PlayerUiState(
    queue: queue ?? this.queue,
    current: current != null ? current() : this.current,
    playing: playing ?? this.playing,
    buffering: buffering ?? this.buffering,
    position: position ?? this.position,
    duration: duration != null ? duration() : this.duration,
    speed: speed ?? this.speed,
    repeatMode: repeatMode ?? this.repeatMode,
    shuffle: shuffle ?? this.shuffle,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );
}

/// Maps app-level playback (current item, queue, position, buffering, error)
/// onto Riverpod state, keeping the engine lifecycle separate (architecture.md §5).
class PlayerController extends Notifier<PlayerUiState> {
  final Map<String, Audio> _audioById = {};
  final List<StreamSubscription<Object?>> _subs = [];
  AudioPlayerHandler get _handler => ref.read(audioPlayerHandlerProvider);

  @override
  PlayerUiState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedSpeed = prefs.getDouble('playback.speed') ?? 1.0;

    _subs.addAll([
      _handler.mediaItem.listen((item) {
        final audio = item == null ? null : _audioById[item.id];
        state = state.copyWith(
          current: () => audio,
          duration: () => item?.duration ?? state.duration,
          errorMessage: () => null,
        );
      }),
      _handler.queue.listen((items) {
        state = state.copyWith(
          queue: items
              .map((item) => _audioById[item.id])
              .whereType<Audio>()
              .toList(growable: false),
        );
      }),
      _handler.playbackState.listen((playback) {
        if (playback.processingState == AudioProcessingState.completed) {
          ref.invalidate(offlineAudiosProvider);
        }
        state = state.copyWith(
          playing: playback.playing,
          buffering:
              playback.processingState == AudioProcessingState.buffering ||
              playback.processingState == AudioProcessingState.loading,
          position: playback.updatePosition,
          errorMessage:
              playback.processingState == AudioProcessingState.error &&
                  playback.errorMessage != null
              ? () => _friendlyMessage(playback.errorMessage!)
              : () => null,
        );
      }),
      _handler.positionStream.listen((position) {
        state = state.copyWith(position: position);
      }),
      _handler.durationStream.listen((duration) {
        state = state.copyWith(duration: () => duration);
      }),
    ]);

    if ((savedSpeed - 1.0).abs() > 0.001) {
      unawaited(_applySpeed(savedSpeed));
    }

    ref.onDispose(() {
      for (final sub in _subs) {
        unawaited(sub.cancel());
      }
    });

    return PlayerUiState(speed: savedSpeed);
  }

  /// Plays [audios] starting at [startIndex], resolving stream URLs via
  /// `CatalogRepository` (signed URL endpoint or public CDN URL).
  Future<void> playAudioList(List<Audio> audios, {int startIndex = 0}) async {
    if (audios.isEmpty) return;
    state = state.copyWith(errorMessage: () => null);

    try {
      final repository = ref.read(catalogRepositoryProvider);
      final boundedIndex = startIndex.clamp(0, audios.length - 1);

      final library = ref.read(audioLibraryProvider);
      final cachePaths = await Future.wait(audios.map(library.pathFor));
      final urls = await Future.wait(
        audios.map((audio) async {
          if (await library.isDownloaded(audio)) return '';
          return repository.getPlaybackUrl(audio);
        }),
      );
      await Future.wait(audios.map(library.register));

      final items = <MediaItem>[
        for (var i = 0; i < audios.length; i++)
          _toMediaItem(audios[i], urls[i], cachePaths[i]),
      ];
      for (final audio in audios) {
        _audioById[audio.id] = audio;
      }

      await _handler.setAudioQueue(items: items, initialIndex: boundedIndex);
      await _applySpeed(state.speed);
      await _applyRepeatMode(state.repeatMode);
      await _handler.setShuffleMode(
        state.shuffle
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => _friendlyMessage(e.toString()),
      );
    }
  }

  Future<void> playQueueIndex(int index) async {
    final queue = state.queue;
    if (index < 0 || index >= queue.length) return;
    await playAudioList(queue, startIndex: index);
  }

  Future<void> togglePlayPause() async {
    if (!state.hasItem) return;
    if (state.playing) {
      await _handler.pause();
    } else {
      await _handler.play();
    }
  }

  Future<void> seek(Duration position) => _handler.seek(position);

  Future<void> skipBy(Duration delta) async {
    final target = state.position + delta;
    final clamped = target.isNegative
        ? Duration.zero
        : (state.duration != null && target > state.duration!)
        ? state.duration!
        : target;
    await _handler.seek(clamped);
  }

  Future<void> next() => _handler.skipToNext();

  Future<void> previous() => _handler.skipToPrevious();

  Future<void> setSpeed(double speed) async {
    await _applySpeed(speed);
    await ref
        .read(sharedPreferencesProvider)
        .setDouble('playback.speed', speed);
  }

  Future<void> cycleRepeatMode() async {
    final nextMode = switch (state.repeatMode) {
      PlayerRepeatMode.off => PlayerRepeatMode.all,
      PlayerRepeatMode.all => PlayerRepeatMode.one,
      PlayerRepeatMode.one => PlayerRepeatMode.off,
    };
    state = state.copyWith(repeatMode: nextMode);
    await _applyRepeatMode(nextMode);
  }

  Future<void> toggleShuffle() async {
    final enabled = !state.shuffle;
    state = state.copyWith(shuffle: enabled);
    await _handler.setShuffleMode(
      enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
  }

  Future<void> _applySpeed(double speed) async {
    state = state.copyWith(speed: speed);
    await _handler.setSpeed(speed);
  }

  Future<void> _applyRepeatMode(PlayerRepeatMode mode) async {
    await _handler.setRepeatMode(switch (mode) {
      PlayerRepeatMode.off => AudioServiceRepeatMode.none,
      PlayerRepeatMode.all => AudioServiceRepeatMode.all,
      PlayerRepeatMode.one => AudioServiceRepeatMode.one,
    });
  }

  MediaItem _toMediaItem(Audio audio, String streamUrl, String cachePath) =>
      MediaItem(
        id: audio.id,
        title: audio.title,
        artist: audio.teacher.shortName ?? audio.teacher.name,
        album: audio.type.name,
        artUri: audio.coverImageUrl == null
            ? null
            : Uri.tryParse(audio.coverImageUrl!),
        duration: Duration(seconds: audio.durationSeconds),
        extras: {
          'slug': audio.slug,
          'stream_url': streamUrl,
          'cache_file_path': cachePath,
        },
      );

  String _friendlyMessage(String raw) {
    if (raw.contains('SocketException') || raw.contains('HttpException')) {
      return 'network';
    }
    if (raw.contains('Source error') || raw.contains('URI')) {
      return 'source';
    }
    return 'generic';
  }
}

final playerControllerProvider =
    NotifierProvider<PlayerController, PlayerUiState>(PlayerController.new);

final currentAudioProvider = Provider<Audio?>(
  (ref) => ref.watch(playerControllerProvider.select((s) => s.current)),
);
