import 'dart:ui' show PlatformDispatcher;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsBinding;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/era_music.dart';
import 'core/locale_store.dart';
import 'core/logger.dart';
import 'core/theme.dart';
import 'data/manifest.dart';
import 'l10n/strings.dart';
import 'ui/screens/home_screen.dart';

class AudioplayersAdapter implements AudioAdapter {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> playLoop(String path) async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(DeviceFileSource(path));
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }
}

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
  try {
    final docs = await getApplicationDocumentsDirectory();
    EraMusicStore.instance = EraMusicStore(docs);
  } catch (e) {
    Logger.warning('era music store init failed: $e');
  }
  EraMusicController.adapter = AudioplayersAdapter();
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
