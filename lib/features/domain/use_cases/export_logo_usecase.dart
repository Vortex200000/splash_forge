import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../main_repo/main_repo.dart';

class ExportLogoUseCase {
  final MainRepo _repo;
  ExportLogoUseCase(this._repo);

  Future<Either<Failure, Unit>> call({
    required Uint8List android12,
    required Uint8List legacy,
    required String splashColor,
    required String iconBgColor,
    required bool useIconBg,
  }) =>
      _repo.exportLogo(
          android12: android12,
          legacy: legacy,
          splashColor: splashColor,
          iconBgColor: iconBgColor,
          useIconBg: useIconBg);
}
