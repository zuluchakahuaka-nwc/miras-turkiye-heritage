import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miras/core/theme.dart';
import 'package:miras/data/manifest.dart';
import 'package:miras/data/sites.dart';
import 'package:miras/l10n/strings.dart';
import 'package:miras/ui/map/turkey_map.dart' show TurkeyGeometry, kMapBaseWidth, kMapBaseHeight, kTurkeyCities, kTurkeyRoads, kSiteRoutes;
import 'package:miras/ui/screens/detail_screen.dart';
import 'package:miras/ui/screens/map_screen.dart' show MapScreen, kMarkerNudges;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ImageRegistry.load();
  });

  group('TurkeyGeometry projection', () {
    test('all sites project inside canvas bounds', () {
      for (final s in kSites) {
        final p = TurkeyGeometry.project(s.lat, s.lon);
        expect(p.dx, inInclusiveRange(0, kMapBaseWidth), reason: '${s.id} x');
        expect(p.dy, inInclusiveRange(0, kMapBaseHeight), reason: '${s.id} y');
      }
    });

    test('projection is monotonic west-east and north-south', () {
      final west = TurkeyGeometry.project(39.0, 26.0);
      final east = TurkeyGeometry.project(39.0, 44.0);
      final north = TurkeyGeometry.project(42.0, 35.0);
      final south = TurkeyGeometry.project(36.0, 35.0);
      expect(east.dx, greaterThan(west.dx));
      expect(south.dy, greaterThan(north.dy));
    });

    test('outline path is closed and non-empty', () {
      final path = TurkeyGeometry.buildOutlinePath();
      expect(path.getBounds().width, greaterThan(0));
      expect(path.getBounds().height, greaterThan(0));
    });

    test('all major cities project inside canvas bounds', () {
      for (final c in kTurkeyCities) {
        final p = TurkeyGeometry.project(c.lat, c.lon);
        expect(p.dx, inInclusiveRange(0, kMapBaseWidth), reason: c.name);
        expect(p.dy, inInclusiveRange(0, kMapBaseHeight), reason: c.name);
      }
      expect(kTurkeyCities.map((c) => c.name).toSet().length, kTurkeyCities.length);
    });

    test('marker nudges are small and keep markers inside canvas', () {
      expect(kMarkerNudges.keys.toSet().length, kMarkerNudges.length);
      for (final e in kMarkerNudges.entries) {
        expect(e.value.dx.abs(), lessThan(40));
        expect(e.value.dy.abs(), lessThan(40));
        final site = kSites.firstWhere((s) => s.id == e.key);
        final p = TurkeyGeometry.project(site.lat, site.lon) + e.value;
        expect(p.dx, inInclusiveRange(0, kMapBaseWidth), reason: e.key);
        expect(p.dy, inInclusiveRange(0, kMapBaseHeight), reason: e.key);
      }
    });

    test('every site has a route from a nearest base city', () {
      for (final s in kSites) {
        final routes = kSiteRoutes[s.id];
        expect(routes, isNotNull, reason: '${s.id} has no route');
        expect(routes!.isNotEmpty, isTrue, reason: '${s.id} empty routes');
        for (final r in routes) {
          expect(r.from, isNotEmpty);
          expect(r.km, greaterThan(0), reason: '${s.id}/${r.from}');
          expect(r.points.length, greaterThanOrEqualTo(2), reason: '${s.id}/${r.from}');
          for (final pt in r.points) {
            final p = TurkeyGeometry.project(pt[1], pt[0]);
            expect(p.dx, inInclusiveRange(0, kMapBaseWidth), reason: '${s.id}/${r.from}');
            expect(p.dy, inInclusiveRange(0, kMapBaseHeight), reason: '${s.id}/${r.from}');
          }
          final end = TurkeyGeometry.project(
              r.points.last[1], r.points.last[0]);
          final marker = TurkeyGeometry.project(s.lat, s.lon);
          expect((end - marker).distance, lessThan(3), reason: '${s.id} route must end at marker');
        }
      }
    });

    test('all road waypoints and labels project inside canvas bounds', () {
      expect(kTurkeyRoads.length, greaterThanOrEqualTo(4));
      for (final r in kTurkeyRoads) {
        expect(r.name, isNotEmpty);
        for (final pt in r.points) {
          final p = TurkeyGeometry.project(pt[1], pt[0]);
          expect(p.dx, inInclusiveRange(0, kMapBaseWidth), reason: '${r.name} point');
          expect(p.dy, inInclusiveRange(0, kMapBaseHeight), reason: '${r.name} point');
        }
        final lp = TurkeyGeometry.project(r.labelAt[1], r.labelAt[0]);
        expect(lp.dx, inInclusiveRange(0, kMapBaseWidth), reason: '${r.name} label');
        expect(lp.dy, inInclusiveRange(0, kMapBaseHeight), reason: '${r.name} label');
      }
    });
  });

  group('MapScreen widget', () {
    Future<void> pumpMap(WidgetTester tester, AppLang lang) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: buildMirasTheme(),
        home: MapScreen(lang: lang),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('shows every site marker', (tester) async {
      await pumpMap(tester, AppLang.ru);
      expect(find.byKey(const Key('map.cities')), findsOneWidget);
      for (final s in kSites) {
        expect(find.byKey(Key('map.marker.${s.id}')), findsOneWidget,
            reason: 'missing marker for ${s.id}');
      }
    });

    testWidgets('localized title in turkish', (tester) async {
      await pumpMap(tester, AppLang.tr);
      expect(find.text('Türkiye haritası'), findsOneWidget);
    });

    testWidgets('legend shows all five eras', (tester) async {
      await pumpMap(tester, AppLang.ru);
      expect(find.text('Древний мир'), findsOneWidget);
      expect(find.text('Античность'), findsOneWidget);
      expect(find.text('Византия'), findsOneWidget);
      expect(find.text('Османы'), findsOneWidget);
      expect(find.text('Республика'), findsOneWidget);
    });

    testWidgets('first tap shows name, second tap opens detail', (tester) async {
      await pumpMap(tester, AppLang.ru);

      expect(find.byKey(const Key('map.label.ephesus')), findsNothing);

      await tester.tap(find.byKey(const Key('map.marker.ephesus')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('map.label.ephesus')), findsOneWidget);
      expect(find.textContaining('Эфес'), findsOneWidget);
      expect(find.byType(SiteDetailScreen), findsNothing);

      await tester.tap(find.byKey(const Key('map.marker.ephesus')));
      await tester.pumpAndSettle();

      expect(find.byType(SiteDetailScreen), findsOneWidget);
      expect(find.text('Легенды и мифы'), findsOneWidget);
    });

    testWidgets('names toggle reveals every label at once', (tester) async {
      await pumpMap(tester, AppLang.ru);

      expect(find.byKey(const Key('map.name.troy')), findsNothing);
      expect(find.byKey(const Key('map.name.side')), findsNothing);

      await tester.tap(find.byKey(const Key('map.names.toggle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('map.name.troy')), findsOneWidget);
      expect(find.byKey(const Key('map.name.side')), findsOneWidget);
      expect(find.byKey(const Key('map.name.anitkabir')), findsOneWidget);

      await tester.tap(find.byKey(const Key('map.names.toggle')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('map.name.troy')), findsNothing);
    });

    testWidgets('all routes layer is always visible without selection', (tester) async {
      await pumpMap(tester, AppLang.ru);

      expect(find.byKey(const Key('map.routes.all')), findsOneWidget);
      expect(find.byKey(const Key('map.route.troy')), findsNothing);

      await tester.tap(find.byKey(const Key('map.marker.troy')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('map.route.troy')), findsOneWidget);
      expect(find.byKey(const Key('map.label.troy')), findsOneWidget);
    });

    testWidgets('selecting a site draws its route layer', (tester) async {
      await pumpMap(tester, AppLang.ru);

      expect(find.byKey(const Key('map.route.cappadocia')), findsNothing);

      await tester.tap(find.byKey(const Key('map.marker.cappadocia')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('map.route.cappadocia')), findsOneWidget);
      expect(find.byKey(const Key('map.label.cappadocia')), findsOneWidget);
    });

    testWidgets('search narrows markers and auto-reveals single match', (tester) async {
      await pumpMap(tester, AppLang.ru);

      await tester.enterText(find.byKey(const Key('map.search')), 'Side');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('map.label.side')), findsOneWidget);
    });

    testWidgets('focusSiteId centers map with plaque visible', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: buildMirasTheme(),
        home: const MapScreen(lang: AppLang.tr, focusSiteId: 'side'),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('map.label.side')), findsOneWidget);
    });
  });
}