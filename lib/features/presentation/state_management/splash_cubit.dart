import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/settings_strings.dart';
import '../../../core/helpers/color_helper.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/use_cases/build_export_files_usecase.dart';
import '../../domain/use_cases/create_andr12_logo_usecase.dart';
import '../../domain/use_cases/create_andr_legacy_logo_usecase.dart';
import '../../domain/use_cases/export_logo_usecase.dart';
import '../../domain/use_cases/save_design_usecase.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final CreateAndr12LogoUseCase _createAndr12;
  final CreateAndrLegacyLogoUseCase _createLegacy;
  final ExportLogoUseCase _export;
  final BuildExportFilesUseCase _buildFiles;
  final SaveDesignUseCase _saveDesign;

  SplashCubit(this._createAndr12, this._createLegacy, this._export,
      this._buildFiles, this._saveDesign)
      : super(const SplashState());

  /// Starts a new design from the defaults chosen in Settings.
  void applyDefaults(AppSettings d) => emit(state.copyWith(
        splashColor: Color(d.splashColor),
        splashColorDark: Color(d.splashColorDark),
        iconBgColor: Color(d.iconBgColor),
        k: d.k,
        radius: d.radius,
      ));

  Future<void> setLogo(Uint8List bytes) async {
    emit(state.copyWith(logo: bytes));
    await regenerate();
  }

  void setSplashColor(Color c) => emit(state.copyWith(splashColor: c));
  void setSplashColorDark(Color c) => emit(state.copyWith(splashColorDark: c));
  void setIconBgColor(Color c) => emit(state.copyWith(iconBgColor: c));
  void setRadius(double v) => emit(state.copyWith(radius: v));
  void setK(double v) => emit(state.copyWith(k: v)); // call regenerate() on slider end
  void setPreviewDark(bool v) => emit(state.copyWith(previewDark: v));

  Future<void> setUseIconBg(bool v) async {
    emit(state.copyWith(useIconBg: v));
    await regenerate();
  }

  Future<void> regenerate() async {
    final logo = state.logo;
    if (logo == null) return;
    emit(state.copyWith(busy: true));

    final r12 = await _createAndr12(logo,
        k: state.k, radius: state.radius, useIconBg: state.useIconBg);
    final rl = await _createLegacy(logo, radius: state.radius);

    r12.fold(
      (f) => emit(state.copyWith(busy: false, message: f.message)),
      (a12) => rl.fold(
        (f) => emit(state.copyWith(busy: false, message: f.message)),
        (leg) => emit(state.copyWith(android12: a12, legacy: leg, busy: false)),
      ),
    );
  }

  /// Exports the ZIP. When [autoSave] is true the design is also kept in My designs.
  Future<void> export({bool autoSave = false}) async {
    final a12 = state.android12, leg = state.legacy;
    if (a12 == null || leg == null) {
      emit(state.copyWith(message: AppStrings.noLogo));
      return;
    }
    emit(state.copyWith(busy: true));
    final r = await _export(
      android12: a12,
      legacy: leg,
      splashColor: state.splashColor.hex,
      splashColorDark: state.splashColorDark.hex,
      iconBgColor: state.iconBgColor.hex,
      useIconBg: state.useIconBg,
    );
    String? message = r.fold((f) => f.message, (_) => AppStrings.exported);
    if (r.isRight() && autoSave) {
      final error = await _keepDesign();
      if (error != null) message = error;
    }
    emit(state.copyWith(busy: false, message: message));
  }

  /// Saves the current design to My designs (the "Save design" button).
  Future<void> saveDesign() async {
    if (state.android12 == null || state.legacy == null) {
      emit(state.copyWith(message: AppStrings.noLogo));
      return;
    }
    emit(state.copyWith(busy: true));
    final error = await _keepDesign();
    emit(state.copyWith(busy: false, message: error ?? SettingsStrings.designSaved));
  }

  /// Returns an error message, or null when the design was saved.
  Future<String?> _keepDesign() async {
    final a12 = state.android12!, leg = state.legacy!;
    final filesResult = await _buildFiles(
      android12: a12,
      legacy: leg,
      splashColor: state.splashColor.hex,
      splashColorDark: state.splashColorDark.hex,
      iconBgColor: state.iconBgColor.hex,
      useIconBg: state.useIconBg,
    );
    return filesResult.fold<Future<String?>>(
      (f) async => f.message,
      (files) async {
        final logo = state.logo;
        if (logo != null) files['source.png'] = logo; // original, for later
        final saved = await _saveDesign(
          name: _defaultName(),
          files: files,
          config: {
            'splashColor': state.splashColor.hex,
            'splashColorDark': state.splashColorDark.hex,
            'iconBgColor': state.iconBgColor.hex,
            'useIconBg': state.useIconBg,
            'k': state.k,
            'radius': state.radius,
          },
        );
        return saved.fold((f) => f.message, (_) => null);
      },
    );
  }

  String _defaultName() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return 'Design ${n.year}-${two(n.month)}-${two(n.day)} ${two(n.hour)}:${two(n.minute)}';
  }
}
