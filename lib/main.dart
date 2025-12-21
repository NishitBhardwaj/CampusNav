/// CampusNav - Main Entry Point
///
/// Offline-first indoor navigation app for campus environments.
/// Built with Flutter using Clean Architecture principles.

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'config/routes.dart';
import 'config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampusNavApp());
}

class CampusNavApp extends StatelessWidget {
  const CampusNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: AppConfig.enableDebugMode,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Routing
      initialRoute: Routes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
