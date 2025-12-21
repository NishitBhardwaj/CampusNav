/// CampusNav - Search Index Model
///
/// Unified search index combining all searchable entities.
/// Optimized for fast offline fuzzy search with intent detection.
///
/// AI DESIGN NOTE:
/// This index is built ONLY from admin-verified data.
/// We do NOT use machine learning or reinforcement learning.
/// Search ranking uses deterministic algorithms (Levenshtein distance,
/// keyword matching) that are transparent and auditable.

import 'package:hive/hive.dart';

part 'search_index.g.dart';

// =============================================================================
// SEARCH ENTITY TYPE
// =============================================================================

/// Type of entity in the search index
@HiveType(typeId: 20)
enum SearchEntityType {
  @HiveField(0)
  room,

  @HiveField(1)
  personnel,

  @HiveField(2)
  department,

  @HiveField(3)
  building,
}

// =============================================================================
// SEARCH INDEX ENTRY
// =============================================================================

/// A single entry in the search index
/// Denormalized for fast search without joins
@HiveType(typeId: 6)
class SearchIndexEntry extends HiveObject {
  /// Unique identifier
  @HiveField(0)
  final String id;

  /// Type of entity
  @HiveField(1)
  final SearchEntityType entityType;

  /// Original entity ID (for navigation)
  @HiveField(2)
  final String entityId;

  /// Primary searchable text (name, title)
  @HiveField(3)
  final String primaryText;

  /// Secondary searchable text (description, designation)
  @HiveField(4)
  final String? secondaryText;

  /// Search keywords/tags for matching
  @HiveField(5)
  final List<String> keywords;

  /// Synonyms for fuzzy matching
  /// e.g., "restroom" -> ["bathroom", "toilet", "washroom"]
  @HiveField(6)
  final List<String>? synonyms;

  /// Location info for display
  @HiveField(7)
  final String? buildingName;

  @HiveField(8)
  final String? floorName;

  @HiveField(9)
  final String? roomNumber;

  /// For navigation
  @HiveField(10)
  final String? buildingId;

  @HiveField(11)
  final String? floorId;

  @HiveField(12)
  final double? x;

  @HiveField(13)
  final double? y;

  /// Data freshness
  @HiveField(14)
  final DateTime lastUpdated;

  /// Version for cache invalidation
  @HiveField(15)
  final int dataVersion;

  SearchIndexEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.primaryText,
    this.secondaryText,
    required this.keywords,
    this.synonyms,
    this.buildingName,
    this.floorName,
    this.roomNumber,
    this.buildingId,
    this.floorId,
    this.x,
    this.y,
    DateTime? lastUpdated,
    this.dataVersion = 1,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Get display title
  String get displayTitle {
    if (roomNumber != null) {
      return '$roomNumber - $primaryText';
    }
    return primaryText;
  }

  /// Get display subtitle
  String get displaySubtitle {
    final parts = <String>[];
    if (buildingName != null) parts.add(buildingName!);
    if (floorName != null) parts.add(floorName!);
    if (secondaryText != null) parts.add(secondaryText!);
    return parts.join(' • ');
  }

  /// Get entity type display name
  String get entityTypeLabel {
    switch (entityType) {
      case SearchEntityType.room:
        return 'Room';
      case SearchEntityType.personnel:
        return 'Person';
      case SearchEntityType.department:
        return 'Department';
      case SearchEntityType.building:
        return 'Building';
    }
  }

  /// Get all searchable text combined
  String get allSearchableText {
    final parts = [
      primaryText.toLowerCase(),
      if (secondaryText != null) secondaryText!.toLowerCase(),
      ...keywords.map((k) => k.toLowerCase()),
      if (synonyms != null) ...synonyms!.map((s) => s.toLowerCase()),
      if (roomNumber != null) roomNumber!.toLowerCase(),
    ];
    return parts.join(' ');
  }
}

// =============================================================================
// SEARCH RESULT
// =============================================================================

/// A search result with relevance score
class SearchResult {
  final SearchIndexEntry entry;
  final double score;
  final String matchType; // 'exact', 'partial', 'fuzzy', 'synonym'
  final String? matchedOn; // What field matched

  const SearchResult({
    required this.entry,
    required this.score,
    required this.matchType,
    this.matchedOn,
  });

  /// Sort by score descending
  static int compareByScore(SearchResult a, SearchResult b) {
    return b.score.compareTo(a.score);
  }
}

// =============================================================================
// DETECTED INTENT
// =============================================================================

/// Intent detected from natural language query
enum QueryIntent {
  /// Looking for a specific person
  findPerson,

  /// Looking for a room/location
  findRoom,

  /// Looking for a department
  findDepartment,

  /// General search
  generalSearch,
}

/// Parsed query with detected intent
class ParsedSearchQuery {
  final String originalQuery;
  final String normalizedQuery;
  final QueryIntent intent;
  final List<String> queryTokens;
  final String? personTitle; // Dr., Prof., Mr., Ms.
  final String? roomPrefix; // Room, Lab, Hall

  ParsedSearchQuery({
    required this.originalQuery,
    required this.normalizedQuery,
    required this.intent,
    required this.queryTokens,
    this.personTitle,
    this.roomPrefix,
  });
}
