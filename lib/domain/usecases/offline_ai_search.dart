/// CampusNav - Offline AI Search Service
///
/// Implements intelligent offline search using:
/// - Fuzzy string matching (Levenshtein distance)
/// - Intent detection from natural language
/// - Synonym expansion
/// - Relevance ranking
///
/// ============================================================================
/// AI DESIGN PHILOSOPHY - WHY NOT REINFORCEMENT LEARNING
/// ============================================================================
///
/// We explicitly chose NOT to use Reinforcement Learning (RL) because:
///
/// 1. DATA INTEGRITY: Campus data (room numbers, personnel locations) must be
///    100% accurate. RL learns from user behavior which could reinforce errors.
///
/// 2. TRANSPARENCY: Our fuzzy matching algorithm is deterministic and auditable.
///    Admins can understand exactly why a result was returned.
///
/// 3. OFFLINE-FIRST: RL typically requires significant computation and training
///    data. Our approach works instantly on any device without training.
///
/// 4. TRUST: Users trust that "Room 204" is actually Room 204, not what an AI
///    "thinks" Room 204 should be based on past searches.
///
/// 5. HUMAN-IN-THE-LOOP: We use controlled feedback where admins verify
///    corrections. This is supervised refinement, not autonomous learning.
///
/// ============================================================================

import 'dart:math';
import '../models/search_index.dart';
import '../../core/utils/helpers.dart';

// =============================================================================
// OFFLINE AI SEARCH SERVICE
// =============================================================================

class OfflineAiSearchService {
  /// Minimum score threshold for results
  static const double _minScoreThreshold = 0.3;

  /// Maximum results to return
  static const int _maxResults = 15;

  /// Search index (loaded from Hive)
  List<SearchIndexEntry> _index = [];

  /// Common synonyms for campus terms
  static const Map<String, List<String>> _synonyms = {
    'restroom': ['bathroom', 'toilet', 'washroom', 'loo', 'wc'],
    'cafeteria': ['canteen', 'food court', 'mess', 'dining'],
    'library': ['reading room', 'study hall'],
    'lab': ['laboratory', 'practical room'],
    'auditorium': ['hall', 'theater', 'theatre', 'audi'],
    'office': ['cabin', 'chamber'],
    'hod': ['head of department', 'department head'],
    'dean': ['dean office', 'deans office'],
    'principal': ['director', 'head'],
    'registrar': ['registration', 'admin office'],
  };

  /// Person title prefixes
  static const List<String> _personTitles = [
    'dr', 'dr.', 'prof', 'prof.', 'professor',
    'mr', 'mr.', 'mrs', 'mrs.', 'ms', 'ms.', 'sir', 'madam',
  ];

  /// Room prefixes
  static const List<String> _roomPrefixes = [
    'room', 'lab', 'hall', 'block', 'building', 'floor',
  ];

  // ===========================================================================
  // PUBLIC METHODS
  // ===========================================================================

  /// Update the search index
  void updateIndex(List<SearchIndexEntry> entries) {
    _index = List.from(entries);
  }

  /// Add entry to index
  void addToIndex(SearchIndexEntry entry) {
    _index.add(entry);
  }

  /// Clear the index
  void clearIndex() {
    _index.clear();
  }

  /// Perform AI-assisted search
  /// Returns ranked results within performance target (<300ms)
  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final startTime = DateTime.now();

    // Parse query and detect intent
    final parsed = _parseQuery(query);

    // Search with intent-aware matching
    final results = _searchWithIntent(parsed);

    // Sort by score
    results.sort(SearchResult.compareByScore);

    // Limit results
    final limitedResults = results.take(_maxResults).toList();

    // Log performance (debug)
    final duration = DateTime.now().difference(startTime);
    assert(duration.inMilliseconds < 300, 'Search exceeded 300ms target');

    return limitedResults;
  }

  /// Get search suggestions for autocomplete
  Future<List<String>> getSuggestions(String partialQuery) async {
    if (partialQuery.length < 2) {
      return [];
    }

    final normalized = partialQuery.toLowerCase().trim();
    final suggestions = <String>{};

    for (final entry in _index) {
      if (entry.primaryText.toLowerCase().startsWith(normalized)) {
        suggestions.add(entry.primaryText);
      }
      for (final keyword in entry.keywords) {
        if (keyword.toLowerCase().startsWith(normalized)) {
          suggestions.add(keyword);
        }
      }
    }

    return suggestions.take(5).toList();
  }

  // ===========================================================================
  // QUERY PARSING
  // ===========================================================================

  /// Parse natural language query and detect intent
  ParsedSearchQuery _parseQuery(String query) {
    final original = query;
    var normalized = query.toLowerCase().trim();

    // Remove common filler words
    normalized = normalized
        .replaceAll(RegExp(r'\b(where|is|the|find|locate|show|me|to|go)\b'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Detect intent
    QueryIntent intent = QueryIntent.generalSearch;
    String? personTitle;
    String? roomPrefix;

    // Check for person titles
    for (final title in _personTitles) {
      if (normalized.contains(title)) {
        intent = QueryIntent.findPerson;
        personTitle = title;
        break;
      }
    }

    // Check for room prefixes
    if (intent == QueryIntent.generalSearch) {
      for (final prefix in _roomPrefixes) {
        if (normalized.contains(prefix)) {
          intent = QueryIntent.findRoom;
          roomPrefix = prefix;
          break;
        }
      }
    }

    // Check for room number pattern (e.g., "204", "A-101")
    if (intent == QueryIntent.generalSearch) {
      if (RegExp(r'\b[a-z]?-?\d{2,4}\b').hasMatch(normalized)) {
        intent = QueryIntent.findRoom;
      }
    }

    // Check for department keywords
    if (intent == QueryIntent.generalSearch) {
      if (normalized.contains('department') ||
          normalized.contains('dept') ||
          normalized.contains('faculty')) {
        intent = QueryIntent.findDepartment;
      }
    }

    // Tokenize
    final tokens = normalized
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 1)
        .toList();

    return ParsedSearchQuery(
      originalQuery: original,
      normalizedQuery: normalized,
      intent: intent,
      queryTokens: tokens,
      personTitle: personTitle,
      roomPrefix: roomPrefix,
    );
  }

  // ===========================================================================
  // SEARCH EXECUTION
  // ===========================================================================

  /// Search with intent-aware matching
  List<SearchResult> _searchWithIntent(ParsedSearchQuery parsed) {
    final results = <SearchResult>[];

    for (final entry in _index) {
      // Apply intent filter
      if (!_matchesIntent(entry, parsed.intent)) {
        continue;
      }

      // Calculate match score
      final result = _scoreEntry(entry, parsed);
      if (result != null && result.score >= _minScoreThreshold) {
        results.add(result);
      }
    }

    return results;
  }

  /// Check if entry matches the detected intent
  bool _matchesIntent(SearchIndexEntry entry, QueryIntent intent) {
    switch (intent) {
      case QueryIntent.findPerson:
        return entry.entityType == SearchEntityType.personnel;
      case QueryIntent.findRoom:
        return entry.entityType == SearchEntityType.room ||
            entry.entityType == SearchEntityType.building;
      case QueryIntent.findDepartment:
        return entry.entityType == SearchEntityType.department;
      case QueryIntent.generalSearch:
        return true;
    }
  }

  /// Score an entry against the parsed query
  SearchResult? _scoreEntry(SearchIndexEntry entry, ParsedSearchQuery parsed) {
    double bestScore = 0;
    String matchType = 'fuzzy';
    String? matchedOn;

    final query = parsed.normalizedQuery;

    // Exact match on primary text
    if (entry.primaryText.toLowerCase() == query) {
      return SearchResult(
        entry: entry,
        score: 1.0,
        matchType: 'exact',
        matchedOn: 'name',
      );
    }

    // Partial match on primary text
    if (entry.primaryText.toLowerCase().contains(query)) {
      bestScore = 0.9;
      matchType = 'partial';
      matchedOn = 'name';
    }

    // Room number exact match
    if (entry.roomNumber != null) {
      if (entry.roomNumber!.toLowerCase() == query ||
          entry.roomNumber!.toLowerCase().replaceAll('-', '') ==
              query.replaceAll('-', '')) {
        return SearchResult(
          entry: entry,
          score: 0.95,
          matchType: 'exact',
          matchedOn: 'room number',
        );
      }
    }

    // Keyword matching
    for (final keyword in entry.keywords) {
      if (keyword.toLowerCase() == query) {
        if (0.85 > bestScore) {
          bestScore = 0.85;
          matchType = 'exact';
          matchedOn = 'keyword';
        }
      } else if (keyword.toLowerCase().contains(query)) {
        if (0.7 > bestScore) {
          bestScore = 0.7;
          matchType = 'partial';
          matchedOn = 'keyword';
        }
      }
    }

    // Synonym matching
    final expandedQuery = _expandSynonyms(query);
    for (final synonym in expandedQuery) {
      if (entry.allSearchableText.contains(synonym)) {
        if (0.65 > bestScore) {
          bestScore = 0.65;
          matchType = 'synonym';
          matchedOn = synonym;
        }
      }
    }

    // Fuzzy matching using Levenshtein distance
    if (bestScore < 0.5) {
      final similarity = stringSimilarity(query, entry.primaryText.toLowerCase());
      if (similarity > bestScore) {
        bestScore = similarity;
        matchType = 'fuzzy';
        matchedOn = 'name';
      }

      // Also check secondary text
      if (entry.secondaryText != null) {
        final secSimilarity =
            stringSimilarity(query, entry.secondaryText!.toLowerCase());
        if (secSimilarity > bestScore) {
          bestScore = secSimilarity;
          matchType = 'fuzzy';
          matchedOn = 'description';
        }
      }
    }

    // Token-based matching for multi-word queries
    if (parsed.queryTokens.length > 1) {
      int matchedTokens = 0;
      for (final token in parsed.queryTokens) {
        if (entry.allSearchableText.contains(token)) {
          matchedTokens++;
        }
      }
      final tokenScore = matchedTokens / parsed.queryTokens.length;
      if (tokenScore > bestScore) {
        bestScore = tokenScore;
        matchType = 'partial';
        matchedOn = 'multiple terms';
      }
    }

    if (bestScore >= _minScoreThreshold) {
      return SearchResult(
        entry: entry,
        score: bestScore,
        matchType: matchType,
        matchedOn: matchedOn,
      );
    }

    return null;
  }

  /// Expand query with synonyms
  List<String> _expandSynonyms(String query) {
    final expanded = <String>[query];

    for (final entry in _synonyms.entries) {
      if (query.contains(entry.key)) {
        expanded.addAll(entry.value);
      }
      for (final synonym in entry.value) {
        if (query.contains(synonym)) {
          expanded.add(entry.key);
          expanded.addAll(entry.value);
        }
      }
    }

    return expanded.toSet().toList();
  }
}
