import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsBinding;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/locale_store.dart';
import 'core/logger.dart';
import 'core/theme.dart';
import 'data/manifest.dart';
import 'l10n/strings.dart';
import 'ui/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    SemanticsBinding.instance.ensureSemantics();
  }
  FlutterError.onError = (details) => Logger.error(details.toString());
  PlatformDispatcher.instance.onError = (error, stack) {
    Logger.error('$error');
    return true;
  };
  final prefs = await SharedPreferences.getInstance();
  await LocaleStore.instance.init(prefs);
  await ImageRegistry.load();
  Logger.info('app start, lang=${LocaleStore.instance.current.value.code}');
  runApp(const MirasApp());
}

class MirasApp extends StatelessWidget {
  const MirasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocaleStore.instance.current,
      builder: (context, AppLang lang, _) {
        return MaterialApp(
          title: 'MİRAS',
          debugShowCheckedModeBanner: false,
          theme: buildMirasTheme(),
          home: HomeScreen(),
        );
      },
    );
  }
}
