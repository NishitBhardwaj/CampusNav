/// CampusNav - Demo Navigation Data
///
/// PHASE 2: Placeholder demo data for ONE building and ONE floor.
///
/// This represents a simple campus building layout for testing and demonstration.
/// In production, this would be loaded from a database or admin-created content.

import '../domain/entities/node.dart';
import '../domain/entities/edge.dart';

// =============================================================================
// DEMO BUILDING: Computer Science Building
// =============================================================================

class DemoNavigationData {
  /// Get demo nodes for Ground Floor
  static List<Node> getGroundFloorNodes() {
    return [
      // ENTRY POINTS
      Node(
        id: 'node_entry_main',
        x: 0,
        y: 0,
        floorId: 'ground',
        type: NodeType.ENTRY,
        label: 'Main Entrance',
        isWalkable: true,
      ),
      
      // HALLWAY CHECKPOINTS
      Node(
        id: 'node_hall_1',
        x: 10,
        y: 0,
        floorId: 'ground',
        type: NodeType.HALLWAY,
        label: 'Main Hallway - Section 1',
        connectedNodeIds: ['node_entry_main', 'node_hall_2', 'node_room_101'],
      ),
      
      Node(
        id: 'node_hall_2',
        x: 20,
        y: 0,
        floorId: 'ground',
        type: NodeType.HALLWAY,
        label: 'Main Hallway - Section 2',
        connectedNodeIds: ['node_hall_1', 'node_hall_3', 'node_room_102'],
      ),
      
      Node(
        id: 'node_hall_3',
        x: 30,
        y: 0,
        floorId: 'ground',
        type: NodeType.HALLWAY,
        label: 'Main Hallway - Section 3',
        connectedNodeIds: ['node_hall_2', 'node_stairs_1', 'node_room_103'],
      ),
      
      // DESTINATIONS (ROOMS)
      Node(
        id: 'node_room_101',
        x: 10,
        y: 10,
        floorId: 'ground',
        locationId: 'room_101',
        type: NodeType.DESTINATION,
        label: 'Room 101 - Registrar Office',
        connectedNodeIds: ['node_hall_1'],
      ),
      
      Node(
        id: 'node_room_102',
        x: 20,
        y: 10,
        floorId: 'ground',
        locationId: 'room_102',
        type: NodeType.DESTINATION,
        label: 'Room 102 - Computer Lab',
        connectedNodeIds: ['node_hall_2'],
      ),
      
      Node(
        id: 'node_room_103',
        x: 30,
        y: 10,
        floorId: 'ground',
        locationId: 'room_103',
        type: NodeType.DESTINATION,
        label: 'Room 103 - Lecture Hall',
        connectedNodeIds: ['node_hall_3'],
      ),
      
      // FLOOR CONNECTOR
      Node(
        id: 'node_stairs_1',
        x: 30,
        y: -5,
        floorId: 'ground',
        type: NodeType.FLOOR_CONNECTOR,
        label: 'Staircase A',
        isStairs: true,
        connectedNodeIds: ['node_hall_3'],
      ),
    ];
  }
  
  /// Get demo nodes for First Floor
  static List<Node> getFirstFloorNodes() {
    return [
      // FLOOR CONNECTOR (connects to ground floor)
      Node(
        id: 'node_stairs_1_f1',
        x: 30,
        y: -5,
        floorId: 'first',
        type: NodeType.FLOOR_CONNECTOR,
        label: 'Staircase A - First Floor',
        isStairs: true,
        connectedNodeIds: ['node_hall_f1_1'],
      ),
      
      // HALLWAY
      Node(
        id: 'node_hall_f1_1',
        x: 30,
        y: 0,
        floorId: 'first',
        type: NodeType.HALLWAY,
        label: 'First Floor Hallway',
        connectedNodeIds: ['node_stairs_1_f1', 'node_room_201', 'node_room_202'],
      ),
      
      // DESTINATIONS
      Node(
        id: 'node_room_201',
        x: 20,
        y: 10,
        floorId: 'first',
        locationId: 'room_201',
        type: NodeType.DESTINATION,
        label: 'Room 201 - Dean Office',
        connectedNodeIds: ['node_hall_f1_1'],
      ),
      
      Node(
        id: 'node_room_202',
        x: 30,
        y: 10,
        floorId: 'first',
        locationId: 'room_202',
        type: NodeType.DESTINATION,
        label: 'Room 202 - Faculty Lounge',
        connectedNodeIds: ['node_hall_f1_1'],
      ),
    ];
  }
  
  /// Get all demo nodes (both floors)
  static List<Node> getAllNodes() {
    return [
      ...getGroundFloorNodes(),
      ...getFirstFloorNodes(),
    ];
  }
  
  /// Get demo edges (connections between nodes)
  static List<Edge> getDemoEdges() {
    final nodes = getAllNodes();
    final nodeMap = {for (var n in nodes) n.id: n};
    final edges = <Edge>[];
    
    // Auto-generate edges from node connections
    for (final node in nodes) {
      for (final connectedId in node.connectedNodeIds) {
        final connectedNode = nodeMap[connectedId];
        if (connectedNode != null) {
          // Calculate distance
          final dx = connectedNode.x - node.x;
          final dy = connectedNode.y - node.y;
          final distance = (dx * dx + dy * dy);
          
          // Create edge (avoid duplicates by checking ID)
          final edgeId = '${node.id}_to_$connectedId';
          final reverseId = '${connectedId}_to_${node.id}';
          
          // Only add if not already added in reverse
          if (!edges.any((e) => e.id == edgeId || e.id == reverseId)) {
            edges.add(Edge.fromNodes(
              fromNodeId: node.id,
              toNodeId: connectedId,
              distance: distance,
              label: '${node.label} → ${connectedNode.label}',
            ));
          }
        }
      }
    }
    
    return edges;
  }
  
  /// Get floor transition edges (stairs connecting floors)
  static List<({String groundNodeId, String firstNodeId})> getFloorTransitions() {
    return [
      (groundNodeId: 'node_stairs_1', firstNodeId: 'node_stairs_1_f1'),
    ];
  }
}
