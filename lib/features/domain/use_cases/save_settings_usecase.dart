import 'package:dartz/dartz.dart';
import '../../../core/constants/settings_strings.dart';
import '../../../core/error/failure.dart';
import '../../../core/helpers/name_helper.dart';
import '../entities/app_settings.dart';
import '../storage_repo/storage_repo.dart';

class SaveSettingsUseCase {
  final StorageRepo _repo;
  SaveSettingsUseCase(this._repo);

  /// Cleans the folder name and returns the settings that were saved.
  Future<Either<Failure, AppSettings>> call(AppSettings settings) async {
    final name = sanitizeName(settings.folderName);
    if (name.isEmpty) return const Left(Failure(SettingsStrings.invalidName));
    final clean = settings.copyWith(folderName: name);
    final r = await _repo.saveSettings(clean);
    return r.map((_) => clean);
  }
}
