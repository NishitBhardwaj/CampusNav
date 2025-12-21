/// CampusNav - Location Repository Implementation
///
/// Implementation of location data repository.
/// Handles data operations for locations with local-first approach.

import '../models/location_model.dart';
import '../local/local_database.dart';
import '../../domain/entities/location.dart';

// =============================================================================
// LOCATION REPOSITORY
// =============================================================================

class LocationRepositoryImpl {
  final LocalDatabase _localDatabase;

  LocationRepositoryImpl(this._localDatabase);

  /// Get location by ID
  Future<Location?> getLocationById(String id) async {
    final model = await _localDatabase.getLocation(id);
    if (model == null) return null;
    return _mapToEntity(model);
  }

  /// Get all locations in a building
  Future<List<Location>> getLocationsByBuilding(String buildingId) async {
    final models = await _localDatabase.getLocationsByBuilding(buildingId);
    return models.map(_mapToEntity).toList();
  }

  /// Get all locations on a floor
  Future<List<Location>> getLocationsByFloor(
      String buildingId, String floorId) async {
    final models =
        await _localDatabase.getLocationsByFloor(buildingId, floorId);
    return models.map(_mapToEntity).toList();
  }

  /// Search locations by query
  Future<List<Location>> searchLocations(String query) async {
    final models = await _localDatabase.searchLocations(query);
    return models.map(_mapToEntity).toList();
  }

  /// Save a location
  Future<void> saveLocation(Location location) async {
    final model = _mapToModel(location);
    await _localDatabase.saveLocation(model);
  }

  // ===========================================================================
  // MAPPING HELPERS
  // ===========================================================================

  Location _mapToEntity(LocationModel model) {
    return Location(
      id: model.id,
      name: model.name,
      buildingId: model.buildingId,
      floorId: model.floorId,
      x: model.x,
      y: model.y,
      description: model.description,
      category: model.category,
      tags: model.tags,
      isAccessible: model.isAccessible,
    );
  }

  LocationModel _mapToModel(Location entity) {
    return LocationModel(
      id: entity.id,
      name: entity.name,
      buildingId: entity.buildingId,
      floorId: entity.floorId,
      x: entity.x,
      y: entity.y,
      description: entity.description,
      category: entity.category,
      tags: entity.tags,
      isAccessible: entity.isAccessible,
    );
  }
}
