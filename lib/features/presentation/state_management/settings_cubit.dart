import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/settings_strings.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/use_cases/get_settings_usecase.dart';
import '../../domain/use_cases/save_settings_usecase.dart';

class SettingsState extends Equatable {
  final AppSettings settings;
  final String? message;
  const SettingsState({this.settings = const AppSettings(), this.message});

  @override
  List<Object?> get props => [settings, message];
}

class SettingsCubit extends Cubit<SettingsState> {
  final GetSettingsUseCase _get;
  final SaveSettingsUseCase _save;
  SettingsCubit(this._get, this._save) : super(const SettingsState());

  Future<void> load() async {
    final r = await _get();
    r.fold(
      (f) => emit(SettingsState(settings: state.settings, message: f.message)),
      (s) => emit(SettingsState(settings: s)),
    );
  }

  /// Updates the UI only (use while a slider or color picker is moving).
  void preview(AppSettings s) => emit(SettingsState(settings: s));

  /// Saves the current settings to disk.
  Future<void> persist() => update(state.settings);

  Future<void> update(AppSettings s) async {
    final r = await _save(s);
    r.fold(
      (f) => emit(SettingsState(settings: state.settings, message: f.message)),
      (clean) => emit(SettingsState(settings: clean)),
    );
  }

  Future<void> saveFolder(String raw) async {
    final r = await _save(state.settings.copyWith(folderName: raw));
    r.fold(
      (f) => emit(SettingsState(settings: state.settings, message: f.message)),
      (clean) => emit(SettingsState(settings: clean, message: SettingsStrings.saved)),
    );
  }

  Future<void> setAutoSave(bool v) => update(state.settings.copyWith(autoSave: v));
  Future<void> setThemeMode(AppThemeMode m) =>
      update(state.settings.copyWith(themeMode: m));
  Future<void> setPreviewMode(PreviewMode m) =>
      update(state.settings.copyWith(previewMode: m));
}
