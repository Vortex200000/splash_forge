import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';

abstract class ImageToolsRepo {
  Future<Either<Failure, Uint8List>> removeBackground(
    Uint8List bytes, {
    required double pickDx,
    required double pickDy,
    required double tolerance,
    required bool contiguous,
  });

  Future<Either<Failure, Uint8List>> resize(
    Uint8List bytes, {
    required int width,
    required int height,
    required bool keepRatio,
  });

  Future<Either<Failure, Unit>> savePng(Uint8List bytes, String fileName);
}
