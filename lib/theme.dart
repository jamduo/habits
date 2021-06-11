import 'package:flutter/material.dart';

dynamic makeLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.deepPurple,
    accentColor: Colors.purple,
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.deepPurple,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Colors.deepPurple,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple
    ),
  );
}

dynamic makeDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.deepPurple,
    accentColor: Colors.purple,
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.deepPurple,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Colors.deepPurple,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple
    ),
  );
}
