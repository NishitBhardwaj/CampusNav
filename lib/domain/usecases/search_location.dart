/// CampusNav - Search Location Use Case
///
/// Business logic for searching locations with fuzzy matching.

import '../entities/location.dart';
import '../../core/utils/helpers.dart';
import '../../core/constants/constants.dart';

// =============================================================================
// SEARCH RESULT
// =============================================================================

class SearchResult {
  final Location location;
  final double score;
  final String matchType; // 'exact', 'partial', 'fuzzy'

  const SearchResult({
    required this.location,
    required this.score,
    required this.matchType,
  });
}

// =============================================================================
// SEARCH LOCATION USE CASE
// =============================================================================

class SearchLocationUseCase {
  /// Execute search with fuzzy matching
  Future<List<SearchResult>> execute({
    required String query,
    required List<Location> locations,
    int maxResults = kMaxSearchResults,
  }) async {
    if (query.isEmpty) {
      return [];
    }

    final normalizedQuery = normalizeSearchQuery(query);
    final results = <SearchResult>[];

    for (final location in locations) {
      final result = _matchLocation(normalizedQuery, location);
      if (result != null) {
        results.add(result);
      }
    }

    // Sort by score (higher is better)
    results.sort((a, b) => b.score.compareTo(a.score));

    // Limit results
    return results.take(maxResults).toList();
  }

  SearchResult? _matchLocation(String query, Location location) {
    double bestScore = 0;
    String matchType = 'fuzzy';

    // Check name
    final nameLower = location.name.toLowerCase();
    if (nameLower == query) {
      return SearchResult(
        location: location,
        score: 1.0,
        matchType: 'exact',
      );
    }

    if (nameLower.contains(query)) {
      bestScore = 0.9;
      matchType = 'partial';
    }

    // Check tags
    if (location.tags != null) {
      for (final tag in location.tags!) {
        if (tag.toLowerCase() == query) {
          bestScore = 0.95;
          matchType = 'exact';
          break;
        }
        if (tag.toLowerCase().contains(query)) {
          if (0.8 > bestScore) {
            bestScore = 0.8;
            matchType = 'partial';
          }
        }
      }
    }

    // Check description
    if (location.description != null) {
      if (location.description!.toLowerCase().contains(query)) {
        if (0.6 > bestScore) {
          bestScore = 0.6;
          matchType = 'partial';
        }
      }
    }

    // Fuzzy match on name
    if (bestScore < kFuzzySearchThreshold) {
      final similarity = stringSimilarity(query, nameLower);
      if (similarity > bestScore && similarity >= kFuzzySearchThreshold) {
        bestScore = similarity;
        matchType = 'fuzzy';
      }
    }

    if (bestScore >= kFuzzySearchThreshold) {
      return SearchResult(
        location: location,
        score: bestScore,
        matchType: matchType,
      );
    }

    return null;
  }
}
