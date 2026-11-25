import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../entities/app_settings.dart';
import '../entities/saved_design.dart';

abstract class StorageRepo {
  Future<Either<Failure, AppSettings>> getSettings();
  Future<Either<Failure, Unit>> saveSettings(AppSettings settings);
  Future<Either<Failure, SavedDesign>> saveDesign({
    required String name,
    required Map<String, List<int>> files,
    required Map<String, dynamic> config,
  });
  Future<Either<Failure, List<SavedDesign>>> getDesigns();
  Future<Either<Failure, Unit>> deleteDesign(String id);
}
