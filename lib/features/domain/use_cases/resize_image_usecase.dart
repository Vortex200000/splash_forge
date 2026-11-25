import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../image_tools_repo/image_tools_repo.dart';

class ResizeImageUseCase {
  final ImageToolsRepo _repo;
  ResizeImageUseCase(this._repo);

  Future<Either<Failure, Uint8List>> call(
    Uint8List bytes, {
    required int width,
    required int height,
    required bool keepRatio,
  }) =>
      _repo.resize(bytes, width: width, height: height, keepRatio: keepRatio);
}
