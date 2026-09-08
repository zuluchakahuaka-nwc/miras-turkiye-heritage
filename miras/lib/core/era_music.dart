import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data/sites.dart';

class EraMusicStore {
  static EraMusicStore? _instance;
  final Directory base;

  EraMusicStore(this.base);

  static EraMusicStore get instance => _instance ??= EraMusicStore(Directory.systemTemp);

  static set instance(EraMusicStore store) => _instance = store;

  Directory get musicDir {
    final d = Directory('${base.path}${Platform.pathSeparator}music');
    if (!d.existsSync()) d.createSync(recursive: true);
    return d;
  }

  File fileFor(Era era) =>
      File('${musicDir.path}${Platform.pathSeparator}era_${era.name}.mp3');

  bool has(Era era) => fileFor(era).existsSync();

  Future<bool> import(Era era, String sourcePath) async {
    try {
      final src = File(sourcePath);
      if (!await src.exists()) return false;
      await src.copy(fileFor(era).path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> remove(Era era) async {
    final f = fileFor(era);
    if (await f.exists()) await f.delete();
  }
}

abstract class AudioAdapter {
  Future<void> playLoop(String path);
  Future<void> stop();
}

class NoopAudioAdapter implements AudioAdapter {
  @override
  Future<void> playLoop(String path) async {}
  @override
  Future<void> stop() async {}
}

class EraMusicController {
  static AudioAdapter adapter = NoopAudioAdapter();
  static ValueNotifier<String?> current = ValueNotifier(null);

  static Future<void> play(String path) async {
    try {
      await adapter.stop();
      await adapter.playLoop(path);
      current.value = path;
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await adapter.stop();
      current.value = null;
    } catch (_) {}
  }
}

typedef Mp3Picker = Future<String?> Function();
