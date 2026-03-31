import 'package:flutter/material.dart';

import 'theme/app_theme_indeed.dart';

// ─── Enum des modes de thème ──────────────────────────────────────────────────
enum AppThemeMode { indeed }

// ─── Provider ────────────────────────────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.indeed;

  AppThemeMode get mode => _mode;

  /// Mode Flutter natif pour MaterialApp.themeMode
  ThemeMode get flutterThemeMode => ThemeMode.light;

  /// ThemeData personnalisé (non-null pour Indeed)
  ThemeData? get customTheme => AppThemeIndeed.theme;

  void setMode(AppThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}
