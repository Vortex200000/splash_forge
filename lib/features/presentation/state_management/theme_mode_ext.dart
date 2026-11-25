import 'package:flutter/material.dart';
import '../../domain/entities/app_settings.dart';

extension AppThemeModeX on AppThemeMode {
  ThemeMode get material => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}
