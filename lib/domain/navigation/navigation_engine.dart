/// CampusNav - Navigation Engine
///
/// Main navigation controller that coordinates pathfinding,
/// position tracking, and navigation instructions.
///
/// PHASE 2 ENHANCEMENTS:
/// - Rail snapping for drift control
/// - Hybrid positioning system
/// - Demo mode support
/// - Floor management
/// - Dynamic rerouting on blocked paths

import '../entities/node.dart';
import '../entities/path.dart';
import '../entities/location.dart';
import '../entities/edge.dart';
import 'a_star_pathfinder.dart';
import 'graph.dart';
import '../services/rail_snapping_service.dart';
import '../services/navigation_positioning_service.dart';
import '../services/demo_mode_service.dart';
import '../services/floor_management_service.dart';

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
  
  /// PHASE 2: New services
  final RailSnappingService _railSnapping;
  final NavigationPositioningService _positioning;
  final DemoModeService _demoMode;
  final FloorManagementService _floorManagement;

  NavigationStatus _status = NavigationStatus.idle;
  Path? _currentPath;
  int _currentStepIndex = 0;
  CurrentPosition? _currentPosition;
  Location? _destination;
  
  /// PHASE 2: Dynamic rerouting flag
  bool dynamicRerouteOnBlock = true;

  NavigationEngine({
    AStarPathfinder? pathfinder,
    NavigationGraph? graph,
    RailSnappingService? railSnapping,
    NavigationPositioningService? positioning,
    DemoModeService? demoMode,
  })  : _pathfinder = pathfinder ?? AStarPathfinder(),
        _graph = graph ?? NavigationGraph(),
        _railSnapping = railSnapping ?? RailSnappingService(),
        _positioning = positioning ?? NavigationPositioningService(),
        _demoMode = demoMode ?? DemoModeService(),
        _floorManagement = FloorManagementService(
          graph: graph ?? NavigationGraph(),
          pathfinder: pathfinder,
        );

  // Getters
  NavigationStatus get status => _status;
  Path? get currentPath => _currentPath;
  int get currentStepIndex => _currentStepIndex;
  CurrentPosition? get currentPosition => _currentPosition;
  Location? get destination => _destination;
  NavigationGraph get graph => _graph;
  
  /// PHASE 2: Service getters
  RailSnappingService get railSnapping => _railSnapping;
  NavigationPositioningService get positioning => _positioning;
  DemoModeService get demoMode => _demoMode;
  FloorManagementService get floorManagement => _floorManagement;

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
  
  // ===========================================================================
  // PHASE 2: BLOCKED PATH HANDLING
  // ===========================================================================
  
  /// Block a path segment and reroute
  /// 
  /// This is called when user reports a blocked hallway or path.
  /// The system will mark the edge as blocked and recalculate the route.
  Future<Path?> blockPathAndReroute({
    required String fromNodeId,
    required String toNodeId,
    required String reason,
  }) async {
    // Block the edge
    _graph.blockEdge(fromNodeId, toNodeId, reason);
    
    // Recalculate route if currently navigating
    if (_status == NavigationStatus.navigating && dynamicRerouteOnBlock) {
      _status = NavigationStatus.rerouting;
      return recalculateRoute();
    }
    
    return null;
  }
  
  /// Unblock a previously blocked path
  void unblockPath({
    required String fromNodeId,
    required String toNodeId,
  }) {
    _graph.unblockEdge(fromNodeId, toNodeId);
  }
  
  /// Get list of blocked edges
  List<Edge> getBlockedEdges() {
    return _graph.allEdges.where((e) => e.isBlocked).toList();
  }
  
  // ===========================================================================
  // PHASE 2: RAIL SNAPPING
  // ===========================================================================
  
  /// Apply rail snapping to current position
  /// 
  /// This keeps the user position aligned to valid navigation paths.
  /// Call this periodically during navigation to prevent drift.
  CurrentPosition? applyRailSnapping(CurrentPosition position) {
    if (_currentPath == null) return position;
    
    // Get edges on current floor
    final floorEdges = _graph.getEdgesByFloor(position.floorId);
    
    // Find nearest edge
    final nearest = _railSnapping.getNearestEdge(
      currentX: position.x,
      currentY: position.y,
      availableEdges: floorEdges,
      nodeMap: _graph.nodeMap,
      currentFloorId: position.floorId,
    );
    
    if (nearest == null) return position;
    
    // Snap heading to edge direction
    final snappedHeading = _railSnapping.snapToEdge(
      currentHeading: position.heading,
      edge: nearest.edge,
      nodeMap: _graph.nodeMap,
    );
    
    // Return snapped position
    return CurrentPosition(
      x: nearest.x,
      y: nearest.y,
      floorId: position.floorId,
      heading: snappedHeading,
      timestamp: position.timestamp,
    );
  }
  
  /// Check if user is off path
  bool isOffPath(CurrentPosition position) {
    final floorEdges = _graph.getEdgesByFloor(position.floorId);
    
    return _railSnapping.isOffPath(
      currentX: position.x,
      currentY: position.y,
      availableEdges: floorEdges,
      nodeMap: _graph.nodeMap,
      currentFloorId: position.floorId,
    );
  }
  
  // ===========================================================================
  // PHASE 2: RESOURCE MANAGEMENT
  // ===========================================================================
  
  /// Dispose resources
  void dispose() {
    _positioning.dispose();
    _demoMode.dispose();
  }
}
