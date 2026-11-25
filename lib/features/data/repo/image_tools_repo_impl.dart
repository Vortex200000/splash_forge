import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/error/failure.dart';
import '../../domain/image_tools_repo/image_tools_repo.dart';
import '../local_data/image_tools_data.dart';

class ImageToolsRepoImpl implements ImageToolsRepo {
  final ImageToolsData _data;
  ImageToolsRepoImpl(this._data);

  @override
  Future<Either<Failure, Uint8List>> removeBackground(
    Uint8List bytes, {
    required double pickDx,
    required double pickDy,
    required double tolerance,
    required bool contiguous,
  }) async {
    try {
      return Right(await _data.removeBackground(bytes,
          pickDx: pickDx,
          pickDy: pickDy,
          tolerance: tolerance,
          contiguous: contiguous));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> resize(
    Uint8List bytes, {
    required int width,
    required int height,
    required bool keepRatio,
  }) async {
    try {
      return Right(await _data.resize(bytes,
          width: width, height: height, keepRatio: keepRatio));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> savePng(Uint8List bytes, String fileName) async {
    try {
      final saved = await _data.savePng(bytes, fileName);
      if (!saved) return const Left(Failure(AppStrings.exportCancelled));
      return const Right(unit);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
