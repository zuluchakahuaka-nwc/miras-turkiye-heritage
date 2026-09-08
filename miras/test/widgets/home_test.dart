import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miras/core/locale_store.dart';
import 'package:miras/core/theme.dart';
import 'package:miras/data/manifest.dart';
import 'package:miras/l10n/strings.dart';
import 'package:miras/ui/screens/gallery_screen.dart';
import 'package:miras/ui/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ImageRegistry.load();
  });

  setUp(() {
    LocaleStore.instance.current.value = AppLang.ru;
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildMirasTheme(),
      home: const HomeScreen(),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('renders hero, stats and pride banners', (tester) async {
    tester.view.physicalSize = const Size(420, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await pumpHome(tester);

    expect(find.byKey(const Key('home.appbar')), findsOneWidget);
    expect(find.text('Колыбель цивилизаций'), findsOneWidget);
    expect(find.byKey(const Key('home.stats')), findsOneWidget);
    expect(find.text('12 000'), findsOneWidget);
    expect(find.text('1923'), findsOneWidget);
    expect(find.byKey(const Key('home.pride.gobekli-tepe')), findsOneWidget);
    expect(find.text('«Как счастливо тому, кто может сказать: я — турк!»'),
        findsOneWidget);
  });

  testWidgets('timeline becomes visible after scrolling', (tester) async {
    await pumpHome(tester);

    await tester.dragUntilVisible(
      find.byKey(const Key('home.timeline')),
      find.byType(ListView).first,
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    expect(find.text('9500 до н. э.'), findsOneWidget);
  });

  testWidgets('cta opens the gallery', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byKey(const Key('home.gallery.cta')));
    await tester.pumpAndSettle();

    expect(find.byType(GalleryScreen), findsOneWidget);
    expect(find.text('Галерея наследия'), findsOneWidget);
  });

  testWidgets('language menu switches ui to turkish', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byKey(const Key('home.lang.menu')));
    await tester.pumpAndSettle();

    expect(find.text('Türkçe'), findsOneWidget);
    await tester.tap(find.text('Türkçe').last);
    await tester.pumpAndSettle();

    expect(find.text('Uygarlıkların beşiği'), findsOneWidget);
    expect(find.text('Колыбель цивилизаций'), findsNothing);
  });

  testWidgets('language menu switches ui to english', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byKey(const Key('home.lang.menu')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(find.text('Cradle of civilisations'), findsOneWidget);
  });
}
