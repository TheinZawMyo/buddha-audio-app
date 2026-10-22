import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/catalog_models.dart';

/// Audio files live in the app's private documents directory, so they are not
/// added to the user's public music/download folders.
class AudioLibrary {
  AudioLibrary() : _dio = Dio();

  final Dio _dio;

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
    final file = await fileFor(audio);
    if (await file.exists()) return;
    final temp = File('${file.path}.part');
    try {
      await _dio.download(url, temp.path);
      await temp.rename(file.path);
      await _writeMetadata(audio);
    } catch (_) {
      if (await temp.exists()) await temp.delete();
      rethrow;
    }
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
    final file = await fileFor(audio);
    if (await file.exists()) await file.delete();
    final audios = (await list()).where((item) => item.id != audio.id);
    final directory = await _directory;
    await File('${directory.path}/index.json')
        .writeAsString(jsonEncode(audios.map(_toJson).toList()));
  }

  Future<void> _writeMetadata(Audio audio) async {
    final directory = await _directory;
    final audios = await list();
    final updated = [...audios.where((item) => item.id != audio.id), audio];
    await File('${directory.path}/index.json')
        .writeAsString(jsonEncode(updated.map(_toJson).toList()));
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

final audioLibraryProvider = Provider<AudioLibrary>((ref) => AudioLibrary());

final offlineAudiosProvider = FutureProvider<List<Audio>>(
  (ref) => ref.watch(audioLibraryProvider).list(),
);

final audioDownloadedProvider = FutureProvider.family<bool, Audio>(
  (ref, audio) => ref.watch(audioLibraryProvider).isDownloaded(audio),
);
