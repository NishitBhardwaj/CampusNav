/// CampusNav - A* Pathfinder
///
/// Implementation of A* (A-star) pathfinding algorithm for
/// finding optimal paths in the navigation graph.

import 'dart:collection';
import 'dart:math';
import '../entities/node.dart';
import 'graph.dart'; // PHASE 2: For blocked edge checking

// =============================================================================
// A* PATHFINDER
// =============================================================================

class AStarPathfinder {
  /// Find the shortest path from start to goal using A* algorithm
  /// 
  /// PHASE 2: Now supports dynamic rerouting by avoiding blocked edges
  List<Node> findPath({
    required Node start,
    required Node goal,
    required Map<String, Node> graph,
    NavigationGraph? navigationGraph, // PHASE 2: For blocked edge checking
  }) {
    // Priority queue for nodes to explore (ordered by f-score)
    final openSet = PriorityQueue<_AStarNode>(
      (a, b) => a.fScore.compareTo(b.fScore),
    );

    // Set of visited nodes
    final closedSet = <String>{};

    // Maps for tracking costs and paths
    final gScore = <String, double>{};
    final cameFrom = <String, String>{};

    // Initialize start node
    gScore[start.id] = 0;
    openSet.add(_AStarNode(
      nodeId: start.id,
      fScore: _heuristic(start, goal),
    ));

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();

      // Goal reached - reconstruct path
      if (current.nodeId == goal.id) {
        return _reconstructPath(cameFrom, goal.id, graph);
      }

      // Skip if already processed
      if (closedSet.contains(current.nodeId)) continue;
      closedSet.add(current.nodeId);

      final currentNode = graph[current.nodeId];
      if (currentNode == null) continue;

      // Explore neighbors
      for (final neighborId in currentNode.connectedNodeIds) {
        if (closedSet.contains(neighborId)) continue;

        final neighbor = graph[neighborId];
        if (neighbor == null || !neighbor.isWalkable) continue;
        
        // PHASE 2: Skip blocked edges
        if (navigationGraph != null && 
            navigationGraph.isEdgeBlocked(current.nodeId, neighborId)) {
          continue;
        }

        // Calculate tentative g-score
        final tentativeG =
            (gScore[current.nodeId] ?? double.infinity) +
            _distance(currentNode, neighbor);

        // If this path is better, record it
        if (tentativeG < (gScore[neighborId] ?? double.infinity)) {
          cameFrom[neighborId] = current.nodeId;
          gScore[neighborId] = tentativeG;

          openSet.add(_AStarNode(
            nodeId: neighborId,
            fScore: tentativeG + _heuristic(neighbor, goal),
          ));
        }
      }
    }

    // No path found
    return [];
  }

  /// Euclidean distance heuristic
  double _heuristic(Node a, Node b) {
    return _distance(a, b);
  }

  /// Calculate distance between two nodes
  double _distance(Node a, Node b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;

    // Add penalty for floor changes
    double penalty = 0;
    if (a.floorId != b.floorId) {
      penalty = 50; // Discourage unnecessary floor changes
    }

    return sqrt(dx * dx + dy * dy) + penalty;
  }

  /// Reconstruct path from cameFrom map
  List<Node> _reconstructPath(
    Map<String, String> cameFrom,
    String goalId,
    Map<String, Node> graph,
  ) {
    final path = <Node>[];
    String? current = goalId;

    while (current != null) {
      final node = graph[current];
      if (node != null) {
        path.insert(0, node);
      }
      current = cameFrom[current];
    }

    return path;
  }
}

// =============================================================================
// HELPER CLASS FOR PRIORITY QUEUE
// =============================================================================

class _AStarNode {
  final String nodeId;
  final double fScore;

  _AStarNode({
    required this.nodeId,
    required this.fScore,
  });
}

// =============================================================================
// PRIORITY QUEUE IMPLEMENTATION
// =============================================================================

class PriorityQueue<T> {
  final List<T> _heap = [];
  final int Function(T, T) _compare;

  PriorityQueue(this._compare);

  bool get isNotEmpty => _heap.isNotEmpty;
  bool get isEmpty => _heap.isEmpty;

  void add(T element) {
    _heap.add(element);
    _bubbleUp(_heap.length - 1);
  }

  T removeFirst() {
    if (_heap.isEmpty) throw StateError('Queue is empty');

    final first = _heap.first;
    final last = _heap.removeLast();

    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _bubbleDown(0);
    }

    return first;
  }

  void _bubbleUp(int index) {
    while (index > 0) {
      final parentIndex = (index - 1) ~/ 2;
      if (_compare(_heap[index], _heap[parentIndex]) >= 0) break;

      final temp = _heap[index];
      _heap[index] = _heap[parentIndex];
      _heap[parentIndex] = temp;
      index = parentIndex;
    }
  }

  void _bubbleDown(int index) {
    while (true) {
      final leftChild = 2 * index + 1;
      final rightChild = 2 * index + 2;
      var smallest = index;

      if (leftChild < _heap.length &&
          _compare(_heap[leftChild], _heap[smallest]) < 0) {
        smallest = leftChild;
      }

      if (rightChild < _heap.length &&
          _compare(_heap[rightChild], _heap[smallest]) < 0) {
        smallest = rightChild;
      }

      if (smallest == index) break;

      final temp = _heap[index];
      _heap[index] = _heap[smallest];
      _heap[smallest] = temp;
      index = smallest;
    }
  }
}
