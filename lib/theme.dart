import 'package:flutter/material.dart';

dynamic makeTheme(Brightness brightness) {
  final MaterialColor primary = Colors.deepPurple;
  final MaterialColor accent = Colors.purple;

  return ThemeData(
    brightness: brightness,
    primarySwatch: primary,
    primaryColor: primary,
    accentColor: accent,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
    ),
  );
}

dynamic makeLightTheme() {
  return makeTheme(Brightness.light);
}

dynamic makeDarkTheme() {
  return makeTheme(Brightness.dark);
}
