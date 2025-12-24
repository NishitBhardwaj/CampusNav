/// CampusNav - Floor Management Service
///
/// PHASE 2: Handles multi-floor navigation and floor transitions.
///
/// WHY FLOOR MANAGEMENT IS CRITICAL:
/// - Indoor navigation often requires moving between floors
/// - Automatic floor detection is UNRELIABLE (barometer drift, etc.)
/// - User confirmation prevents navigation errors
/// - Manual override ensures system never gets stuck
///
/// APPROACH:
/// 1. Detect when path crosses floors (via stairs/elevator nodes)
/// 2. Prompt user for confirmation before floor change
/// 3. Allow manual floor selection as fallback
/// 4. Update navigation graph to current floor

import '../entities/node.dart';
import '../entities/path.dart';
import 'navigation/graph.dart';
import 'navigation/a_star_pathfinder.dart';

// =============================================================================
// FLOOR MANAGEMENT SERVICE
// =============================================================================

class FloorManagementService {
  final NavigationGraph _graph;
  final AStarPathfinder _pathfinder;
  
  String _currentFloorId = '';
  
  FloorManagementService({
    required NavigationGraph graph,
    AStarPathfinder? pathfinder,
  }) : _graph = graph,
       _pathfinder = pathfinder ?? AStarPathfinder();
  
  String get currentFloorId => _currentFloorId;
  
  /// Set current floor
  void setCurrentFloor(String floorId) {
    _currentFloorId = floorId;
  }
  
  /// Check if a path crosses floors
  bool pathCrossesFloors(Path path) {
    if (path.nodes.isEmpty) return false;
    
    final floors = path.nodes.map((n) => n.floorId).toSet();
    return floors.length > 1;
  }
  
  /// Get floor transitions in a path
  /// Returns list of (fromFloor, toFloor, transitionNode)
  List<FloorTransition> getFloorTransitions(Path path) {
    final transitions = <FloorTransition>[];
    
    for (int i = 0; i < path.nodes.length - 1; i++) {
      final current = path.nodes[i];
      final next = path.nodes[i + 1];
      
      if (current.floorId != next.floorId) {
        transitions.add(FloorTransition(
          fromFloorId: current.floorId,
          toFloorId: next.floorId,
          transitionNode: next,
          nodeIndex: i + 1,
        ));
      }
    }
    
    return transitions;
  }
  
  /// Navigate across floors
  /// 
  /// This is the main method for multi-floor navigation.
  /// It handles pathfinding even when start and goal are on different floors.
  Path? navigateToNodeAcrossFloors({
    required Node startNode,
    required Node goalNode,
  }) {
    // If same floor, simple pathfinding
    if (startNode.floorId == goalNode.floorId) {
      final pathNodes = _pathfinder.findPath(
        start: startNode,
        goal: goalNode,
        graph: _graph.nodeMap,
        navigationGraph: _graph,
      );
      
      if (pathNodes.isEmpty) return null;
      
      return Path(
        nodes: pathNodes,
        totalDistance: _calculatePathDistance(pathNodes),
        estimatedTimeSeconds: _estimateTime(pathNodes),
        crossesFloors: false,
      );
    }
    
    // Different floors - need to find floor connector
    final startFloorConnectors = _graph.getFloorConnectors(startNode.floorId);
    final goalFloorConnectors = _graph.getFloorConnectors(goalNode.floorId);
    
    if (startFloorConnectors.isEmpty || goalFloorConnectors.isEmpty) {
      // No way to change floors
      return null;
    }
    
    // Find best path through floor connectors
    Path? bestPath;
    double bestDistance = double.infinity;
    
    for (final startConnector in startFloorConnectors) {
      for (final goalConnector in goalFloorConnectors) {
        // Check if connectors are linked (same staircase/elevator)
        if (!_areConnectorsLinked(startConnector, goalConnector)) {
          continue;
        }
        
        // Path from start to connector on start floor
        final pathToConnector = _pathfinder.findPath(
          start: startNode,
          goal: startConnector,
          graph: _graph.nodeMap,
          navigationGraph: _graph,
        );
        
        if (pathToConnector.isEmpty) continue;
        
        // Path from connector to goal on goal floor
        final pathFromConnector = _pathfinder.findPath(
          start: goalConnector,
          goal: goalNode,
          graph: _graph.nodeMap,
          navigationGraph: _graph,
        );
        
        if (pathFromConnector.isEmpty) continue;
        
        // Combine paths
        final combinedNodes = [
          ...pathToConnector,
          goalConnector, // Add the connector on the destination floor
          ...pathFromConnector.skip(1), // Skip first node (duplicate connector)
        ];
        
        final distance = _calculatePathDistance(combinedNodes);
        
        if (distance < bestDistance) {
          bestDistance = distance;
          bestPath = Path(
            nodes: combinedNodes,
            totalDistance: distance,
            estimatedTimeSeconds: _estimateTime(combinedNodes),
            crossesFloors: true,
          );
        }
      }
    }
    
    return bestPath;
  }
  
  /// Check if two floor connectors are linked (same staircase/elevator)
  /// 
  /// In a real implementation, this would check a database of linked connectors.
  /// For demo, we use naming convention (e.g., "stairs_1" and "stairs_1_f1")
  bool _areConnectorsLinked(Node connector1, Node connector2) {
    // Simple heuristic: if labels contain same identifier
    final label1 = connector1.label?.toLowerCase() ?? connector1.id;
    final label2 = connector2.label?.toLowerCase() ?? connector2.id;
    
    // Extract base name (e.g., "stairs_1" from "stairs_1_f1")
    final baseName1 = label1.replaceAll(RegExp(r'_f\d+$'), '');
    final baseName2 = label2.replaceAll(RegExp(r'_f\d+$'), '');
    
    return baseName1 == baseName2;
  }
  
  /// Calculate total distance of a path
  double _calculatePathDistance(List<Node> nodes) {
    double total = 0;
    for (int i = 0; i < nodes.length - 1; i++) {
      final dx = nodes[i + 1].x - nodes[i].x;
      final dy = nodes[i + 1].y - nodes[i].y;
      total += (dx * dx + dy * dy);
    }
    return total;
  }
  
  /// Estimate time in seconds (assuming 1.4 m/s walking speed)
  int _estimateTime(List<Node> nodes) {
    final distance = _calculatePathDistance(nodes);
    return (distance / 1.4).round();
  }
  
  /// Get available floors in the graph
  List<String> getAvailableFloors() {
    final floors = <String>{};
    for (final node in _graph.allNodes) {
      floors.add(node.floorId);
    }
    return floors.toList()..sort();
  }
  
  /// Get floor connectors for current floor
  List<Node> getCurrentFloorConnectors() {
    if (_currentFloorId.isEmpty) return [];
    return _graph.getFloorConnectors(_currentFloorId);
  }
}

// =============================================================================
// FLOOR TRANSITION MODEL
// =============================================================================

class FloorTransition {
  final String fromFloorId;
  final String toFloorId;
  final Node transitionNode;
  final int nodeIndex; // Index in path where transition occurs
  
  FloorTransition({
    required this.fromFloorId,
    required this.toFloorId,
    required this.transitionNode,
    required this.nodeIndex,
  });
  
  String get transitionType => transitionNode.isStairs ? 'stairs' : 'elevator';
  
  String get instruction {
    final action = transitionNode.isStairs ? 'Take stairs' : 'Take elevator';
    return '$action from $fromFloorId to $toFloorId';
  }
  
  @override
  String toString() => 'FloorTransition($fromFloorId → $toFloorId via $transitionType at node ${nodeIndex})';
}
