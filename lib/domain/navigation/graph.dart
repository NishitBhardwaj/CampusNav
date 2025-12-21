/// CampusNav - Navigation Graph
///
/// Graph data structure for representing the navigation network.
/// Provides utilities for graph operations and queries.

import '../entities/node.dart';

// =============================================================================
// NAVIGATION GRAPH
// =============================================================================

class NavigationGraph {
  final Map<String, Node> _nodes = {};
  final Map<String, List<String>> _adjacencyList = {};

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
  void addEdge(String fromId, String toId) {
    _adjacencyList.putIfAbsent(fromId, () => []);
    _adjacencyList.putIfAbsent(toId, () => []);

    if (!_adjacencyList[fromId]!.contains(toId)) {
      _adjacencyList[fromId]!.add(toId);
    }
    if (!_adjacencyList[toId]!.contains(fromId)) {
      _adjacencyList[toId]!.add(fromId);
    }
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
