/// CampusNav - Navigation Graph
///
/// Graph data structure for representing the navigation network.
/// Provides utilities for graph operations and queries.
///
/// PHASE 2 ENHANCEMENTS:
/// - Edge-based graph with blocking support
/// - Multi-floor navigation
/// - Dynamic rerouting when paths blocked

import '../entities/node.dart';
import '../entities/edge.dart';

// =============================================================================
// NAVIGATION GRAPH
// =============================================================================

class NavigationGraph {
  final Map<String, Node> _nodes = {};
  final Map<String, List<String>> _adjacencyList = {};
  
  /// PHASE 2: Edge storage for blocking support
  final Map<String, Edge> _edges = {};
  
  /// PHASE 2: Track blocked edges for dynamic rerouting
  final Set<String> _blockedEdges = {};

  /// Add a node to the graph
  void addNode(Node node) {
    _nodes[node.id] = node;
    _adjacencyList.putIfAbsent(node.id, () => []);

    // Add connections
    for (final connectedId in node.connectedNodeIds) {
      addEdge(node.id, connectedId);
    }
  }

  /// Add an edge between two nodes
  void addEdge(String fromId, String toId, {double? distance}) {
    _adjacencyList.putIfAbsent(fromId, () => []);
    _adjacencyList.putIfAbsent(toId, () => []);

    if (!_adjacencyList[fromId]!.contains(toId)) {
      _adjacencyList[fromId]!.add(toId);
    }
    if (!_adjacencyList[toId]!.contains(fromId)) {
      _adjacencyList[toId]!.add(fromId);
    }
    
    // PHASE 2: Create edge object
    final fromNode = _nodes[fromId];
    final toNode = _nodes[toId];
    if (fromNode != null && toNode != null) {
      final calculatedDistance = distance ?? _calculateDistance(fromNode, toNode);
      final edge = Edge.fromNodes(
        fromNodeId: fromId,
        toNodeId: toId,
        distance: calculatedDistance,
      );
      _edges[edge.id] = edge;
    }
  }
  
  /// PHASE 2: Add edge object directly
  void addEdgeObject(Edge edge) {
    _edges[edge.id] = edge;
    
    // Update adjacency list
    _adjacencyList.putIfAbsent(edge.fromNodeId, () => []);
    _adjacencyList.putIfAbsent(edge.toNodeId, () => []);
    
    if (!_adjacencyList[edge.fromNodeId]!.contains(edge.toNodeId)) {
      _adjacencyList[edge.fromNodeId]!.add(edge.toNodeId);
    }
    if (!_adjacencyList[edge.toNodeId]!.contains(edge.fromNodeId)) {
      _adjacencyList[edge.toNodeId]!.add(edge.fromNodeId);
    }
  }
  
  /// PHASE 2: Block an edge (for dynamic rerouting)
  void blockEdge(String fromId, String toId, String reason) {
    final edgeId = '${fromId}_to_$toId';
    final reverseId = '${toId}_to_$fromId';
    
    _blockedEdges.add(edgeId);
    _blockedEdges.add(reverseId);
    
    // Update edge object if it exists
    if (_edges.containsKey(edgeId)) {
      _edges[edgeId] = _edges[edgeId]!.block(reason);
    }
    if (_edges.containsKey(reverseId)) {
      _edges[reverseId] = _edges[reverseId]!.block(reason);
    }
  }
  
  /// PHASE 2: Unblock an edge
  void unblockEdge(String fromId, String toId) {
    final edgeId = '${fromId}_to_$toId';
    final reverseId = '${toId}_to_$fromId';
    
    _blockedEdges.remove(edgeId);
    _blockedEdges.remove(reverseId);
    
    // Update edge object if it exists
    if (_edges.containsKey(edgeId)) {
      _edges[edgeId] = _edges[edgeId]!.unblock();
    }
    if (_edges.containsKey(reverseId)) {
      _edges[reverseId] = _edges[reverseId]!.unblock();
    }
  }
  
  /// PHASE 2: Check if edge is blocked
  bool isEdgeBlocked(String fromId, String toId) {
    final edgeId = '${fromId}_to_$toId';
    return _blockedEdges.contains(edgeId);
  }
  
  /// PHASE 2: Get all edges
  List<Edge> get allEdges => _edges.values.toList();
  
  /// PHASE 2: Get edges for a specific floor
  List<Edge> getEdgesByFloor(String floorId) {
    return _edges.values.where((edge) {
      final fromNode = _nodes[edge.fromNodeId];
      return fromNode?.floorId == floorId;
    }).toList();
  }

  /// Get a node by ID
  Node? getNode(String id) => _nodes[id];

  /// Get all nodes
  List<Node> get allNodes => _nodes.values.toList();

  /// Get nodes on a specific floor
  List<Node> getNodesByFloor(String floorId) {
    return _nodes.values.where((n) => n.floorId == floorId).toList();
  }

  /// Get adjacent node IDs
  List<String> getAdjacentNodeIds(String nodeId) {
    return _adjacencyList[nodeId] ?? [];
  }

  /// Get adjacent nodes
  List<Node> getAdjacentNodes(String nodeId) {
    final adjacentIds = _adjacencyList[nodeId] ?? [];
    return adjacentIds.map((id) => _nodes[id]).whereType<Node>().toList();
  }

  /// Find node closest to a point
  Node? findClosestNode(double x, double y, String floorId) {
    Node? closest;
    double minDistance = double.infinity;

    for (final node in _nodes.values) {
      if (node.floorId != floorId || !node.isWalkable) continue;

      final dx = node.x - x;
      final dy = node.y - y;
      final distance = dx * dx + dy * dy;

      if (distance < minDistance) {
        minDistance = distance;
        closest = node;
      }
    }

    return closest;
  }

  /// Find node by associated location ID
  Node? findNodeByLocationId(String locationId) {
    return _nodes.values.where((n) => n.locationId == locationId).firstOrNull;
  }

  /// Get floor connectors (stairs, elevators)
  List<Node> getFloorConnectors(String floorId) {
    return _nodes.values
        .where((n) => n.floorId == floorId && n.isFloorConnector)
        .toList();
  }

  /// Get all nodes as a map (for A* algorithm)
  Map<String, Node> get nodeMap => Map.unmodifiable(_nodes);

  /// Clear the graph
  void clear() {
    _nodes.clear();
    _adjacencyList.clear();
    _edges.clear();
    _blockedEdges.clear();
  }
  
  /// PHASE 2: Calculate distance between two nodes
  double _calculateDistance(Node a, Node b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    return (dx * dx + dy * dy); // Return squared distance for efficiency
  }

  /// Get number of nodes
  int get nodeCount => _nodes.length;

  /// Get number of edges
  int get edgeCount {
    int count = 0;
    for (final edges in _adjacencyList.values) {
      count += edges.length;
    }
    return count ~/ 2; // Each edge is counted twice
  }
}
