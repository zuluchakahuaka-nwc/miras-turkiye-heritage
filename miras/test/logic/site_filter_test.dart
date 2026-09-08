import 'package:flutter_test/flutter_test.dart';
import 'package:miras/data/sites.dart';
import 'package:miras/l10n/strings.dart';
import 'package:miras/logic/site_filter.dart';

void main() {
  group('filterSites', () {
    test('empty query and no era returns everything', () {
      final result = filterSites(kSites, query: '', lang: AppLang.ru);
      expect(result.length, kSites.length);
    });

    test('era filter is exact', () {
      final result = filterSites(kSites, era: Era.ancientWorld, query: '', lang: AppLang.ru);
      expect(result, isNotEmpty);
      expect(result.every((s) => s.era == Era.ancientWorld), isTrue);
    });

    test('every era yields at least one site', () {
      for (final era in Era.values) {
        final result = filterSites(kSites, era: era, query: '', lang: AppLang.ru);
        expect(result, isNotEmpty, reason: 'no sites for era ${era.name}');
      }
    });

    test('search by name in current language', () {
      final ru = filterSites(kSites, query: 'Сиде', lang: AppLang.ru);
      expect(ru.map((s) => s.id), contains('side'));

      final tr = filterSites(kSites, query: 'Efes', lang: AppLang.tr);
      expect(tr.map((s) => s.id), contains('ephesus'));

      final en = filterSites(kSites, query: 'Ephesus', lang: AppLang.en);
      expect(en.map((s) => s.id), contains('ephesus'));
    });

    test('search is case-insensitive and trimmed', () {
      final result = filterSites(kSites, query: '  айя-софия ', lang: AppLang.ru);
      expect(result.map((s) => s.id), contains('hagia-sophia'));
    });

    test('search matches across all languages regardless of UI lang', () {
      final result = filterSites(kSites, query: 'Anıtkabir', lang: AppLang.ru);
      expect(result.map((s) => s.id), contains('anitkabir'));
    });

    test('search matches region', () {
      final result = filterSites(kSites, query: 'Анталья', lang: AppLang.ru);
      expect(result.map((s) => s.id), containsAll(['side', 'aspendos', 'myra']));
    });

    test('combined era and query', () {
      final result = filterSites(kSites,
          era: Era.antiquity, query: 'театр', lang: AppLang.ru);
      expect(result.map((s) => s.id), contains('aspendos'));
      expect(result.every((s) => s.era == Era.antiquity), isTrue);
    });

    test('gibberish query yields empty list', () {
      final result = filterSites(kSites, query: 'zzzz9999', lang: AppLang.ru);
      expect(result, isEmpty);
    });
  });
}
