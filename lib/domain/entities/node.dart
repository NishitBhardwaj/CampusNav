/// CampusNav - Node Entity
///
/// Domain entity representing a navigation graph node.
/// Nodes are points that can be traversed during pathfinding.
///
/// PHASE 2 ENHANCEMENTS:
/// - NodeType classification for intelligent routing
/// - Label for user-friendly descriptions
/// - Support for rail-snapping and position tracking

// =============================================================================
// NODE TYPE ENUM
// =============================================================================

/// Classification of nodes for navigation logic
enum NodeType {
  /// Building entrance or exit point
  ENTRY,
  
  /// Intermediate waypoint for path guidance
  CHECKPOINT,
  
  /// Stairs or elevator connecting floors
  FLOOR_CONNECTOR,
  
  /// Final destination (room, office, etc.)
  DESTINATION,
  
  /// Generic hallway or corridor node
  HALLWAY,
}

// =============================================================================
// NODE ENTITY
// =============================================================================

class Node {
  final String id;
  final double x;
  final double y;
  final String floorId;
  final String? locationId;
  final List<String> connectedNodeIds;
  final bool isWalkable;
  final bool isStairs;
  final bool isElevator;
  
  /// PHASE 2: Node type for intelligent routing
  final NodeType type;
  
  /// PHASE 2: Human-readable label (e.g., "Main Entrance", "Room 204")
  final String? label;

  const Node({
    required this.id,
    required this.x,
    required this.y,
    required this.floorId,
    this.locationId,
    this.connectedNodeIds = const [],
    this.isWalkable = true,
    this.isStairs = false,
    this.isElevator = false,
    this.type = NodeType.CHECKPOINT,
    this.label,
  });

  /// Get position as a tuple
  (double, double) get position => (x, y);

  /// Check if this node connects floors
  bool get isFloorConnector => isStairs || isElevator || type == NodeType.FLOOR_CONNECTOR;

  /// Copy with method for creating modified nodes
  Node copyWith({
    String? id,
    double? x,
    double? y,
    String? floorId,
    String? locationId,
    List<String>? connectedNodeIds,
    bool? isWalkable,
    bool? isStairs,
    bool? isElevator,
    NodeType? type,
    String? label,
  }) {
    return Node(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      floorId: floorId ?? this.floorId,
      locationId: locationId ?? this.locationId,
      connectedNodeIds: connectedNodeIds ?? this.connectedNodeIds,
      isWalkable: isWalkable ?? this.isWalkable,
      isStairs: isStairs ?? this.isStairs,
      isElevator: isElevator ?? this.isElevator,
      type: type ?? this.type,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Node && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Node($id${label != null ? ' - $label' : ''} at $x, $y)';
}
