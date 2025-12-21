/// CampusNav - App Routes
///
/// Defines app navigation routes and route generation.
/// Includes all screens for Phase 0 foundation.

import 'package:flutter/material.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/location_init/location_init_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/navigation/navigation_screen.dart';
import '../presentation/screens/admin/admin_screen.dart';
import '../presentation/screens/fallback/fallback_screen.dart';
import '../presentation/screens/arrival/arrival_screen.dart';

// =============================================================================
// ROUTE NAMES
// =============================================================================

/// Centralized route name constants
class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String locationInit = '/location_init';
  static const String search = '/search';
  static const String navigation = '/navigation';
  static const String admin = '/admin';
  static const String fallback = '/fallback';
  static const String arrival = '/arrival';
}

// =============================================================================
// ROUTE GENERATOR
// =============================================================================

/// Generates routes for the app
class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _buildRoute(const SplashScreen(), settings);

      case Routes.home:
        return _buildRoute(const HomeScreen(), settings);

      case Routes.locationInit:
        return _buildRoute(const LocationInitScreen(), settings);

      case Routes.search:
        return _buildRoute(const SearchScreen(), settings);

      case Routes.navigation:
        return _buildRoute(const NavigationScreen(), settings);

      case Routes.admin:
        return _buildRoute(const AdminScreen(), settings);

      case Routes.fallback:
        final errorMessage = settings.arguments as String?;
        return _buildRoute(FallbackScreen(errorMessage: errorMessage), settings);

      case Routes.arrival:
        return _buildRoute(const ArrivalScreen(), settings);

      default:
        return _buildRoute(
          Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Route not found: ${settings.name}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      Navigator.of(settings.arguments as BuildContext? ?? 
                          throw Exception('No context')).context,
                      Routes.home,
                    ),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
          settings,
        );
    }
  }

  /// Build a material page route with custom transition
  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
