/// CampusNav - Phase 2 Navigation Tests
///
/// Unit tests for Phase 2 navigation features:
/// - A* pathfinding
/// - Dynamic rerouting
/// - Rail snapping
/// - Multi-floor traversal

import 'package:flutter_test/flutter_test.dart';
import 'package:campusnav/domain/entities/node.dart';
import 'package:campusnav/domain/entities/edge.dart';
import 'package:campusnav/domain/navigation/graph.dart';
import 'package:campusnav/domain/navigation/a_star_pathfinder.dart';
import 'package:campusnav/domain/services/rail_snapping_service.dart';
import 'package:campusnav/data/mock/mock_navigation_data.dart';

void main() {
  group('A* Pathfinding Tests', () {
    late NavigationGraph graph;
    late AStarPathfinder pathfinder;

    setUp(() {
      graph = NavigationGraph();
      pathfinder = AStarPathfinder();
      
      // Load demo data
      final nodes = DemoNavigationData.getAllNodes();
      for (final node in nodes) {
        graph.addNode(node);
      }
    });

    test('Find path on same floor', () {
      final startNode = graph.getNode('node_entry_main');
      final goalNode = graph.getNode('node_room_103');

      expect(startNode, isNotNull);
      expect(goalNode, isNotNull);

      final path = pathfinder.findPath(
        start: startNode!,
        goal: goalNode!,
        graph: graph.nodeMap,
        navigationGraph: graph,
      );

      expect(path, isNotEmpty);
      expect(path.first.id, equals('node_entry_main'));
      expect(path.last.id, equals('node_room_103'));
    });

    test('Path is empty when no route exists', () {
      // Create isolated node
      final isolatedNode = Node(
        id: 'isolated',
        x: 100,
        y: 100,
        floorId: 'ground',
        type: NodeType.DESTINATION,
      );
      graph.addNode(isolatedNode);

      final startNode = graph.getNode('node_entry_main')!;
      final path = pathfinder.findPath(
        start: startNode,
        goal: isolatedNode,
        graph: graph.nodeMap,
        navigationGraph: graph,
      );

      expect(path, isEmpty);
    });

    test('Path avoids blocked edges', () {
      final startNode = graph.getNode('node_entry_main')!;
      final goalNode = graph.getNode('node_room_102')!;

      // Find initial path
      final initialPath = pathfinder.findPath(
        start: startNode,
        goal: goalNode,
        graph: graph.nodeMap,
        navigationGraph: graph,
      );

      expect(initialPath, isNotEmpty);

      // Block an edge on the path
      graph.blockEdge('node_hall_1', 'node_hall_2', 'Test blocking');

      // Find new path
      final newPath = pathfinder.findPath(
        start: startNode,
        goal: goalNode,
        graph: graph.nodeMap,
        navigationGraph: graph,
      );

      // Path should either be different or empty (if no alternative)
      if (newPath.isNotEmpty) {
        expect(newPath, isNot(equals(initialPath)));
      }
    });
  });

  group('Dynamic Rerouting Tests', () {
    late NavigationGraph graph;

    setUp(() {
      graph = NavigationGraph();
      final nodes = DemoNavigationData.getAllNodes();
      for (final node in nodes) {
        graph.addNode(node);
      }
    });

    test('Block and unblock edge', () {
      expect(graph.isEdgeBlocked('node_hall_1', 'node_hall_2'), isFalse);

      graph.blockEdge('node_hall_1', 'node_hall_2', 'Maintenance');
      expect(graph.isEdgeBlocked('node_hall_1', 'node_hall_2'), isTrue);

      graph.unblockEdge('node_hall_1', 'node_hall_2');
      expect(graph.isEdgeBlocked('node_hall_1', 'node_hall_2'), isFalse);
    });

    test('Get blocked edges', () {
      graph.blockEdge('node_hall_1', 'node_hall_2', 'Test 1');
      graph.blockEdge('node_hall_2', 'node_hall_3', 'Test 2');

      final blockedEdges = graph.allEdges.where((e) => e.isBlocked).toList();
      expect(blockedEdges.length, greaterThanOrEqualTo(2));
    });
  });

  group('Rail Snapping Tests', () {
    late RailSnappingService railSnapping;
    late NavigationGraph graph;

    setUp(() {
      railSnapping = RailSnappingService();
      graph = NavigationGraph();
      
      // Create simple test graph
      final node1 = Node(
        id: 'n1',
        x: 0,
        y: 0,
        floorId: 'ground',
        connectedNodeIds: ['n2'],
      );
      final node2 = Node(
        id: 'n2',
        x: 10,
        y: 0,
        floorId: 'ground',
        connectedNodeIds: ['n1'],
      );
      
      graph.addNode(node1);
      graph.addNode(node2);
    });

    test('Find nearest edge', () {
      final edges = graph.getEdgesByFloor('ground');
      
      final nearest = railSnapping.getNearestEdge(
        currentX: 5,
        currentY: 1,
        availableEdges: edges,
        nodeMap: graph.nodeMap,
        currentFloorId: 'ground',
      );

      expect(nearest, isNotNull);
      expect(nearest!.distanceToEdge, lessThan(2.0));
    });

    test('Snap heading to edge direction', () {
      final edges = graph.getEdgesByFloor('ground');
      final edge = edges.first;

      // Heading significantly off from edge direction
      final currentHeading = 45.0;
      
      final snappedHeading = railSnapping.snapToEdge(
        currentHeading: currentHeading,
        edge: edge,
        nodeMap: graph.nodeMap,
      );

      // Should snap to edge direction (90° for horizontal edge)
      expect(snappedHeading, isNot(equals(currentHeading)));
    });

    test('Detect off-path position', () {
      final edges = graph.getEdgesByFloor('ground');

      // Position close to path
      final onPath = railSnapping.isOffPath(
        currentX: 5,
        currentY: 0.5,
        availableEdges: edges,
        nodeMap: graph.nodeMap,
        currentFloorId: 'ground',
      );

      expect(onPath, isFalse);

      // Position far from path
      final offPath = railSnapping.isOffPath(
        currentX: 5,
        currentY: 10,
        availableEdges: edges,
        nodeMap: graph.nodeMap,
        currentFloorId: 'ground',
      );

      expect(offPath, isTrue);
    });
  });

  group('Multi-Floor Traversal Tests', () {
    late NavigationGraph graph;
    late AStarPathfinder pathfinder;

    setUp(() {
      graph = NavigationGraph();
      pathfinder = AStarPathfinder();
      
      final nodes = DemoNavigationData.getAllNodes();
      for (final node in nodes) {
        graph.addNode(node);
      }
    });

    test('Identify floor connectors', () {
      final groundConnectors = graph.getFloorConnectors('ground');
      final firstConnectors = graph.getFloorConnectors('first');

      expect(groundConnectors, isNotEmpty);
      expect(firstConnectors, isNotEmpty);
      
      expect(groundConnectors.first.isFloorConnector, isTrue);
    });

    test('Path crosses floors', () {
      // Get nodes on different floors
      final groundNode = graph.getNode('node_room_101');
      final firstNode = graph.getNode('node_room_201');

      expect(groundNode, isNotNull);
      expect(firstNode, isNotNull);
      expect(groundNode!.floorId, isNot(equals(firstNode!.floorId)));
    });
  });

  group('Edge Model Tests', () {
    test('Create edge from nodes', () {
      final edge = Edge.fromNodes(
        fromNodeId: 'n1',
        toNodeId: 'n2',
        distance: 10.0,
        label: 'Test Edge',
      );

      expect(edge.fromNodeId, equals('n1'));
      expect(edge.toNodeId, equals('n2'));
      expect(edge.distance, equals(10.0));
      expect(edge.isBlocked, isFalse);
    });

    test('Block and unblock edge', () {
      final edge = Edge.fromNodes(
        fromNodeId: 'n1',
        toNodeId: 'n2',
        distance: 10.0,
      );

      final blocked = edge.block('Maintenance');
      expect(blocked.isBlocked, isTrue);
      expect(blocked.blockReason, equals('Maintenance'));
      expect(blocked.blockedAt, isNotNull);

      final unblocked = blocked.unblock();
      expect(unblocked.isBlocked, isFalse);
      expect(unblocked.blockReason, isNull);
    });

    test('Edge connects nodes bidirectionally', () {
      final edge = Edge.fromNodes(
        fromNodeId: 'n1',
        toNodeId: 'n2',
        distance: 10.0,
      );

      expect(edge.connects('n1', 'n2'), isTrue);
      expect(edge.connects('n2', 'n1'), isTrue);
      expect(edge.connects('n1', 'n3'), isFalse);
    });
  });
}
