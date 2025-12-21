/// CampusNav - Path Entity
///
/// Domain entity representing a navigation path.
/// A path is a sequence of nodes from origin to destination.

import 'node.dart';

// =============================================================================
// PATH ENTITY
// =============================================================================

class Path {
  final List<Node> nodes;
  final double totalDistance;
  final int estimatedTimeSeconds;
  final bool crossesFloors;

  const Path({
    required this.nodes,
    required this.totalDistance,
    this.estimatedTimeSeconds = 0,
    this.crossesFloors = false,
  });

  /// Empty path (no route found)
  static const Path empty = Path(
    nodes: [],
    totalDistance: 0,
    estimatedTimeSeconds: 0,
  );

  /// Check if path exists
  bool get isValid => nodes.isNotEmpty;

  /// Get number of steps in the path
  int get stepCount => nodes.length;

  /// Get origin node
  Node? get origin => nodes.isNotEmpty ? nodes.first : null;

  /// Get destination node
  Node? get destination => nodes.isNotEmpty ? nodes.last : null;

  /// Get path as list of coordinates
  List<(double, double)> get coordinates =>
      nodes.map((n) => (n.x, n.y)).toList();

  /// Get estimated time in minutes
  double get estimatedTimeMinutes => estimatedTimeSeconds / 60.0;

  /// Format estimated time as string
  String get formattedTime {
    if (estimatedTimeSeconds < 60) {
      return '< 1 min';
    }
    final minutes = (estimatedTimeSeconds / 60).round();
    return '$minutes min';
  }

  /// Format distance as string
  String get formattedDistance {
    if (totalDistance < 1000) {
      return '${totalDistance.round()} m';
    }
    return '${(totalDistance / 1000).toStringAsFixed(1)} km';
  }

  @override
  String toString() =>
      'Path(${nodes.length} nodes, ${formattedDistance}, ${formattedTime})';
}

// =============================================================================
// PATH SEGMENT (for multi-floor paths)
// =============================================================================

class PathSegment {
  final String floorId;
  final List<Node> nodes;
  final String? transitionType; // 'stairs' or 'elevator'

  const PathSegment({
    required this.floorId,
    required this.nodes,
    this.transitionType,
  });
}
