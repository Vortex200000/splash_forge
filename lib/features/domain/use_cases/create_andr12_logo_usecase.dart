import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../main_repo/main_repo.dart';

class CreateAndr12LogoUseCase {
  final MainRepo _repo;
  CreateAndr12LogoUseCase(this._repo);

  Future<Either<Failure, Uint8List>> call(Uint8List logo,
          {required double k, required double radius, required bool useIconBg}) =>
      _repo.createAndr12Logo(logo, k: k, radius: radius, useIconBg: useIconBg);
}
