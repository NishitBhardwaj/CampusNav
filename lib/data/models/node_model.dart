/// CampusNav - Node Model
///
/// Data model for navigation graph nodes.
/// Nodes represent points on the map where users can navigate to or through.

// =============================================================================
// NODE MODEL
// =============================================================================

class NodeModel {
  final String id;
  final double x;
  final double y;
  final String floorId;
  final String? locationId; // Links to LocationModel if this is a named location
  final List<String> connectedNodeIds;
  final bool isWalkable;
  final bool isStairs;
  final bool isElevator;

  NodeModel({
    required this.id,
    required this.x,
    required this.y,
    required this.floorId,
    this.locationId,
    this.connectedNodeIds = const [],
    this.isWalkable = true,
    this.isStairs = false,
    this.isElevator = false,
  });

  /// Create from JSON map
  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      floorId: json['floor_id'] as String,
      locationId: json['location_id'] as String?,
      connectedNodeIds: (json['connected_node_ids'] as List?)?.cast<String>() ?? [],
      isWalkable: json['is_walkable'] as bool? ?? true,
      isStairs: json['is_stairs'] as bool? ?? false,
      isElevator: json['is_elevator'] as bool? ?? false,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'floor_id': floorId,
      'location_id': locationId,
      'connected_node_ids': connectedNodeIds,
      'is_walkable': isWalkable,
      'is_stairs': isStairs,
      'is_elevator': isElevator,
    };
  }
}
