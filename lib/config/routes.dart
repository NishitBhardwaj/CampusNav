/// CampusNav - App Routes
///
/// Defines app navigation routes and route generation.

import 'package:flutter/material.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/location_init/location_init_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/navigation/navigation_screen.dart';
import '../presentation/screens/fallback/fallback_screen.dart';
import '../presentation/screens/arrival/arrival_screen.dart';

// =============================================================================
// ROUTE NAMES
// =============================================================================

class Routes {
  static const String splash = '/';
  static const String locationInit = '/location_init';
  static const String search = '/search';
  static const String navigation = '/navigation';
  static const String fallback = '/fallback';
  static const String arrival = '/arrival';
}

// =============================================================================
// ROUTE GENERATOR
// =============================================================================

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _buildRoute(const SplashScreen());

      case Routes.locationInit:
        return _buildRoute(const LocationInitScreen());

      case Routes.search:
        return _buildRoute(const SearchScreen());

      case Routes.navigation:
        return _buildRoute(const NavigationScreen());

      case Routes.fallback:
        final errorMessage = settings.arguments as String?;
        return _buildRoute(FallbackScreen(errorMessage: errorMessage));

      case Routes.arrival:
        return _buildRoute(const ArrivalScreen());

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
