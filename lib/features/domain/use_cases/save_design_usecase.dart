import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../entities/saved_design.dart';
import '../storage_repo/storage_repo.dart';

class SaveDesignUseCase {
  final StorageRepo _repo;
  SaveDesignUseCase(this._repo);

  Future<Either<Failure, SavedDesign>> call({
    required String name,
    required Map<String, List<int>> files,
    required Map<String, dynamic> config,
  }) =>
      _repo.saveDesign(name: name, files: files, config: config);
}
