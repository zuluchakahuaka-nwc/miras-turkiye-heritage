import 'package:flutter/material.dart';

class MirasColors {
  static const ink = Color(0xFF0E2A2B);
  static const teal = Color(0xFF14636B);
  static const turquoise = Color(0xFF2AA198);
  static const gold = Color(0xFFC9A227);
  static const goldLight = Color(0xFFE8C766);
  static const ivory = Color(0xFFF7F2E5);
  static const paper = Color(0xFFFBF8EF);
  static const terracotta = Color(0xFFB0532F);
  static const bodyText = Color(0xFF3A4A4A);
}

ThemeData buildMirasTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    colorScheme: ColorScheme.fromSeed(seedColor: MirasColors.teal).copyWith(
      surface: MirasColors.paper,
      primary: MirasColors.teal,
      secondary: MirasColors.gold,
      error: MirasColors.terracotta,
    ),
  );
  return base.copyWith(
    scaffoldBackgroundColor: MirasColors.paper,
    appBarTheme: const AppBarTheme(
      backgroundColor: MirasColors.ink,
      foregroundColor: MirasColors.goldLight,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: base.textTheme
        .apply(
          bodyColor: MirasColors.bodyText,
          displayColor: MirasColors.ink,
          fontFamily: 'Manrope',
        )
        .copyWith(
          displayLarge: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.w700,
            color: MirasColors.ink,
            fontSize: 40,
            height: 1.15,
          ),
          displayMedium: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.w700,
            color: MirasColors.ink,
            fontSize: 32,
            height: 1.2,
          ),
          headlineMedium: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.w700,
            color: MirasColors.ink,
            fontSize: 26,
          ),
          titleLarge: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.w700,
            color: MirasColors.ink,
            fontSize: 21,
            height: 1.25,
          ),
          titleMedium: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            color: MirasColors.ink,
            fontSize: 16,
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            height: 1.55,
            color: MirasColors.bodyText,
          ),
          bodyLarge: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 15.5,
            height: 1.6,
            color: MirasColors.bodyText,
          ),
          labelSmall: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 1.3,
            color: MirasColors.terracotta,
          ),
        ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: MirasColors.ivory,
      selectedColor: MirasColors.teal,
      labelStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
        color: MirasColors.ink,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFF9A9A8C), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x33C9A227)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x33C9A227)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MirasColors.gold, width: 1.6),
      ),
      prefixIconColor: MirasColors.teal,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x2214636B)),
      ),
    ),
  );
}
