import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';

import '../data/models/catalog_models.dart';

/// Audio files live in the app's private documents directory, so they are not
/// added to the user's public music/download folders.
class AudioLibrary {
  static const _downloadGroup = 'audio_library_downloads';
  final FileDownloader _downloader = FileDownloader();
  final ValueNotifier<List<AudioDownloadEntry>> downloadsNotifier =
      ValueNotifier(const []);
  final StreamController<void> _changes = StreamController<void>.broadcast();
  final Map<String, Audio> _audioById = {};
  final Set<String> _observedTransfers = {};
  final Set<String> _finalizing = {};
  Future<void> _metadataWrite = Future<void>.value();
  bool _initialized = false;
  String _languageCode = 'my';

  Stream<void> get changes => _changes.stream;

  set languageCode(String value) => _languageCode = value;

  bool get _isEnglish => _languageCode == 'en';

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    for (final audio in await _registeredAudios()) {
      _audioById[audio.id] = audio;
    }
    await _downloader.start(autoCleanDatabase: true);
    _downloader.transfers.notifier.addListener(_refreshDownloads);
    _refreshDownloads();
  }

  Future<Directory> get _directory async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/offline_audio');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  Future<File> fileFor(Audio audio) async =>
      File('${(await _directory).path}/${_safeId(audio.id)}.mp3');

  Future<String> pathFor(Audio audio) async => (await fileFor(audio)).path;

  Future<bool> isDownloaded(Audio audio) async =>
      (await fileFor(audio)).exists();

  Future<void> cache(Audio audio, String url) async {
    await startDownload(audio, url);
  }

  Future<void> startDownload(Audio audio, String url) async {
    await initialize();
    if (await isDownloaded(audio)) return;
    _audioById[audio.id] = audio;
    await _writeMetadata(audio);
    final task = DownloadTask(
      taskId: _taskId(audio),
      url: url,
      filename: '${_safeId(audio.id)}.background.mp3',
      directory: 'offline_audio',
      baseDirectory: BaseDirectory.applicationDocuments,
      group: _downloadGroup,
      metaData: audio.id,
      displayName: audio.title,
      retries: 2,
      allowPause: true,
      updates: Updates.statusAndProgress,
      transferHints: {TransferHint.largeFile},
      notificationConfig: TaskNotificationConfig(
        running: TaskNotification(
          _isEnglish ? 'Downloading' : 'ဒေါင်းလုဒ်လုပ်နေသည်',
          '{displayName} · {progress}',
        ),
        complete: TaskNotification(
          _isEnglish ? 'Download complete' : 'ဒေါင်းလုဒ်ပြီးပါပြီ',
          '{displayName}',
        ),
        error: TaskNotification(
          _isEnglish ? 'Download failed' : 'ဒေါင်းလုဒ် မအောင်မြင်ပါ',
          '{displayName}',
        ),
        progressBar: true,
      ),
    );
    final transfer = await _downloader.transfers.getOrStart(task);
    _observe(transfer);
    _publishDownloads();
  }

  Future<void> retryDownload(Audio audio, String url) =>
      startDownload(audio, url);

  Future<void> cancelDownload(Audio audio) async {
    final transfer = _downloader.transfers.forId(_taskId(audio));
    if (transfer != null) await transfer.cancel();
  }

  Future<void> pauseDownload(Audio audio) async {
    await _downloader.transfers.forId(_taskId(audio))?.pause();
  }

  Future<void> resumeDownload(Audio audio) async {
    await _downloader.transfers.forId(_taskId(audio))?.resume();
  }

  Future<void> register(Audio audio) => _writeMetadata(audio);

  Future<List<Audio>> list() async {
    final directory = await _directory;
    final index = File('${directory.path}/index.json');
    if (!await index.exists()) return const [];
    try {
      final decoded = jsonDecode(await index.readAsString()) as List<dynamic>;
      final audios = decoded
          .whereType<Map<String, dynamic>>()
          .map(Audio.fromJson)
          .toList();
      final result = <Audio>[];
      for (final audio in audios) {
        if (await isDownloaded(audio)) result.add(audio);
      }
      return result;
    } catch (_) {
      return const [];
    }
  }

  Future<void> delete(Audio audio) async {
    await cancelDownload(audio);
    final taskId = _taskId(audio);
    _downloader.transfers.remove(taskId);
    _observedTransfers.remove(taskId);
    await _downloader.database.deleteRecordWithId(taskId);
    final file = await fileFor(audio);
    if (await file.exists()) await file.delete();
    final taskFile = File(
      '${(await _directory).path}/${_safeId(audio.id)}.background.mp3',
    );
    if (await taskFile.exists()) await taskFile.delete();
    final audios = (await _registeredAudios()).where(
      (item) => item.id != audio.id,
    );
    final directory = await _directory;
    await File('${directory.path}/index.json')
        .writeAsString(jsonEncode(audios.map(_toJson).toList()));
    _audioById.remove(audio.id);
    _changes.add(null);
    _publishDownloads();
  }

  Future<void> _writeMetadata(Audio audio) {
    final next = _metadataWrite.then((_) => _writeMetadataSerialized(audio));
    _metadataWrite = next.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return next;
  }

  Future<void> _writeMetadataSerialized(Audio audio) async {
    final directory = await _directory;
    final audios = await _registeredAudios();
    final updated = [...audios.where((item) => item.id != audio.id), audio];
    await File('${directory.path}/index.json')
        .writeAsString(jsonEncode(updated.map(_toJson).toList()));
    _changes.add(null);
  }

  Future<List<Audio>> _registeredAudios() async {
    final directory = await _directory;
    final index = File('${directory.path}/index.json');
    if (!await index.exists()) return const [];
    try {
      final decoded = jsonDecode(await index.readAsString()) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Audio.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  String _taskId(Audio audio) => 'offline_audio_${_safeId(audio.id)}';

  void _refreshDownloads() {
    for (final transfer in _downloader.transfers.all(group: _downloadGroup)) {
      _observe(transfer);
    }
    _publishDownloads();
  }

  void _observe(Transfer transfer) {
    if (!_observedTransfers.add(transfer.task.taskId)) return;
    transfer.statusNotifier.addListener(() {
      if (transfer.status == TaskStatus.complete) {
        unawaited(_finishDownload(transfer));
      }
      _publishDownloads();
    });
    transfer.progressNotifier.addListener(_publishDownloads);
    if (transfer.status == TaskStatus.complete) {
      unawaited(_finishDownload(transfer));
    }
  }

  Future<void> _finishDownload(Transfer transfer) async {
    final id = transfer.task.metaData;
    if (!_finalizing.add(transfer.task.taskId)) return;
    try {
      var audio = _audioById[id];
      if (audio == null) {
        for (final item in await _registeredAudios()) {
          if (item.id == id) {
            audio = item;
            break;
          }
        }
      }
      if (audio == null) return;
      final source = await transfer.file;
      final target = await fileFor(audio);
      if (await target.exists()) {
        await source.delete();
      } else {
        await source.rename(target.path);
      }
      _audioById[id] = audio;
      await _writeMetadata(audio);
      _changes.add(null);
    } catch (_) {
      // A transfer may report completion before its file is available after
      // process restoration. It will be reconciled on the next app launch.
    } finally {
      _finalizing.remove(transfer.task.taskId);
      _publishDownloads();
    }
  }

  void _publishDownloads() {
    final entries = <AudioDownloadEntry>[];
    for (final transfer in _downloader.transfers.all(group: _downloadGroup)) {
      final id = transfer.task.metaData;
      final audio = _audioById[id];
      if (audio == null ||
          transfer.status == TaskStatus.complete ||
          transfer.status == TaskStatus.canceled) {
        continue;
      }
      entries.add(
        AudioDownloadEntry(
          audio: audio,
          progress: transfer.progress,
          status: transfer.status,
        ),
      );
    }
    downloadsNotifier.value = List.unmodifiable(entries);
  }

  String _safeId(String value) =>
      value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

  Map<String, dynamic> _toJson(Audio audio) => {
    'id': audio.id,
    'slug': audio.slug,
    'title': audio.title,
    'description': audio.description,
    'duration_seconds': audio.durationSeconds,
    'language': audio.language,
    'cover_image_url': audio.coverImageUrl,
    'published_at': audio.publishedAt?.toIso8601String(),
    'teacher': {
      'id': audio.teacher.id,
      'slug': audio.teacher.slug,
      'name': audio.teacher.name,
      'short_name': audio.teacher.shortName,
      'photo_url': audio.teacher.photoUrl,
    },
    'type': {
      'id': audio.type.id,
      'slug': audio.type.slug,
      'name': audio.type.name,
    },
    'categories': audio.categories
        .map(
          (category) => {
            'id': category.id,
            'slug': category.slug,
            'name': category.name,
          },
        )
        .toList(),
  };
}

class AudioDownloadEntry {
  const AudioDownloadEntry({
    required this.audio,
    required this.status,
    this.progress,
  });

  final Audio audio;
  final TaskStatus status;
  final double? progress;
}

final audioLibraryProvider = Provider<AudioLibrary>((ref) => AudioLibrary());

final offlineAudiosProvider = FutureProvider<List<Audio>>((ref) async {
  final library = ref.watch(audioLibraryProvider);
  final sub = library.changes.listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
  return library.list();
});

final audioDownloadedProvider = FutureProvider.family<bool, Audio>((
  ref,
  audio,
) async {
  final library = ref.watch(audioLibraryProvider);
  final sub = library.changes.listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
  return library.isDownloaded(audio);
});
