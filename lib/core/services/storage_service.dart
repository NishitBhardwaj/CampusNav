/// CampusNav - Storage Service
///
/// Service for local data persistence.
/// Handles caching of map data, user preferences, and offline data.

// =============================================================================
// STORAGE SERVICE INTERFACE
// =============================================================================

/// Abstract interface for local storage operations
abstract class StorageService {
  /// Initialize the storage service
  Future<void> initialize();

  /// Save a string value
  Future<void> saveString(String key, String value);

  /// Get a string value
  Future<String?> getString(String key);

  /// Save a map/JSON object
  Future<void> saveJson(String key, Map<String, dynamic> json);

  /// Get a map/JSON object
  Future<Map<String, dynamic>?> getJson(String key);

  /// Delete a value
  Future<void> delete(String key);

  /// Clear all stored data
  Future<void> clearAll();

  /// Check if a key exists
  Future<bool> containsKey(String key);
}

// =============================================================================
// STORAGE KEYS
// =============================================================================

/// Constants for storage keys used throughout the app
class StorageKeys {
  static const String lastLocation = 'last_location';
  static const String cachedMaps = 'cached_maps';
  static const String userPreferences = 'user_preferences';
  static const String recentSearches = 'recent_searches';
  static const String favoriteLocations = 'favorite_locations';
  static const String cachedPeopleDirectory = 'cached_people_directory';
}

// =============================================================================
// IN-MEMORY STORAGE (for testing/demo)
// =============================================================================

/// In-memory implementation for testing
class InMemoryStorageService implements StorageService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> initialize() async {
    // No initialization needed for in-memory storage
  }

  @override
  Future<void> saveString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _storage[key] as String?;
  }

  @override
  Future<void> saveJson(String key, Map<String, dynamic> json) async {
    _storage[key] = json;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    return _storage[key] as Map<String, dynamic>?;
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clearAll() async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }
}
