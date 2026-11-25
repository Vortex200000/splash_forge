import 'package:get_it/get_it.dart';
import '../../features/data/local_data/image_tools_data.dart';
import '../../features/data/local_data/local_data.dart';
import '../../features/data/local_data/storage_data.dart';
import '../../features/data/repo/image_tools_repo_impl.dart';
import '../../features/data/repo/main_repo_impl.dart';
import '../../features/data/repo/storage_repo_impl.dart';
import '../../features/domain/image_tools_repo/image_tools_repo.dart';
import '../../features/domain/main_repo/main_repo.dart';
import '../../features/domain/storage_repo/storage_repo.dart';
import '../../features/domain/use_cases/build_export_files_usecase.dart';
import '../../features/domain/use_cases/create_andr12_logo_usecase.dart';
import '../../features/domain/use_cases/create_andr_legacy_logo_usecase.dart';
import '../../features/domain/use_cases/delete_design_usecase.dart';
import '../../features/domain/use_cases/export_logo_usecase.dart';
import '../../features/domain/use_cases/get_designs_usecase.dart';
import '../../features/domain/use_cases/get_settings_usecase.dart';
import '../../features/domain/use_cases/remove_background_usecase.dart';
import '../../features/domain/use_cases/resize_image_usecase.dart';
import '../../features/domain/use_cases/save_design_usecase.dart';
import '../../features/domain/use_cases/save_image_usecase.dart';
import '../../features/domain/use_cases/save_settings_usecase.dart';
import '../../features/presentation/state_management/designs_cubit.dart';
import '../../features/presentation/state_management/image_tools_cubit.dart';
import '../../features/presentation/state_management/settings_cubit.dart';
import '../../features/presentation/state_management/splash_cubit.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt
    // ---- splash editor
    ..registerLazySingleton<LocalData>(() => LocalDataImpl())
    ..registerLazySingleton<MainRepo>(() => MainRepoImpl(getIt()))
    ..registerLazySingleton(() => CreateAndr12LogoUseCase(getIt()))
    ..registerLazySingleton(() => CreateAndrLegacyLogoUseCase(getIt()))
    ..registerLazySingleton(() => ExportLogoUseCase(getIt()))
    ..registerLazySingleton(() => BuildExportFilesUseCase(getIt()))
    // ---- settings and saved designs
    ..registerLazySingleton<StorageData>(() => StorageDataImpl())
    ..registerLazySingleton<StorageRepo>(() => StorageRepoImpl(getIt()))
    ..registerLazySingleton(() => GetSettingsUseCase(getIt()))
    ..registerLazySingleton(() => SaveSettingsUseCase(getIt()))
    ..registerLazySingleton(() => SaveDesignUseCase(getIt()))
    ..registerLazySingleton(() => GetDesignsUseCase(getIt()))
    ..registerLazySingleton(() => DeleteDesignUseCase(getIt()))
    // ---- image tools
    ..registerLazySingleton<ImageToolsData>(() => ImageToolsDataImpl())
    ..registerLazySingleton<ImageToolsRepo>(() => ImageToolsRepoImpl(getIt()))
    ..registerLazySingleton(() => RemoveBackgroundUseCase(getIt()))
    ..registerLazySingleton(() => ResizeImageUseCase(getIt()))
    ..registerLazySingleton(() => SaveImageUseCase(getIt()))
    // ---- state (settings and designs are shared by all pages)
    ..registerLazySingleton(() => SettingsCubit(getIt(), getIt()))
    ..registerLazySingleton(() => DesignsCubit(getIt(), getIt(), getIt()))
    ..registerFactory(() => SplashCubit(getIt(), getIt(), getIt(), getIt(), getIt()))
    ..registerFactory(() => ImageToolsCubit(getIt(), getIt(), getIt()));
}
