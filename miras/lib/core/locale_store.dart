import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';

class LocaleStore {
  LocaleStore._();

  static final LocaleStore instance = LocaleStore._();
  static const String prefsKey = 'miras.lang';

  final ValueNotifier<AppLang> current = ValueNotifier(AppLang.ru);
  SharedPreferences? _prefs;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    final saved = prefs.getString(prefsKey);
    AppLang? lang = langFromCode(saved);
    lang ??= langFromCode(
      WidgetsBinding.instance.platformDispatcher.locale.languageCode,
    );
    current.value = lang ?? AppLang.ru;
  }

  Future<void> set(AppLang lang) async {
    current.value = lang;
    await _prefs?.setString(prefsKey, lang.code);
  }
}
