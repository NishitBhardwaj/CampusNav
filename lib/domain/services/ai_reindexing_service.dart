/// CampusNav - AI Re-indexing Service
///
/// PHASE 5: Updates AI search index when admin modifies data.
///
/// TRIGGER CONDITIONS:
/// - Admin updates room/personnel data
/// - Admin approves feedback
/// - Campus map changes
///
/// PERFORMANCE TARGET: <300ms
/// MUST STAY OFFLINE

import 'dart:async';
import 'package:hive/hive.dart';
import '../entities/room.dart';
import '../entities/personnel.dart';
import '../entities/data_version.dart';
import '../../data/models/search_index_entry.dart';
import '../ai/offline_ai_search_service.dart';

// =============================================================================
// AI RE-INDEXING SERVICE
// =============================================================================

class AIReindexingService {
  final OfflineAiSearchService _searchService;
  
  AIReindexingService({
    required OfflineAiSearchService searchService,
  }) : _searchService = searchService;
  
  // ===========================================================================
  // FULL RE-INDEX
  // ===========================================================================
  
  /// Rebuild entire search index from scratch
  /// 
  /// Call this after major data changes
  Future<void> rebuildFullIndex() async {
    final startTime = DateTime.now();
    
    print('🔄 Starting full AI index rebuild...');
    
    // Clear existing index
    _searchService.clearIndex();
    
    // Re-index rooms
    await _reindexRooms();
    
    // Re-index personnel
    await _reindexPersonnel();
    
    final duration = DateTime.now().difference(startTime);
    print('✅ Full index rebuild complete in ${duration.inMilliseconds}ms');
    
    // Update version
    await _updateIndexVersion('full_rebuild');
  }
  
  // ===========================================================================
  // INCREMENTAL RE-INDEX
  // ===========================================================================
  
  /// Update index for a specific room
  Future<void> reindexRoom(Room room) async {
    final entry = SearchIndexEntry(
      id: room.id,
      type: SearchResultType.room,
      primaryText: room.roomName,
      secondaryText: 'Room ${room.roomNumber}',
      metadata: {
        'roomNumber': room.roomNumber,
        'floor': room.floorId,
        'type': room.type.toString(),
        'description': room.description ?? '',
      },
      searchableText: _buildRoomSearchText(room),
      tags: _buildRoomTags(room),
    );
    
    _searchService.addToIndex(entry);
    
    await _updateIndexVersion('room_updated: ${room.roomNumber}');
  }
  
  /// Update index for a specific person
  Future<void> reindexPerson(Personnel person) async {
    final entry = SearchIndexEntry(
      id: person.id,
      type: SearchResultType.person,
      primaryText: person.name,
      secondaryText: person.title,
      metadata: {
        'title': person.title,
        'department': person.department,
        'roomId': person.roomId ?? '',
        'email': person.email ?? '',
      },
      searchableText: _buildPersonSearchText(person),
      tags: _buildPersonTags(person),
    );
    
    _searchService.addToIndex(entry);
    
    await _updateIndexVersion('person_updated: ${person.name}');
  }
  
  // ===========================================================================
  // BATCH RE-INDEX
  // ===========================================================================
  
  /// Re-index all rooms from Hive
  Future<void> _reindexRooms() async {
    final roomsBox = await Hive.openBox<Room>('rooms');
    
    for (final room in roomsBox.values) {
      await reindexRoom(room);
    }
    
    print('📍 Re-indexed ${roomsBox.length} rooms');
  }
  
  /// Re-index all personnel from Hive
  Future<void> _reindexPersonnel() async {
    final personnelBox = await Hive.openBox<Personnel>('personnel');
    
    for (final person in personnelBox.values) {
      await reindexPerson(person);
    }
    
    print('👥 Re-indexed ${personnelBox.length} personnel');
  }
  
  // ===========================================================================
  // SEARCH TEXT BUILDERS
  // ===========================================================================
  
  /// Build searchable text for room
  String _buildRoomSearchText(Room room) {
    return [
      room.roomName,
      room.roomNumber,
      room.type.toString().split('.').last,
      room.description ?? '',
    ].join(' ').toLowerCase();
  }
  
  /// Build searchable text for person
  String _buildPersonSearchText(Personnel person) {
    return [
      person.name,
      person.title,
      person.department,
    ].join(' ').toLowerCase();
  }
  
  // ===========================================================================
  // TAG BUILDERS
  // ===========================================================================
  
  /// Build tags for room
  List<String> _buildRoomTags(Room room) {
    return [
      room.type.toString().split('.').last.toLowerCase(),
      room.floorId,
      'room',
    ];
  }
  
  /// Build tags for person
  List<String> _buildPersonTags(Personnel person) {
    return [
      person.department.toLowerCase(),
      person.title.toLowerCase(),
      'person',
      'staff',
    ];
  }
  
  // ===========================================================================
  // VERSION TRACKING
  // ===========================================================================
  
  /// Update search index version
  Future<void> _updateIndexVersion(String changeDescription) async {
    final versionBox = await Hive.openBox<DataVersion>('data_versions');
    
    final existingVersion = versionBox.get('search_index');
    final newVersionNumber = (existingVersion?.versionNumber ?? 0) + 1;
    
    final newVersion = DataVersion(
      id: 'search_index',
      versionNumber: newVersionNumber,
      datasetName: 'search_index',
      updatedBy: 'AI Re-indexing Service',
      changeDescription: changeDescription,
      recordCount: _searchService.getIndexSize(),
    );
    
    await versionBox.put('search_index', newVersion);
  }
  
  // ===========================================================================
  // STATISTICS
  // ===========================================================================
  
  /// Get index statistics
  Map<String, dynamic> getIndexStats() {
    return {
      'totalEntries': _searchService.getIndexSize(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
}

// Extension to get index size (add to OfflineAiSearchService if needed)
extension on OfflineAiSearchService {
  int getIndexSize() {
    // TODO: Add this method to OfflineAiSearchService
    return 0; // Placeholder
  }
}
