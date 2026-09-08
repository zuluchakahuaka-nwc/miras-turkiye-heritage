import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miras/core/theme.dart';
import 'package:miras/data/manifest.dart';
import 'package:miras/data/sites.dart';
import 'package:miras/l10n/strings.dart';
import 'package:miras/ui/screens/detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ImageRegistry.load();
  });

  Future<void> pumpDetail(WidgetTester tester, Site site, AppLang lang) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: buildMirasTheme(),
      home: SiteDetailScreen(site: site, lang: lang),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows facts and pride callout in russian', (tester) async {
    final site = kSites.firstWhere((s) => s.id == 'hagia-sophia');
    await pumpDetail(tester, site, AppLang.ru);

    expect(find.text('Айя-София'), findsOneWidget);
    expect(find.textContaining('Купол диаметром 31 метр'), findsOneWidget);
    expect(find.text(t(AppLang.ru, 'pride.label')), findsOneWidget);
    expect(find.textContaining('Соломон, я превзошёл тебя'), findsOneWidget);
    expect(find.textContaining('UNESCO'), findsOneWidget);
    expect(find.textContaining('Истанбул'), findsWidgets);
  });

  testWidgets('localized in turkish', (tester) async {
    final site = kSites.firstWhere((s) => s.id == 'anitkabir');
    await pumpDetail(tester, site, AppLang.tr);

    expect(find.text('Anıtkabir'), findsOneWidget);
    expect(find.text(t(AppLang.tr, 'pride.label')), findsOneWidget);
    expect(find.textContaining('Hitit aslanları'), findsOneWidget);
  });

  testWidgets('localized in english', (tester) async {
    final site = kSites.firstWhere((s) => s.id == 'gobekli-tepe');
    await pumpDetail(tester, site, AppLang.en);

    expect(find.text('Göbekli Tepe'), findsOneWidget);
    expect(find.text(t(AppLang.en, 'pride.label')), findsOneWidget);
    expect(find.textContaining('civilisation began in Anatolia'), findsOneWidget);
  });

  testWidgets('site without unesco hides its chip', (tester) async {
    final site = kSites.firstWhere((s) => s.id == 'side');
    await pumpDetail(tester, site, AppLang.ru);

    expect(find.textContaining('UNESCO'), findsNothing);
    expect(find.text('Сиде'), findsOneWidget);
  });
}
