import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/helpers/color_helper.dart';
import '../../domain/use_cases/create_andr12_logo_usecase.dart';
import '../../domain/use_cases/create_andr_legacy_logo_usecase.dart';
import '../../domain/use_cases/export_logo_usecase.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final CreateAndr12LogoUseCase _createAndr12;
  final CreateAndrLegacyLogoUseCase _createLegacy;
  final ExportLogoUseCase _export;

  SplashCubit(this._createAndr12, this._createLegacy, this._export)
      : super(const SplashState());

  Future<void> setLogo(Uint8List bytes) async {
    emit(state.copyWith(logo: bytes));
    await regenerate();
  }

  void setSplashColor(Color c) => emit(state.copyWith(splashColor: c));
  void setSplashColorDark(Color c) => emit(state.copyWith(splashColorDark: c));
  void setIconBgColor(Color c) => emit(state.copyWith(iconBgColor: c));
  void setRadius(double v) => emit(state.copyWith(radius: v));
  void setK(double v) => emit(state.copyWith(k: v)); // call regenerate() on slider end

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

  Future<void> export() async {
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
      splashColorDark :state.splashColorDark.hex,
      iconBgColor: state.iconBgColor.hex,
      useIconBg: state.useIconBg,
    );
    emit(state.copyWith(
      busy: false,
      message: r.fold((f) => f.message, (_) => AppStrings.exported),
    ));
  }
}
