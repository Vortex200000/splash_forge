import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';

abstract class MainRepo {
  Future<Either<Failure, Uint8List>> createAndr12Logo(
    Uint8List logo, {
    required double k,
    required double radius,
    required bool useIconBg,
  });

  Future<Either<Failure, Uint8List>> createAndrLegacyLogo(
    Uint8List logo, {
    required double radius,
  });

  Future<Either<Failure, Unit>> exportLogo({
    required Uint8List android12,
    required Uint8List legacy,
    required String splashColor,
    required String iconBgColor,
    required bool useIconBg,
  });
}
