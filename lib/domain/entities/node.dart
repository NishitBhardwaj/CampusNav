/// CampusNav - Node Entity
///
/// Domain entity representing a navigation graph node.
/// Nodes are points that can be traversed during pathfinding.

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
  });

  /// Get position as a tuple
  (double, double) get position => (x, y);

  /// Check if this node connects floors
  bool get isFloorConnector => isStairs || isElevator;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Node && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Node($id at $x, $y)';
}
