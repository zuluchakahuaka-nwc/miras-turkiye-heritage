import 'package:flutter_test/flutter_test.dart';
import 'package:miras/core/locale_store.dart';
import 'package:miras/l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleStore', () {
    test('restores saved language from prefs', () async {
      SharedPreferences.setMockInitialValues({LocaleStore.prefsKey: 'tr'});
      final prefs = await SharedPreferences.getInstance();
      final store = LocaleStore.instance;

      await store.init(prefs);
      expect(store.current.value, AppLang.tr);
    });

    test('falls back to device locale when nothing saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = LocaleStore.instance;

      await store.init(prefs);
      expect(store.current.value, AppLang.en);
    });

    test('set updates notifier and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = LocaleStore.instance;
      await store.init(prefs);

      await store.set(AppLang.tr);
      expect(store.current.value, AppLang.tr);
      expect(prefs.getString(LocaleStore.prefsKey), 'tr');

      await store.set(AppLang.en);
      expect(store.current.value, AppLang.en);
      expect(prefs.getString(LocaleStore.prefsKey), 'en');
    });
  });
}
