/// CampusNav - Search Provider (Riverpod)
///
/// Provides state management for the AI-assisted search feature.
/// Combines offline AI search with Riverpod for reactive UI updates.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/search_index.dart';
import '../../domain/usecases/offline_ai_search.dart';

// =============================================================================
// SEARCH STATE
// =============================================================================

class SearchState {
  final String query;
  final List<SearchResult> results;
  final List<String> suggestions;
  final bool isSearching;
  final String? error;
  final QueryIntent? detectedIntent;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.suggestions = const [],
    this.isSearching = false,
    this.error,
    this.detectedIntent,
  });

  SearchState copyWith({
    String? query,
    List<SearchResult>? results,
    List<String>? suggestions,
    bool? isSearching,
    String? error,
    QueryIntent? detectedIntent,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      suggestions: suggestions ?? this.suggestions,
      isSearching: isSearching ?? this.isSearching,
      error: error,
      detectedIntent: detectedIntent ?? this.detectedIntent,
    );
  }

  /// Check if there are results
  bool get hasResults => results.isNotEmpty;

  /// Check if query is empty
  bool get isEmpty => query.isEmpty;
}

// =============================================================================
// SEARCH NOTIFIER
// =============================================================================

class SearchNotifier extends StateNotifier<SearchState> {
  final OfflineAiSearchService _searchService;

  SearchNotifier(this._searchService) : super(const SearchState());

  /// Perform search
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(
      query: query,
      isSearching: true,
      error: null,
    );

    try {
      final results = await _searchService.search(query);
      
      // Detect intent from first result if available
      QueryIntent? intent;
      if (results.isNotEmpty) {
        switch (results.first.entry.entityType) {
          case SearchEntityType.personnel:
            intent = QueryIntent.findPerson;
            break;
          case SearchEntityType.room:
            intent = QueryIntent.findRoom;
            break;
          case SearchEntityType.department:
            intent = QueryIntent.findDepartment;
            break;
          default:
            intent = QueryIntent.generalSearch;
        }
      }

      state = state.copyWith(
        results: results,
        isSearching: false,
        detectedIntent: intent,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: 'Search failed: $e',
      );
    }
  }

  /// Get suggestions for autocomplete
  Future<void> getSuggestions(String partialQuery) async {
    if (partialQuery.length < 2) {
      state = state.copyWith(suggestions: []);
      return;
    }

    final suggestions = await _searchService.getSuggestions(partialQuery);
    state = state.copyWith(suggestions: suggestions);
  }

  /// Clear search
  void clear() {
    state = const SearchState();
  }

  /// Select a suggestion
  void selectSuggestion(String suggestion) {
    search(suggestion);
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Provider for the search service
final searchServiceProvider = Provider<OfflineAiSearchService>((ref) {
  return OfflineAiSearchService();
});

/// Provider for search state
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final service = ref.watch(searchServiceProvider);
  return SearchNotifier(service);
});

/// Provider for current search results
final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  return ref.watch(searchProvider).results;
});

/// Provider for search loading state
final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(searchProvider).isSearching;
});

/// Provider for selected result (for detail view)
final selectedResultProvider = StateProvider<SearchResult?>((ref) => null);
