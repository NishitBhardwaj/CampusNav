/// CampusNav - App Router
///
/// PHASE 4: go_router configuration for app navigation.
///
/// ROUTES:
/// - / (splash)
/// - /home
/// - /search
/// - /navigation
/// - /arrival
/// - /admin

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/navigation/navigation_screen.dart';
import '../screens/arrival/arrival_screen.dart';
import '../screens/admin/admin_panel_screen.dart';

// =============================================================================
// ROUTE NAMES
// =============================================================================

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String search = '/search';
  static const String navigation = '/navigation';
  static const String arrival = '/arrival';
  static const String admin = '/admin';
}

// =============================================================================
// ROUTER CONFIGURATION
// =============================================================================

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.navigation,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return NavigationScreen(
          destinationId: extra?['destinationId'] as String?,
          destinationName: extra?['destinationName'] as String?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.arrival,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ArrivalScreen(
          destinationName: extra?['destinationName'] as String? ?? 'Destination',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.admin,
      builder: (context, state) => const AdminPanelScreen(),
    ),
  ],
);
