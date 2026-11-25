import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../image_tools_repo/image_tools_repo.dart';

class SaveImageUseCase {
  final ImageToolsRepo _repo;
  SaveImageUseCase(this._repo);

  Future<Either<Failure, Unit>> call(Uint8List bytes, {required String fileName}) =>
      _repo.savePng(bytes, fileName);
}
