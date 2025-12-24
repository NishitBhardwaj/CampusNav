/// CampusNav - User Profile Entity
///
/// PHASE 7: User profile for offline-first authentication.

import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 13)
class UserProfile extends HiveObject {
  @HiveField(0)
  String uid;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String email;
  
  @HiveField(3)
  String? photoUrl;
  
  @HiveField(4)
  String language;
  
  @HiveField(5)
  List<String> favorites;
  
  @HiveField(6)
  List<SearchHistoryEntry> searchHistory;
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  DateTime lastSyncedAt;
  
  @HiveField(9)
  bool isDarkMode;
  
  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.language = 'en',
    List<String>? favorites,
    List<SearchHistoryEntry>? searchHistory,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
    this.isDarkMode = false,
  })  : favorites = favorites ?? [],
        searchHistory = searchHistory ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastSyncedAt = lastSyncedAt ?? DateTime.now();
  
  /// Add to favorites
  void addFavorite(String nodeId) {
    if (!favorites.contains(nodeId)) {
      favorites.add(nodeId);
      save();
    }
  }
  
  /// Remove from favorites
  void removeFavorite(String nodeId) {
    favorites.remove(nodeId);
    save();
  }
  
  /// Check if favorited
  bool isFavorite(String nodeId) {
    return favorites.contains(nodeId);
  }
  
  /// Add search to history
  void addSearchHistory({
    required String query,
    required String resultNodeId,
    String? resultName,
  }) {
    // Add to beginning
    searchHistory.insert(
      0,
      SearchHistoryEntry(
        query: query,
        resultNodeId: resultNodeId,
        resultName: resultName,
        timestamp: DateTime.now(),
      ),
    );
    
    // Limit to 50 entries
    if (searchHistory.length > 50) {
      searchHistory.removeRange(50, searchHistory.length);
    }
    
    save();
  }
  
  /// Clear search history
  void clearSearchHistory() {
    searchHistory.clear();
    save();
  }
  
  /// Update last synced time
  void updateLastSynced() {
    lastSyncedAt = DateTime.now();
    save();
  }
  
  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'language': language,
      'favorites': favorites,
      'searchHistory': searchHistory.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastSyncedAt': lastSyncedAt.toIso8601String(),
      'isDarkMode': isDarkMode,
    };
  }
  
  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      language: json['language'] ?? 'en',
      favorites: List<String>.from(json['favorites'] ?? []),
      searchHistory: (json['searchHistory'] as List?)
          ?.map((e) => SearchHistoryEntry.fromJson(e))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      lastSyncedAt: DateTime.parse(json['lastSyncedAt']),
      isDarkMode: json['isDarkMode'] ?? false,
    );
  }
  
  @override
  String toString() => 'UserProfile($name, $email)';
}

// =============================================================================
// SEARCH HISTORY ENTRY
// =============================================================================

@HiveType(typeId: 14)
class SearchHistoryEntry {
  @HiveField(0)
  String query;
  
  @HiveField(1)
  String resultNodeId;
  
  @HiveField(2)
  String? resultName;
  
  @HiveField(3)
  DateTime timestamp;
  
  SearchHistoryEntry({
    required this.query,
    required this.resultNodeId,
    this.resultName,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'resultNodeId': resultNodeId,
      'resultName': resultName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory SearchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SearchHistoryEntry(
      query: json['query'],
      resultNodeId: json['resultNodeId'],
      resultName: json['resultName'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  
  @override
  String toString() => 'SearchHistoryEntry($query → $resultName)';
}
