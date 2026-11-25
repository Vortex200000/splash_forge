import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/tools_strings.dart';
import '../../domain/use_cases/remove_background_usecase.dart';
import '../../domain/use_cases/resize_image_usecase.dart';
import '../../domain/use_cases/save_image_usecase.dart';

class ImageToolsState extends Equatable {
  final Uint8List? source;
  final Uint8List? result;
  final bool removeBg;
  final bool contiguous;
  final bool keepRatio;
  final double tolerance;
  final double pickDx; // where the user tapped, 0..1
  final double pickDy;
  final int width;
  final int height;
  final bool busy;
  final String? message;

  const ImageToolsState({
    this.source,
    this.result,
    this.removeBg = true,
    this.contiguous = true,
    this.keepRatio = true,
    this.tolerance = 0.12,
    this.pickDx = 0,
    this.pickDy = 0,
    this.width = 960,
    this.height = 960,
    this.busy = false,
    this.message,
  });

  // message is cleared on every copy unless passed again
  ImageToolsState copyWith({
    Uint8List? source,
    Uint8List? result,
    bool? removeBg,
    bool? contiguous,
    bool? keepRatio,
    double? tolerance,
    double? pickDx,
    double? pickDy,
    int? width,
    int? height,
    bool? busy,
    String? message,
  }) =>
      ImageToolsState(
        source: source ?? this.source,
        result: result ?? this.result,
        removeBg: removeBg ?? this.removeBg,
        contiguous: contiguous ?? this.contiguous,
        keepRatio: keepRatio ?? this.keepRatio,
        tolerance: tolerance ?? this.tolerance,
        pickDx: pickDx ?? this.pickDx,
        pickDy: pickDy ?? this.pickDy,
        width: width ?? this.width,
        height: height ?? this.height,
        busy: busy ?? this.busy,
        message: message,
      );

  @override
  List<Object?> get props => [source, result, removeBg, contiguous, keepRatio,
        tolerance, pickDx, pickDy, width, height, busy, message];
}

class ImageToolsCubit extends Cubit<ImageToolsState> {
  final RemoveBackgroundUseCase _remove;
  final ResizeImageUseCase _resize;
  final SaveImageUseCase _save;
  Uint8List? _cleaned; // background-removed image, reused when only the size changes

  ImageToolsCubit(this._remove, this._resize, this._save)
      : super(const ImageToolsState());

  Future<void> setImage(Uint8List bytes) async {
    _cleaned = null;
    emit(state.copyWith(source: bytes, pickDx: 0, pickDy: 0));
    await process();
  }

  Future<void> setRemoveBg(bool v) async {
    emit(state.copyWith(removeBg: v));
    await process();
  }

  void setTolerance(double v) => emit(state.copyWith(tolerance: v)); // process() on slider end

  Future<void> setContiguous(bool v) async {
    emit(state.copyWith(contiguous: v));
    await process();
  }

  Future<void> setPick(double dx, double dy) async {
    emit(state.copyWith(pickDx: dx.clamp(0.0, 1.0), pickDy: dy.clamp(0.0, 1.0)));
    await process();
  }

  Future<void> setKeepRatio(bool v) async {
    emit(state.copyWith(keepRatio: v));
    await process(clean: false);
  }

  Future<void> setSize(int w, int h) async {
    emit(state.copyWith(width: w.clamp(16, 4096), height: h.clamp(16, 4096)));
    await process(clean: false);
  }

  Future<void> process({bool clean = true}) async {
    final src = state.source;
    if (src == null) return;
    emit(state.copyWith(busy: true));

    var input = src;
    if (state.removeBg) {
      if (clean || _cleaned == null) {
        final r = await _remove(src,
            pickDx: state.pickDx,
            pickDy: state.pickDy,
            tolerance: state.tolerance,
            contiguous: state.contiguous);
        final error = r.fold<String?>((f) => f.message, (bytes) {
          _cleaned = bytes;
          return null;
        });
        if (error != null) {
          emit(state.copyWith(busy: false, message: error));
          return;
        }
      }
      input = _cleaned!;
    }

    final r = await _resize(input,
        width: state.width, height: state.height, keepRatio: state.keepRatio);
    r.fold(
      (f) => emit(state.copyWith(busy: false, message: f.message)),
      (bytes) => emit(state.copyWith(result: bytes, busy: false)),
    );
  }

  Future<void> save() async {
    final bytes = state.result;
    if (bytes == null) {
      emit(state.copyWith(message: ToolsStrings.noImage));
      return;
    }
    final r = await _save(bytes, fileName: 'image_${state.width}x${state.height}.png');
    emit(state.copyWith(message: r.fold((f) => f.message, (_) => ToolsStrings.saved)));
  }
}
