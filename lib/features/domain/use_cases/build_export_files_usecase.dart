import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../main_repo/main_repo.dart';

/// Builds the same files the ZIP contains (PNGs + YAML) without saving them.
class BuildExportFilesUseCase {
  final MainRepo _repo;
  BuildExportFilesUseCase(this._repo);

  Future<Either<Failure, Map<String, List<int>>>> call({
    required Uint8List android12,
    required Uint8List legacy,
    required String splashColor,
    required String splashColorDark,
    required String iconBgColor,
    required bool useIconBg,
  }) =>
      _repo.buildExportFiles(
          android12: android12,
          legacy: legacy,
          splashColor: splashColor,
          splashColorDark: splashColorDark,
          iconBgColor: iconBgColor,
          useIconBg: useIconBg);
}
