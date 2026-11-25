import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../storage_repo/storage_repo.dart';

class DeleteDesignUseCase {
  final StorageRepo _repo;
  DeleteDesignUseCase(this._repo);

  Future<Either<Failure, Unit>> call(String id) => _repo.deleteDesign(id);
}
