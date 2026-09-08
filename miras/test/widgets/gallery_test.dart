import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miras/core/theme.dart';
import 'package:miras/data/manifest.dart';
import 'package:miras/l10n/strings.dart';
import 'package:miras/ui/screens/gallery_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ImageRegistry.load();
  });

  Future<void> pumpGallery(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildMirasTheme(),
      home: const GalleryScreen(lang: AppLang.ru),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('search narrows results to a single card', (tester) async {
    await pumpGallery(tester);

    await tester.enterText(find.byKey(const Key('gallery.search')), 'гёбекли');
    await tester.pumpAndSettle();

    expect(find.text('Гёбекли-Тепе'), findsOneWidget);
    expect(find.text('Аныткабир'), findsNothing);
  });

  testWidgets('search works for turkish query in russian ui', (tester) async {
    await pumpGallery(tester);

    await tester.enterText(find.byKey(const Key('gallery.search')), 'Anitkabir');
    await tester.pumpAndSettle();

    expect(find.text('Аныткабир'), findsOneWidget);
  });

  testWidgets('era chip filters content', (tester) async {
    await pumpGallery(tester);

    await tester.tap(find.byKey(const Key('gallery.chip.antiquity')));
    await tester.pumpAndSettle();

    expect(find.text('Эфес'), findsOneWidget);
    expect(find.text('Гёбекли-Тепе'), findsNothing);
  });

  testWidgets('reset chip returns all sites', (tester) async {
    await pumpGallery(tester);

    await tester.tap(find.byKey(const Key('gallery.chip.antiquity')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('gallery.chip.all')));
    await tester.pumpAndSettle();

    expect(find.text('Гёбекли-Тепе'), findsOneWidget);
    expect(find.text('Эфес'), findsOneWidget);
  });

  testWidgets('gibberish query shows empty state', (tester) async {
    await pumpGallery(tester);

    await tester.enterText(find.byKey(const Key('gallery.search')), 'zzzz9999');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('gallery.empty')), findsOneWidget);
    expect(find.text('Ничего не найдено'), findsOneWidget);
  });

  testWidgets('turkish ui shows localized header and hint', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildMirasTheme(),
      home: const GalleryScreen(lang: AppLang.tr),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Miras galerisi'), findsOneWidget);
    expect(find.text('Tümü'), findsOneWidget);
  });
}
