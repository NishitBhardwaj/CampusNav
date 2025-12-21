/// CampusNav - Find Path Use Case
///
/// Business logic for finding optimal paths between locations.

import '../entities/node.dart';
import '../entities/path.dart';
import '../navigation/a_star_pathfinder.dart';

// =============================================================================
// FIND PATH USE CASE
// =============================================================================

class FindPathUseCase {
  final AStarPathfinder _pathfinder;

  FindPathUseCase(this._pathfinder);

  /// Find path between two nodes
  Future<Path> execute({
    required Node startNode,
    required Node endNode,
    required Map<String, Node> graph,
    bool preferStairs = false,
    bool preferElevator = false,
  }) async {
    // Use A* algorithm to find optimal path
    final pathNodes = _pathfinder.findPath(
      start: startNode,
      goal: endNode,
      graph: graph,
    );

    if (pathNodes.isEmpty) {
      return Path.empty;
    }

    // Calculate total distance
    double totalDistance = 0;
    for (int i = 0; i < pathNodes.length - 1; i++) {
      totalDistance += _calculateDistance(pathNodes[i], pathNodes[i + 1]);
    }

    // Estimate time (assuming 1.4 m/s walking speed)
    final estimatedTime = (totalDistance / 1.4).round();

    // Check if path crosses floors
    final floors = pathNodes.map((n) => n.floorId).toSet();
    final crossesFloors = floors.length > 1;

    return Path(
      nodes: pathNodes,
      totalDistance: totalDistance,
      estimatedTimeSeconds: estimatedTime,
      crossesFloors: crossesFloors,
    );
  }

  double _calculateDistance(Node a, Node b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    return (dx * dx + dy * dy);
  }
}
