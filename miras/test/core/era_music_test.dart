import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miras/core/era_music.dart';
import 'package:miras/data/sites.dart';

void main() {
  late Directory tempDir;
  late EraMusicStore store;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('miras_music_test');
    store = EraMusicStore(tempDir);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  File fakeMp3(Directory dir, String name) {
    final f = File('${dir.path}${Platform.pathSeparator}$name');
    f.writeAsBytesSync(List.filled(64, 0xFF));
    return f;
  }

  group('EraMusicStore', () {
    test('has() is false before import', () {
      expect(store.has(Era.antiquity), isFalse);
    });

    test('import copies file and has() becomes true', () async {
      final src = fakeMp3(tempDir, 'my_melody.mp3');
      final ok = await store.import(Era.antiquity, src.path);

      expect(ok, isTrue);
      expect(store.has(Era.antiquity), isTrue);
      expect(store.fileFor(Era.antiquity).lengthSync(), 64);
    });

    test('eras are isolated from each other', () async {
      final src = fakeMp3(tempDir, 'byzantine.mp3');
      await store.import(Era.byzantium, src.path);

      expect(store.has(Era.byzantium), isTrue);
      expect(store.has(Era.ottoman), isFalse);
      expect(store.has(Era.antiquity), isFalse);
    });

    test('import of missing file fails gracefully', () async {
      final ok = await store.import(Era.republic, 'Z:/no/such/file.mp3');
      expect(ok, isFalse);
      expect(store.has(Era.republic), isFalse);
    });

    test('remove deletes the melody', () async {
      final src = fakeMp3(tempDir, 'gone.mp3');
      await store.import(Era.ancientWorld, src.path);
      expect(store.has(Era.ancientWorld), isTrue);

      await store.remove(Era.ancientWorld);
      expect(store.has(Era.ancientWorld), isFalse);
    });
  });

  group('EraMusicController', () {
    test('noop adapter is safe by default', () async {
      await EraMusicController.play('any/path.mp3');
      await EraMusicController.stop();
      expect(EraMusicController.current.value, isNull);
    });
  });
}
