import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/di/service_locator.dart';
import 'features/presentation/views/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MaterialApp(
    title: AppStrings.appName,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: const HomeView(),
  ));
}
