import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/settings_strings.dart';
import '../../domain/entities/saved_design.dart';
import '../../domain/use_cases/delete_design_usecase.dart';
import '../../domain/use_cases/get_designs_usecase.dart';
import '../../domain/use_cases/save_design_usecase.dart';

class DesignsState extends Equatable {
  final List<SavedDesign> designs;
  final bool loading;
  final String? message;
  const DesignsState({this.designs = const [], this.loading = false, this.message});

  DesignsState copyWith({List<SavedDesign>? designs, bool? loading, String? message}) =>
      DesignsState(
        designs: designs ?? this.designs,
        loading: loading ?? this.loading,
        message: message, // cleared unless passed again
      );

  @override
  List<Object?> get props => [designs, loading, message];
}

class DesignsCubit extends Cubit<DesignsState> {
  final GetDesignsUseCase _get;
  final SaveDesignUseCase _save;
  final DeleteDesignUseCase _delete;
  DesignsCubit(this._get, this._save, this._delete) : super(const DesignsState());

  Future<void> load({String? message}) async {
    emit(state.copyWith(loading: true));
    final r = await _get();
    r.fold(
      (f) => emit(state.copyWith(loading: false, message: f.message)),
      (list) => emit(DesignsState(designs: list, message: message)),
    );
  }

  /// [files] keys are paths inside the design folder, e.g.
  /// 'assets/splash/logo.png'. [config] holds colors, sliders, etc.
  Future<void> save({
    String? name,
    required Map<String, List<int>> files,
    required Map<String, dynamic> config,
  }) async {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final label = name ??
        'Design ${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}';
    final r = await _save(name: label, files: files, config: config);
    await r.fold(
      (f) async => emit(state.copyWith(message: f.message)),
      (_) => load(message: SettingsStrings.designSaved),
    );
  }

  Future<void> delete(String id) async {
    final r = await _delete(id);
    await r.fold(
      (f) async => emit(state.copyWith(message: f.message)),
      (_) => load(message: SettingsStrings.designDeleted),
    );
  }
}
