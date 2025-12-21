/// CampusNav - App Providers
///
/// Central provider definitions for the app.
/// Groups all Riverpod providers for easy access.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

// Re-export auth providers
export 'auth_provider.dart';

// =============================================================================
// APP STATE PROVIDERS
// =============================================================================

/// Provider for app initialization status
final appInitializedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isInitialized;
});

// =============================================================================
// NAVIGATION PROVIDERS (Placeholders)
// =============================================================================

/// Provider for current navigation state (placeholder)
final isNavigatingProvider = StateProvider<bool>((ref) => false);

/// Provider for current floor ID (placeholder)
final currentFloorIdProvider = StateProvider<String?>((ref) => null);

/// Provider for current building ID (placeholder)
final currentBuildingIdProvider = StateProvider<String?>((ref) => null);

// =============================================================================
// SEARCH PROVIDERS (Placeholders)
// =============================================================================

/// Provider for search query (placeholder)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for search filter type (placeholder)
enum SearchFilterType { all, rooms, people, departments }

final searchFilterProvider = StateProvider<SearchFilterType>(
  (ref) => SearchFilterType.all,
);

// =============================================================================
// FEEDBACK PROVIDERS
// =============================================================================

/// Provider for pending feedback count
final pendingFeedbackCountProvider = StateProvider<int>((ref) => 0);
