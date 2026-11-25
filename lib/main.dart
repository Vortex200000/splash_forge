import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_strings.dart';
import 'core/di/service_locator.dart';
import 'features/presentation/state_management/settings_cubit.dart';
import 'features/presentation/state_management/theme_mode_ext.dart';
import 'features/presentation/views/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await getIt<SettingsCubit>().load(); // theme and defaults are ready at launch
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: getIt<SettingsCubit>(),
      buildWhen: (a, b) => a.settings.themeMode != b.settings.themeMode,
      builder: (_, s) => MaterialApp(
        title: AppStrings.appName,
        themeMode: s.settings.themeMode.material,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.dark,
        ),
        home: const HomeView(),
      ),
    );
  }
}
