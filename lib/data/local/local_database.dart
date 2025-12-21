/// CampusNav - Local Database
///
/// Handles local data storage and retrieval.
/// Uses in-memory storage with optional persistent storage support.

import '../models/location_model.dart';
import '../models/node_model.dart';
import '../models/building_model.dart';
import '../models/person_model.dart';

// =============================================================================
// LOCAL DATABASE
// =============================================================================

class LocalDatabase {
  // In-memory storage for demo purposes
  final Map<String, BuildingModel> _buildings = {};
  final Map<String, LocationModel> _locations = {};
  final Map<String, NodeModel> _nodes = {};
  final Map<String, PersonModel> _people = {};

  bool _isInitialized = false;

  /// Initialize the database
  Future<void> initialize() async {
    if (_isInitialized) return;
    // TODO: Load from persistent storage
    _isInitialized = true;
  }

  // ===========================================================================
  // BUILDINGS
  // ===========================================================================

  Future<void> saveBuilding(BuildingModel building) async {
    _buildings[building.id] = building;
  }

  Future<BuildingModel?> getBuilding(String id) async {
    return _buildings[id];
  }

  Future<List<BuildingModel>> getAllBuildings() async {
    return _buildings.values.toList();
  }

  // ===========================================================================
  // LOCATIONS
  // ===========================================================================

  Future<void> saveLocation(LocationModel location) async {
    _locations[location.id] = location;
  }

  Future<LocationModel?> getLocation(String id) async {
    return _locations[id];
  }

  Future<List<LocationModel>> getLocationsByBuilding(String buildingId) async {
    return _locations.values
        .where((loc) => loc.buildingId == buildingId)
        .toList();
  }

  Future<List<LocationModel>> getLocationsByFloor(
      String buildingId, String floorId) async {
    return _locations.values
        .where((loc) => loc.buildingId == buildingId && loc.floorId == floorId)
        .toList();
  }

  Future<List<LocationModel>> searchLocations(String query) async {
    final lowerQuery = query.toLowerCase();
    return _locations.values.where((loc) {
      return loc.name.toLowerCase().contains(lowerQuery) ||
          (loc.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (loc.tags?.any((t) => t.toLowerCase().contains(lowerQuery)) ?? false);
    }).toList();
  }

  // ===========================================================================
  // NODES
  // ===========================================================================

  Future<void> saveNode(NodeModel node) async {
    _nodes[node.id] = node;
  }

  Future<NodeModel?> getNode(String id) async {
    return _nodes[id];
  }

  Future<List<NodeModel>> getNodesByFloor(String floorId) async {
    return _nodes.values.where((node) => node.floorId == floorId).toList();
  }

  // ===========================================================================
  // PEOPLE
  // ===========================================================================

  Future<void> savePerson(PersonModel person) async {
    _people[person.id] = person;
  }

  Future<PersonModel?> getPerson(String id) async {
    return _people[id];
  }

  Future<List<PersonModel>> searchPeople(String query) async {
    final lowerQuery = query.toLowerCase();
    return _people.values.where((person) {
      return person.name.toLowerCase().contains(lowerQuery) ||
          (person.department?.toLowerCase().contains(lowerQuery) ?? false) ||
          (person.designation?.toLowerCase().contains(lowerQuery) ?? false) ||
          (person.tags?.any((t) => t.toLowerCase().contains(lowerQuery)) ??
              false);
    }).toList();
  }

  Future<List<PersonModel>> getAllPeople() async {
    return _people.values.toList();
  }

  // ===========================================================================
  // BULK OPERATIONS
  // ===========================================================================

  Future<void> loadMockData({
    List<BuildingModel>? buildings,
    List<LocationModel>? locations,
    List<NodeModel>? nodes,
    List<PersonModel>? people,
  }) async {
    if (buildings != null) {
      for (var b in buildings) {
        _buildings[b.id] = b;
      }
    }
    if (locations != null) {
      for (var l in locations) {
        _locations[l.id] = l;
      }
    }
    if (nodes != null) {
      for (var n in nodes) {
        _nodes[n.id] = n;
      }
    }
    if (people != null) {
      for (var p in people) {
        _people[p.id] = p;
      }
    }
  }

  /// Clear all data
  Future<void> clearAll() async {
    _buildings.clear();
    _locations.clear();
    _nodes.clear();
    _people.clear();
  }
}
