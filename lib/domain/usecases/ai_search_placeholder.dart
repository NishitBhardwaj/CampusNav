/// CampusNav - AI Search Placeholder
///
/// Placeholder for AI-assisted search functionality.
/// Designed for offline operation without hallucination.
///
/// Core Principles:
/// 1. OFFLINE-FIRST: No external API calls
/// 2. NO HALLUCINATION: Only return verified, admin-added data
/// 3. FUZZY MATCHING: Use Levenshtein distance for typo tolerance
/// 4. TRANSPARENT: Always show source of information
///
/// Features (planned):
/// - Fuzzy text search across all entity types
/// - Natural language query parsing
/// - Search suggestions based on history
/// - Category-based filtering  
/// - Synonym matching for common terms

// =============================================================================
// AI SEARCH SERVICE INTERFACE
// =============================================================================

/// Abstract interface for AI-assisted search
abstract class AiSearchService {
  /// Search across all entities
  /// Returns only admin-verified data
  Future<List<SearchResult>> search(String query);

  /// Get search suggestions
  Future<List<String>> getSuggestions(String partialQuery);

  /// Parse natural language query
  /// Example: "Where is Dr. Kumar's office?"
  Future<ParsedQuery> parseNaturalQuery(String naturalQuery);
}

/// Represents a parsed natural language query
class ParsedQuery {
  final String? personName;
  final String? roomName;
  final String? buildingName;
  final String? departmentName;
  final QueryIntent intent;

  ParsedQuery({
    this.personName,
    this.roomName,
    this.buildingName,
    this.departmentName,
    required this.intent,
  });
}

/// Intent of the search query
enum QueryIntent {
  findLocation,
  findPerson,
  navigate,
  generalSearch,
}

/// Represents a search result
class SearchResult {
  final String entityType;
  final String entityId;
  final String title;
  final String? subtitle;
  final double relevanceScore;
  final String? buildingId;
  final String? floorId;

  SearchResult({
    required this.entityType,
    required this.entityId,
    required this.title,
    this.subtitle,
    required this.relevanceScore,
    this.buildingId,
    this.floorId,
  });
}

// =============================================================================
// PLACEHOLDER IMPLEMENTATION
// =============================================================================

/// Placeholder implementation using existing fuzzy search
class PlaceholderAiSearchService implements AiSearchService {
  @override
  Future<List<SearchResult>> search(String query) async {
    // TODO: Implement with Hive data
    return [];
  }

  @override
  Future<List<String>> getSuggestions(String partialQuery) async {
    // TODO: Implement search suggestions
    return [];
  }

  @override
  Future<ParsedQuery> parseNaturalQuery(String naturalQuery) async {
    // Simple keyword-based parsing (no ML required)
    final lower = naturalQuery.toLowerCase();

    QueryIntent intent = QueryIntent.generalSearch;
    String? personName;

    if (lower.contains('where is') || lower.contains('find')) {
      intent = QueryIntent.findLocation;
    }
    if (lower.contains('navigate') || lower.contains('go to')) {
      intent = QueryIntent.navigate;
    }
    if (lower.contains('dr.') || lower.contains('prof.') || lower.contains('mr.') || lower.contains('ms.')) {
      intent = QueryIntent.findPerson;
      // Extract name after title
    }

    return ParsedQuery(
      personName: personName,
      intent: intent,
    );
  }
}
