/// CampusNav - Main Entry Point
///
/// Offline-first indoor navigation app for campus environments.
/// 
/// Phase 0 Foundation:
/// - Clean Architecture
/// - Riverpod state management  
/// - Hive local database
/// - Material 3 theming
/// - Role-based access (User/Admin)
/// - flutter_animate for smooth UI transitions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'config/routes.dart';
import 'config/app_config.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await _initializeHive();

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: CampusNavApp(),
    ),
  );
}

/// Initialize Hive database
Future<void> _initializeHive() async {
  await Hive.initFlutter();

  // Register Hive adapters
  // TODO: Register adapters after running build_runner
  // Hive.registerAdapter(BuildingHiveAdapter());
  // Hive.registerAdapter(FloorHiveAdapter());
  // Hive.registerAdapter(RoomHiveAdapter());
  // Hive.registerAdapter(RoomTypeAdapter());
  // Hive.registerAdapter(DepartmentHiveAdapter());
  // Hive.registerAdapter(PersonnelHiveAdapter());
  // Hive.registerAdapter(UserFeedbackHiveAdapter());
  // Hive.registerAdapter(FeedbackTypeAdapter());
  // Hive.registerAdapter(FeedbackStatusAdapter());

  // Open boxes (will be used after adapters are registered)
  // await Hive.openBox<BuildingHive>('buildings');
  // await Hive.openBox<FloorHive>('floors');
  // await Hive.openBox<RoomHive>('rooms');
  // await Hive.openBox<DepartmentHive>('departments');
  // await Hive.openBox<PersonnelHive>('personnel');
  // await Hive.openBox<UserFeedbackHive>('feedback');
}

/// Main application widget
class CampusNavApp extends StatelessWidget {
  const CampusNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App info
      title: AppConfig.appName,
      debugShowCheckedModeBanner: AppConfig.enableDebugMode,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Navigation
      initialRoute: Routes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
