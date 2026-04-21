import 'package:flutter/material.dart';
import '../core/design/app_design_system.dart';

// ─── Enum des modes de thème ──────────────────────────────────────────────────
enum AppThemeMode { app }

// ─── Provider ────────────────────────────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.app;

  AppThemeMode get mode => _mode;

  /// Mode Flutter natif pour MaterialApp.themeMode
  ThemeMode get flutterThemeMode => ThemeMode.light;

  /// ThemeData personnalisé principal de l'application
  ThemeData? get customTheme => AppThemeData.theme;

  void setMode(AppThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}
