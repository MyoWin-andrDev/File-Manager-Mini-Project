import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_management/shared_preferences/theme_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Theme mode is persisted with shared preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final ThemePreferences prefs = ThemePreferences();

    await prefs.saveThemeMode(ThemeMode.dark);
    final ThemeMode storedThemeMode = await prefs.loadThemeMode();

    expect(storedThemeMode, ThemeMode.dark);
  });
}
