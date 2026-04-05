import 'package:file_management/home/home.dart';
import 'package:file_management/shared_preferences/theme_preferences.dart';
import 'package:file_management/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ThemePreferences themePreferences = ThemePreferences();
  final ThemeMode initialThemeMode = await themePreferences.loadThemeMode();

  runApp(
    MyApp(
      themePreferences: themePreferences,
      initialThemeMode: initialThemeMode,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.themePreferences,
    required this.initialThemeMode,
  });

  final ThemePreferences themePreferences;
  final ThemeMode initialThemeMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  Future<void> _onThemeModeChanged(ThemeMode newThemeMode) async {
    if (_themeMode == newThemeMode) return;

    setState(() {
      _themeMode = newThemeMode;
    });

    await widget.themePreferences.saveThemeMode(newThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File Management',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: Home(
        currentThemeMode: _themeMode,
        onThemeModeChanged: _onThemeModeChanged,
      ),
    );
  }
}
