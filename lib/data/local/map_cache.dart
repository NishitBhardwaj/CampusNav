/// CampusNav - Map Cache
///
/// Handles caching of map images and floor plan data for offline use.

import 'dart:typed_data';

// =============================================================================
// MAP CACHE
// =============================================================================

class MapCache {
  final Map<String, Uint8List> _imageCache = {};
  final Map<String, MapMetadata> _metadataCache = {};

  /// Cache a map image
  Future<void> cacheMapImage(String floorId, Uint8List imageData) async {
    _imageCache[floorId] = imageData;
  }

  /// Get cached map image
  Future<Uint8List?> getMapImage(String floorId) async {
    return _imageCache[floorId];
  }

  /// Check if map is cached
  bool isMapCached(String floorId) {
    return _imageCache.containsKey(floorId);
  }

  /// Cache map metadata
  Future<void> cacheMetadata(String floorId, MapMetadata metadata) async {
    _metadataCache[floorId] = metadata;
  }

  /// Get cached metadata
  Future<MapMetadata?> getMetadata(String floorId) async {
    return _metadataCache[floorId];
  }

  /// Clear specific floor cache
  Future<void> clearFloorCache(String floorId) async {
    _imageCache.remove(floorId);
    _metadataCache.remove(floorId);
  }

  /// Clear all cache
  Future<void> clearAll() async {
    _imageCache.clear();
    _metadataCache.clear();
  }

  /// Get total cache size in bytes
  int get totalCacheSize {
    return _imageCache.values.fold(0, (sum, data) => sum + data.length);
  }
}

// =============================================================================
// MAP METADATA
// =============================================================================

class MapMetadata {
  final String floorId;
  final double width;
  final double height;
  final double pixelsPerMeter;
  final DateTime cachedAt;

  MapMetadata({
    required this.floorId,
    required this.width,
    required this.height,
    required this.pixelsPerMeter,
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now();
}
