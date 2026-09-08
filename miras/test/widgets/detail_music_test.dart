import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miras/core/era_music.dart';
import 'package:miras/core/theme.dart';
import 'package:miras/data/manifest.dart';
import 'package:miras/data/sites.dart';
import 'package:miras/l10n/strings.dart';
import 'package:miras/ui/screens/detail_screen.dart';

class _SyncStore extends EraMusicStore {
  _SyncStore(super.base);

  @override
  Future<bool> import(era, String sourcePath) async {
    try {
      final bytes = File(sourcePath).readAsBytesSync();
      fileFor(era).writeAsBytesSync(bytes);
      return true;
    } catch (_) {
      return false;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ImageRegistry.load();
  });

  late Directory tempDir;
  late _SyncStore store;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('miras_detail_music');
    store = _SyncStore(tempDir);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  Future<void> pumpDetail(
    WidgetTester tester, {
    required Mp3Picker picker,
  }) async {
    tester.view.physicalSize = const Size(420, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final site = kSites.firstWhere((s) => s.id == 'ephesus');
    await tester.pumpWidget(MaterialApp(
      theme: buildMirasTheme(),
      home: SiteDetailScreen(
        site: site,
        lang: AppLang.ru,
        musicStore: store,
        mp3Picker: picker,
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows load button when no melody stored', (tester) async {
    await pumpDetail(tester, picker: () async => null);

    expect(find.byKey(const Key('detail.music')), findsOneWidget);
    expect(find.byKey(const Key('detail.music.load')), findsOneWidget);
    expect(find.text('Загрузить MP3'), findsOneWidget);
    expect(find.byKey(const Key('detail.music.toggle')), findsNothing);
  });

  testWidgets('importing a melody switches to play chip', (tester) async {
    final mp3 = File('${tempDir.path}${Platform.pathSeparator}era.mp3');
    mp3.writeAsBytesSync(List.filled(32, 0x01));

    await pumpDetail(tester, picker: () async => mp3.path);

    await tester.tap(find.byKey(const Key('detail.music.load')));
    await tester.pumpAndSettle();

    expect(store.has(Era.antiquity), isTrue);
    expect(find.byKey(const Key('detail.music.toggle')), findsOneWidget);
    expect(find.byKey(const Key('detail.music.load')), findsNothing);
    expect(find.text('Мелодия сохранена'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('detail shows music title for every language', (tester) async {
    for (final lang in AppLang.values) {
      final site = kSites.firstWhere((s) => s.id == 'hagia-sophia');
      tester.view.physicalSize = const Size(420, 3600);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(MaterialApp(
        theme: buildMirasTheme(),
        home: SiteDetailScreen(
          site: site,
          lang: lang,
          musicStore: store,
          mp3Picker: () async => null,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(t(lang, 'music.title')), findsOneWidget);
      expect(find.text(t(lang, 'music.load')), findsOneWidget);
    }
    tester.view.reset();
  });
}
