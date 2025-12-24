/// CampusNav - Edge Entity
///
/// Domain entity representing a connection between two nodes in the navigation graph.
/// Edges define walkable paths with distance and blocking capabilities.
///
/// PHASE 2: Critical for dynamic rerouting and blocked path handling

// =============================================================================
// EDGE ENTITY
// =============================================================================

/// Represents a bidirectional connection between two nodes
class Edge {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final double distance;
  
  /// PHASE 2: Flag for dynamic rerouting when paths are blocked
  /// When true, A* pathfinding will avoid this edge
  final bool isBlocked;
  
  /// Optional label for debugging (e.g., "Main Hallway", "Stairwell A")
  final String? label;
  
  /// Timestamp when edge was blocked (if applicable)
  final DateTime? blockedAt;
  
  /// Reason for blocking (user-reported, maintenance, etc.)
  final String? blockReason;

  const Edge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.distance,
    this.isBlocked = false,
    this.label,
    this.blockedAt,
    this.blockReason,
  });

  /// Create edge from two node IDs with calculated distance
  factory Edge.fromNodes({
    required String fromNodeId,
    required String toNodeId,
    required double distance,
    String? label,
  }) {
    return Edge(
      id: '${fromNodeId}_to_$toNodeId',
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      distance: distance,
      label: label,
    );
  }

  /// Copy with method for blocking/unblocking edges
  Edge copyWith({
    String? id,
    String? fromNodeId,
    String? toNodeId,
    double? distance,
    bool? isBlocked,
    String? label,
    DateTime? blockedAt,
    String? blockReason,
  }) {
    return Edge(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      distance: distance ?? this.distance,
      isBlocked: isBlocked ?? this.isBlocked,
      label: label ?? this.label,
      blockedAt: blockedAt ?? this.blockedAt,
      blockReason: blockReason ?? this.blockReason,
    );
  }

  /// Block this edge with a reason
  Edge block(String reason) {
    return copyWith(
      isBlocked: true,
      blockedAt: DateTime.now(),
      blockReason: reason,
    );
  }

  /// Unblock this edge
  Edge unblock() {
    return copyWith(
      isBlocked: false,
      blockedAt: null,
      blockReason: null,
    );
  }

  /// Check if this edge connects the given nodes (bidirectional)
  bool connects(String nodeId1, String nodeId2) {
    return (fromNodeId == nodeId1 && toNodeId == nodeId2) ||
           (fromNodeId == nodeId2 && toNodeId == nodeId1);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Edge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Edge($fromNodeId → $toNodeId, ${distance.toStringAsFixed(1)}m${isBlocked ? ' [BLOCKED]' : ''})';
}
