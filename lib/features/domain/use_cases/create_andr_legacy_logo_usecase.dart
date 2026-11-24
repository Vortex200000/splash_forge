import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../main_repo/main_repo.dart';

class CreateAndrLegacyLogoUseCase {
  final MainRepo _repo;
  CreateAndrLegacyLogoUseCase(this._repo);

  Future<Either<Failure, Uint8List>> call(Uint8List logo, {required double radius}) =>
      _repo.createAndrLegacyLogo(logo, radius: radius);
}
