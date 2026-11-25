import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/saved_design.dart';
import '../../domain/storage_repo/storage_repo.dart';
import '../local_data/storage_data.dart';

class StorageRepoImpl implements StorageRepo {
  final StorageData _data;
  StorageRepoImpl(this._data);

  Future<Either<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppSettings>> getSettings() =>
      _run(() => _data.getSettings());

  @override
  Future<Either<Failure, Unit>> saveSettings(AppSettings settings) =>
      _run(() async {
        await _data.saveSettings(settings);
        return unit;
      });

  @override
  Future<Either<Failure, SavedDesign>> saveDesign({
    required String name,
    required Map<String, List<int>> files,
    required Map<String, dynamic> config,
  }) =>
      _run(() => _data.saveDesign(name: name, files: files, config: config));

  @override
  Future<Either<Failure, List<SavedDesign>>> getDesigns() =>
      _run(() => _data.listDesigns());

  @override
  Future<Either<Failure, Unit>> deleteDesign(String id) =>
      _run(() async {
        await _data.deleteDesign(id);
        return unit;
      });
}
