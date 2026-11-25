import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../entities/app_settings.dart';
import '../storage_repo/storage_repo.dart';

class GetSettingsUseCase {
  final StorageRepo _repo;
  GetSettingsUseCase(this._repo);

  Future<Either<Failure, AppSettings>> call() => _repo.getSettings();
}
