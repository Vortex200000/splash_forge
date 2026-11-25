import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../image_tools_repo/image_tools_repo.dart';

class RemoveBackgroundUseCase {
  final ImageToolsRepo _repo;
  RemoveBackgroundUseCase(this._repo);

  Future<Either<Failure, Uint8List>> call(
    Uint8List bytes, {
    required double pickDx,
    required double pickDy,
    required double tolerance,
    required bool contiguous,
  }) =>
      _repo.removeBackground(bytes,
          pickDx: pickDx,
          pickDy: pickDy,
          tolerance: tolerance,
          contiguous: contiguous);
}
