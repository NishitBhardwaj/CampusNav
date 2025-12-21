/// CampusNav - Navigation Repository Implementation
///
/// Implementation of navigation data repository.
/// Handles pathfinding graph data and navigation operations.

import '../models/node_model.dart';
import '../local/local_database.dart';
import '../../domain/entities/node.dart';

// =============================================================================
// NAVIGATION REPOSITORY
// =============================================================================

class NavigationRepositoryImpl {
  final LocalDatabase _localDatabase;

  NavigationRepositoryImpl(this._localDatabase);

  /// Get node by ID
  Future<Node?> getNodeById(String id) async {
    final model = await _localDatabase.getNode(id);
    if (model == null) return null;
    return _mapToEntity(model);
  }

  /// Get all nodes on a floor
  Future<List<Node>> getNodesByFloor(String floorId) async {
    final models = await _localDatabase.getNodesByFloor(floorId);
    return models.map(_mapToEntity).toList();
  }

  /// Get navigation graph for a floor
  Future<Map<String, Node>> getFloorGraph(String floorId) async {
    final nodes = await getNodesByFloor(floorId);
    return {for (var node in nodes) node.id: node};
  }

  /// Save a node
  Future<void> saveNode(Node node) async {
    final model = _mapToModel(node);
    await _localDatabase.saveNode(model);
  }

  // ===========================================================================
  // MAPPING HELPERS
  // ===========================================================================

  Node _mapToEntity(NodeModel model) {
    return Node(
      id: model.id,
      x: model.x,
      y: model.y,
      floorId: model.floorId,
      locationId: model.locationId,
      connectedNodeIds: model.connectedNodeIds,
      isWalkable: model.isWalkable,
      isStairs: model.isStairs,
      isElevator: model.isElevator,
    );
  }

  NodeModel _mapToModel(Node entity) {
    return NodeModel(
      id: entity.id,
      x: entity.x,
      y: entity.y,
      floorId: entity.floorId,
      locationId: entity.locationId,
      connectedNodeIds: entity.connectedNodeIds,
      isWalkable: entity.isWalkable,
      isStairs: entity.isStairs,
      isElevator: entity.isElevator,
    );
  }
}
