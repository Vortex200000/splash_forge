import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/error/failure.dart';
import '../../domain/main_repo/main_repo.dart';
import '../local_data/local_data.dart';

class MainRepoImpl implements MainRepo {
  final LocalData _local;
  MainRepoImpl(this._local);

  @override
  Future<Either<Failure, Uint8List>> createAndr12Logo(
    Uint8List logo, {
    required double k,
    required double radius,
    required bool useIconBg,
  }) async {
    try {
      return Right(await _local.createDesign(logo, k: k, radius: radius, useIconBg: useIconBg));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> createAndrLegacyLogo(
    Uint8List logo, {
    required double radius,
  }) async {
    try {
      return Right(await _local.createDesign(logo, legacy: true, radius: radius));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> exportLogo({
    required Uint8List android12,
    required Uint8List legacy,
    required String splashColor,
    required String iconBgColor,
    required bool useIconBg,
  }) async {
    try {
      final yaml = _local.buildYaml(
          splashColor: splashColor,
          iconBgColor: iconBgColor,
          useIconBg: useIconBg);
      final saved = await _local.saveZip({
        'assets/splash/logo_android12.png': android12,
        'assets/splash/logo.png': legacy,
        'flutter_native_splash.yaml': yaml.codeUnits,
      });
      if (!saved) return const Left(Failure(AppStrings.exportCancelled));
      return const Right(unit);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
