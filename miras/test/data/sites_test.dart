import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miras/data/sites.dart';
import 'package:miras/l10n/strings.dart';

void checkL10n(L10nText text, String field, String id) {
  expect(text.ru.trim(), isNotEmpty, reason: '$id.$field.ru is empty');
  expect(text.tr.trim(), isNotEmpty, reason: '$id.$field.tr is empty');
  expect(text.en.trim(), isNotEmpty, reason: '$id.$field.en is empty');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('sites data', () {
    test('has exactly 26 sites', () {
      expect(kSites.length, 26);
    });

    test('site ids are unique slugs', () {
      final ids = kSites.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')));
      }
    });

    test('every site has complete trilingual content', () {
      for (final s in kSites) {
        checkL10n(s.name, 'name', s.id);
        checkL10n(s.region, 'region', s.id);
        checkL10n(s.date, 'date', s.id);
        checkL10n(s.desc, 'desc', s.id);
        checkL10n(s.pride, 'pride', s.id);
        checkL10n(s.legend, 'legend', s.id);
        checkL10n(s.gettingThere, 'gettingThere', s.id);
        expect(s.desc.ru.length, greaterThan(60), reason: '${s.id} desc too short');
        expect(s.pride.ru.length, greaterThan(20), reason: '${s.id} pride too short');
        expect(s.legend.ru.length, greaterThan(40), reason: '${s.id} legend too short');
        expect(s.gettingThere.ru.length, greaterThan(30), reason: '${s.id} gettingThere too short');
      }
    });

    test('coordinates fall within Türkiye bounding box', () {
      for (final s in kSites) {
        expect(s.lat, inInclusiveRange(35.5, 42.5), reason: '${s.id} lat');
        expect(s.lon, inInclusiveRange(25.5, 45.0), reason: '${s.id} lon');
      }
    });

    test('formatCoords renders degrees', () {
      final c = formatCoords(37.2233, 38.9225);
      expect(c, '37.2233° N, 38.9225° E');
    });

    test('unesco years are plausible or absent', () {
      for (final s in kSites) {
        if (s.unesco != null) {
          expect(s.unesco!, inInclusiveRange(1972, 2030), reason: '${s.id} unesco year');
        }
      }
    });

    test('every era has a label in three languages', () {
      expect(kEraLabels.keys.toSet(), Era.values.toSet());
      for (final era in Era.values) {
        checkL10n(eraLabel(era), 'eraLabel', era.name);
      }
    });

    test('timeline is strictly ordered by year', () {
      final years = kTimeline.map((e) => e.year).toList();
      for (var i = 1; i < years.length; i++) {
        expect(years[i], greaterThan(years[i - 1]),
            reason: 'timeline not ordered at index $i');
      }
      for (final e in kTimeline) {
        checkL10n(e.title, 'timeline', e.year.toString());
      }
    });

    test('featured sites exist and reference valid entries', () {
      final featured = kSites.where((s) => s.featured).toList();
      expect(featured.length, greaterThanOrEqualTo(4));
      expect(featured.length, lessThanOrEqualTo(8));
    });
  });

  group('formatYear', () {
    test('BC years are formatted per language', () {
      expect(formatYear(-9500, AppLang.ru), contains('до н. э.'));
      expect(formatYear(-9500, AppLang.tr), startsWith('MÖ'));
      expect(formatYear(-9500, AppLang.en), endsWith('BC'));
    });

    test('AD years below 1000 are formatted per language', () {
      expect(formatYear(537, AppLang.ru), '537 г.');
      expect(formatYear(537, AppLang.tr), '537');
      expect(formatYear(537, AppLang.en), 'AD 537');
    });

    test('modern years are plain numbers', () {
      for (final lang in AppLang.values) {
        expect(formatYear(1923, lang), '1923');
      }
    });
  });

  group('assets manifest consistency', () {
    final manifestFile = File('assets/images/manifest.json');

    test('manifest exists and parses', () {
      expect(manifestFile.existsSync(), isTrue,
          reason: 'run scripts/fetch_images.ps1 to generate the manifest');
      final data = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      expect(data['images'], isA<List<dynamic>>());
    });

    test('every site has a manifest entry and file on disk', () {
      final data = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      final entries = (data['images'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => e['site'] as String)
          .toSet();
      final siteIds = kSites.map((s) => s.id).toSet();
      expect(entries.difference(siteIds), isEmpty,
          reason: 'manifest has unknown site ids');
      expect(siteIds.difference(entries), isEmpty,
          reason: 'sites missing from manifest');
    });

    test('every manifest file exists and is a real image', () {
      final data = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      final images = (data['images'] as List<dynamic>).whereType<Map<String, dynamic>>();
      for (final e in images) {
        final file = e['file'];
        if (file == null) continue;
        final f = File('assets/images/$file');
        expect(f.existsSync(), isTrue, reason: 'missing asset $file');
        expect(f.lengthSync(), greaterThan(30000), reason: 'asset $file suspiciously small');
      }
    });
  });
}
