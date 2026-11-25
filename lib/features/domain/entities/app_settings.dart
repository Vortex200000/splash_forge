import 'package:equatable/equatable.dart';

enum AppThemeMode { system, light, dark }

enum PreviewMode { both, toggle }

class AppSettings extends Equatable {
  final String folderName;
  final bool autoSave;
  final AppThemeMode themeMode;
  final PreviewMode previewMode;
  final int splashColor; // ARGB, default for new designs
  final int splashColorDark;
  final int iconBgColor;
  final double k; // default original-logo roundness
  final double radius; // default corner radius

  const AppSettings({
    this.folderName = 'SplashForge',
    this.autoSave = true,
    this.themeMode = AppThemeMode.system,
    this.previewMode = PreviewMode.both,
    this.splashColor = 0xFFFFFFFF,
    this.splashColorDark = 0xFF002B36,
    this.iconBgColor = 0xFF1A3F46,
    this.k = 0.22,
    this.radius = 0,
  });

  AppSettings copyWith({
    String? folderName,
    bool? autoSave,
    AppThemeMode? themeMode,
    PreviewMode? previewMode,
    int? splashColor,
    int? splashColorDark,
    int? iconBgColor,
    double? k,
    double? radius,
  }) =>
      AppSettings(
        folderName: folderName ?? this.folderName,
        autoSave: autoSave ?? this.autoSave,
        themeMode: themeMode ?? this.themeMode,
        previewMode: previewMode ?? this.previewMode,
        splashColor: splashColor ?? this.splashColor,
        splashColorDark: splashColorDark ?? this.splashColorDark,
        iconBgColor: iconBgColor ?? this.iconBgColor,
        k: k ?? this.k,
        radius: radius ?? this.radius,
      );

  @override
  List<Object?> get props => [folderName, autoSave, themeMode, previewMode,
        splashColor, splashColorDark, iconBgColor, k, radius];
}
