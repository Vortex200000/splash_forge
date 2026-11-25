import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../entities/saved_design.dart';
import '../storage_repo/storage_repo.dart';

class GetDesignsUseCase {
  final StorageRepo _repo;
  GetDesignsUseCase(this._repo);

  Future<Either<Failure, List<SavedDesign>>> call() => _repo.getDesigns();
}
