/// CampusNav - Navigation Engine
///
/// Main navigation controller that coordinates pathfinding,
/// position tracking, and navigation instructions.

import '../entities/node.dart';
import '../entities/path.dart';
import '../entities/location.dart';
import 'a_star_pathfinder.dart';
import 'graph.dart';

// =============================================================================
// NAVIGATION STATUS
// =============================================================================

enum NavigationStatus {
  idle,
  calculating,
  navigating,
  rerouting,
  arrived,
  error,
}

// =============================================================================
// NAVIGATION INSTRUCTION
// =============================================================================

class NavigationInstruction {
  final String text;
  final double distance;
  final String? iconName;
  final bool isFloorChange;

  const NavigationInstruction({
    required this.text,
    required this.distance,
    this.iconName,
    this.isFloorChange = false,
  });
}

// =============================================================================
// CURRENT POSITION
// =============================================================================

class CurrentPosition {
  final double x;
  final double y;
  final String floorId;
  final double heading; // Direction in degrees (0 = North)
  final DateTime timestamp;

  CurrentPosition({
    required this.x,
    required this.y,
    required this.floorId,
    this.heading = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// =============================================================================
// NAVIGATION ENGINE
// =============================================================================

class NavigationEngine {
  final AStarPathfinder _pathfinder;
  final NavigationGraph _graph;

  NavigationStatus _status = NavigationStatus.idle;
  Path? _currentPath;
  int _currentStepIndex = 0;
  CurrentPosition? _currentPosition;
  Location? _destination;

  NavigationEngine({
    AStarPathfinder? pathfinder,
    NavigationGraph? graph,
  })  : _pathfinder = pathfinder ?? AStarPathfinder(),
        _graph = graph ?? NavigationGraph();

  // Getters
  NavigationStatus get status => _status;
  Path? get currentPath => _currentPath;
  int get currentStepIndex => _currentStepIndex;
  CurrentPosition? get currentPosition => _currentPosition;
  Location? get destination => _destination;

  /// Initialize the navigation graph with nodes
  void initializeGraph(List<Node> nodes) {
    _graph.clear();
    for (final node in nodes) {
      _graph.addNode(node);
    }
  }

  /// Set current position
  void updatePosition(CurrentPosition position) {
    _currentPosition = position;

    // Check if we've arrived
    if (_status == NavigationStatus.navigating && _currentPath != null) {
      final dest = _currentPath!.destination;
      if (dest != null) {
        final dx = position.x - dest.x;
        final dy = position.y - dest.y;
        final distance = (dx * dx + dy * dy);

        if (distance < 25) {
          // Within 5 meters (25 = 5^2)
          _status = NavigationStatus.arrived;
        }
      }
    }
  }

  /// Start navigation to a destination
  Future<Path?> startNavigation({
    required CurrentPosition from,
    required Location to,
  }) async {
    _status = NavigationStatus.calculating;
    _destination = to;
    _currentPosition = from;

    // Find closest node to current position
    final startNode = _graph.findClosestNode(from.x, from.y, from.floorId);
    if (startNode == null) {
      _status = NavigationStatus.error;
      return null;
    }

    // Find node at destination
    final endNode = _graph.findNodeByLocationId(to.id);
    if (endNode == null) {
      // Try to find closest node to destination coordinates
      final closestEnd = _graph.findClosestNode(to.x, to.y, to.floorId);
      if (closestEnd == null) {
        _status = NavigationStatus.error;
        return null;
      }
    }

    // Calculate path
    final pathNodes = _pathfinder.findPath(
      start: startNode,
      goal: endNode ?? _graph.findClosestNode(to.x, to.y, to.floorId)!,
      graph: _graph.nodeMap,
    );

    if (pathNodes.isEmpty) {
      _status = NavigationStatus.error;
      return null;
    }

    // Calculate total distance
    double totalDistance = 0;
    for (int i = 0; i < pathNodes.length - 1; i++) {
      final dx = pathNodes[i + 1].x - pathNodes[i].x;
      final dy = pathNodes[i + 1].y - pathNodes[i].y;
      totalDistance += (dx * dx + dy * dy);
    }

    _currentPath = Path(
      nodes: pathNodes,
      totalDistance: totalDistance,
      estimatedTimeSeconds: (totalDistance / 1.4).round(),
      crossesFloors:
          pathNodes.map((n) => n.floorId).toSet().length > 1,
    );

    _currentStepIndex = 0;
    _status = NavigationStatus.navigating;

    return _currentPath;
  }

  /// Get current navigation instruction
  NavigationInstruction? getCurrentInstruction() {
    if (_currentPath == null || _currentPath!.nodes.isEmpty) {
      return null;
    }

    if (_currentStepIndex >= _currentPath!.nodes.length - 1) {
      return NavigationInstruction(
        text: 'You have arrived at your destination',
        distance: 0,
        iconName: 'flag',
      );
    }

    final current = _currentPath!.nodes[_currentStepIndex];
    final next = _currentPath!.nodes[_currentStepIndex + 1];

    // Check for floor change
    if (current.floorId != next.floorId) {
      final action = next.isStairs ? 'Take stairs' : 'Take elevator';
      return NavigationInstruction(
        text: '$action to ${next.floorId}',
        distance: 0,
        iconName: next.isStairs ? 'stairs' : 'elevator',
        isFloorChange: true,
      );
    }

    final dx = next.x - current.x;
    final dy = next.y - current.y;
    final distance = (dx * dx + dy * dy);

    return NavigationInstruction(
      text: 'Continue forward',
      distance: distance,
      iconName: 'arrow_forward',
    );
  }

  /// Stop navigation
  void stopNavigation() {
    _status = NavigationStatus.idle;
    _currentPath = null;
    _currentStepIndex = 0;
    _destination = null;
  }

  /// Recalculate route (for rerouting)
  Future<Path?> recalculateRoute() async {
    if (_currentPosition == null || _destination == null) {
      return null;
    }

    _status = NavigationStatus.rerouting;
    return startNavigation(from: _currentPosition!, to: _destination!);
  }
}
