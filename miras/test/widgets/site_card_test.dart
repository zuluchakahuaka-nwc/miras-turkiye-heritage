import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miras/core/theme.dart';
import 'package:miras/data/manifest.dart';
import 'package:miras/data/sites.dart';
import 'package:miras/l10n/strings.dart';
import 'package:miras/ui/widgets/site_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ImageRegistry.load();
  });

  Widget wrap(Widget child) => MaterialApp(
        theme: buildMirasTheme(),
        home: Scaffold(body: child),
      );

  testWidgets('renders name, region and era ribbon', (tester) async {
    final site = kSites.firstWhere((s) => s.id == 'ephesus');
    await tester.pumpWidget(wrap(SizedBox(
      width: 400,
      child: SiteCard(site: site, lang: AppLang.ru, onTap: (_) {}),
    )));

    expect(find.text('Эфес'), findsOneWidget);
    expect(find.text('ИЗМИР · X в. до н. э.'), findsOneWidget);
    expect(find.text('Античность'), findsOneWidget);
    expect(find.text('ЮНЕСКО 2015'), findsOneWidget);
  });

  testWidgets('unesco badge hidden when site is not in list', (tester) async {
    final site = kSites.firstWhere((s) => s.id == 'aspendos');
    await tester.pumpWidget(wrap(SizedBox(
      width: 400,
      child: SiteCard(site: site, lang: AppLang.ru, onTap: (_) {}),
    )));

    expect(find.text('Аспендос'), findsOneWidget);
    expect(find.textContaining('ЮНЕСКО'), findsNothing);
  });

  testWidgets('localized in Turkish', (tester) async {
    final site = kSites.firstWhere((s) => s.id == 'side');
    await tester.pumpWidget(wrap(SizedBox(
      width: 400,
      child: SiteCard(site: site, lang: AppLang.tr, onTap: (_) {}),
    )));

    expect(find.text('Side'), findsOneWidget);
    expect(find.text('ANTALYA · MÖ 7. yüzyıl'), findsOneWidget);
  });

  testWidgets('falls back to ornament placeholder when asset missing',
      (tester) async {
    final site = Site(
      id: 'no-such-site',
      name: const L10nText('Тест', 'Test', 'Test'),
      region: const L10nText('Регион', 'Bölge', 'Region'),
      date: const L10nText('I в.', 'MS 1. yy', '1st c.'),
      era: Era.antiquity,
      sortYear: 100,
      lat: 37.0,
      lon: 30.0,
      desc: const L10nText(
        'Описание тестового объекта, которого нет в манифесте.',
        'Manifestte olmayan test nesnesi açıklaması.',
        'Description of a test object missing from the manifest.',
      ),
      pride: const L10nText('Гордость', 'Gurur', 'Pride'),
      legend: const L10nText('Легенда тестового объекта.', 'Test efsanesi.', 'A test legend.'),
      gettingThere: const L10nText('Как добраться: тест.', 'Nasıl gidilir: test.', 'Getting there: test.'),
      wikiRu: 'Тест',
      wikiEn: 'Test',
    );
    await tester.pumpWidget(wrap(SizedBox(
      width: 400,
      child: SiteCard(site: site, lang: AppLang.ru, onTap: (_) {}),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Тест'), findsOneWidget);
    expect(find.text('Фото недоступно'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onTap fires with the site', (tester) async {
    final site = kSites.first;
    Site? tapped;
    await tester.pumpWidget(wrap(SizedBox(
      width: 400,
      child: SiteCard(site: site, lang: AppLang.ru, onTap: (s) => tapped = s),
    )));
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(tapped?.id, site.id);
  });
}
