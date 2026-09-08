import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class Logger {
  static const String tag = 'MIRAS';

  static void _log(LogLevel level, String message) {
    debugPrint('[$tag][${level.name.toUpperCase()}] $message');
  }

  static void debug(String message) => _log(LogLevel.debug, message);
  static void info(String message) => _log(LogLevel.info, message);
  static void warning(String message) => _log(LogLevel.warning, message);
  static void error(String message) => _log(LogLevel.error, message);
}
