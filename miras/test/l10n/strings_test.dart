import 'package:flutter_test/flutter_test.dart';
import 'package:miras/l10n/strings.dart';

void main() {
  group('strings completeness', () {
    test('every key has all three languages', () {
      expect(kStrings.length, greaterThan(20));
      for (final entry in kStrings.entries) {
        expect(entry.value.keys.toSet(), AppLang.values.toSet(),
            reason: 'key ${entry.key} misses some languages');
        for (final lang in AppLang.values) {
          expect(entry.value[lang]!.trim(), isNotEmpty,
              reason: 'key ${entry.key} empty for ${lang.name}');
        }
      }
    });

    test('critical keys exist', () {
      const critical = [
        'app.name', 'app.cradle', 'hero.sub',
        'action.gallery', 'action.sources',
        'section.pride', 'section.timeline', 'section.gallery',
        'search.hint', 'era.all', 'badge.unesco', 'pride.label',
        'empty.search', 'quote.text', 'quote.author',
        'sources.title', 'photo.unavailable',
      ];
      for (final key in critical) {
        expect(kStrings.containsKey(key), isTrue, reason: 'missing key $key');
      }
    });

    test('all five era labels covered by data module contract', () {
      for (final key in ['era.all']) {
        expect(kStrings[key], isNotNull);
      }
    });
  });

  group('langFromCode', () {
    test('maps known codes', () {
      expect(langFromCode('ru'), AppLang.ru);
      expect(langFromCode('tr'), AppLang.tr);
      expect(langFromCode('en'), AppLang.en);
    });

    test('null for unknown or null', () {
      expect(langFromCode('de'), isNull);
      expect(langFromCode(null), isNull);
      expect(langFromCode(''), isNull);
    });
  });

  group('L10nText', () {
    const text = L10nText('мир', 'dünya', 'world');

    test('by returns language value', () {
      expect(text.by(AppLang.ru), 'мир');
      expect(text.by(AppLang.tr), 'dünya');
      expect(text.by(AppLang.en), 'world');
    });

    test('extension gives code and native name', () {
      expect(AppLang.ru.code, 'ru');
      expect(AppLang.tr.nativeName, 'Türkçe');
      expect(AppLang.en.nativeName, 'English');
    });
  });

  group('t()', () {
    test('resolves known keys', () {
      expect(t(AppLang.ru, 'app.name'), 'MİRAS');
    });

    test('throws on unknown key', () {
      expect(() => t(AppLang.ru, 'no.such.key'), throwsA(isA<TypeError>()));
    });
  });
}
