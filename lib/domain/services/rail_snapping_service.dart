/// CampusNav - Rail Snapping Service
///
/// PHASE 2: Critical service for preventing sensor drift during navigation.
///
/// WHY RAIL SNAPPING IS ESSENTIAL:
/// - Indoor sensors (accelerometer, compass) are inherently noisy
/// - Users don't walk in perfectly straight lines
/// - Compass can be affected by metal structures, electronics
/// - Without snapping, the user dot would drift through walls
///
/// HOW IT WORKS:
/// 1. User position is always "snapped" to the nearest valid edge
/// 2. If heading deviates >20° from edge direction → auto-correct
/// 3. If position moves outside corridor boundaries → snap to nearest point
///
/// This ensures the navigation dot stays on valid paths, preventing
/// the confusing experience of seeing yourself "walk through walls".

import 'dart:math';
import '../entities/node.dart';
import '../entities/edge.dart';

// =============================================================================
// RAIL SNAPPING SERVICE
// =============================================================================

class RailSnappingService {
  /// Maximum allowed deviation angle before snapping (degrees)
  static const double maxDeviationAngle = 20.0;
  
  /// Maximum distance from edge before considering off-path (meters)
  static const double maxEdgeDistance = 3.0;

  /// Find the nearest edge to the current position
  /// 
  /// Returns the edge and the closest point on that edge.
  /// This is used to keep the user "on rails" during navigation.
  ({Edge edge, double x, double y, double distanceToEdge})? getNearestEdge({
    required double currentX,
    required double currentY,
    required List<Edge> availableEdges,
    required Map<String, Node> nodeMap,
    String? currentFloorId,
  }) {
    if (availableEdges.isEmpty) return null;

    Edge? nearestEdge;
    double minDistance = double.infinity;
    double closestX = currentX;
    double closestY = currentY;

    for (final edge in availableEdges) {
      // Skip blocked edges
      if (edge.isBlocked) continue;

      final fromNode = nodeMap[edge.fromNodeId];
      final toNode = nodeMap[edge.toNodeId];

      if (fromNode == null || toNode == null) continue;

      // Skip if edge is on different floor
      if (currentFloorId != null && fromNode.floorId != currentFloorId) {
        continue;
      }

      // Find closest point on edge to current position
      final result = _closestPointOnSegment(
        currentX, currentY,
        fromNode.x, fromNode.y,
        toNode.x, toNode.y,
      );

      if (result.distance < minDistance) {
        minDistance = result.distance;
        nearestEdge = edge;
        closestX = result.x;
        closestY = result.y;
      }
    }

    if (nearestEdge == null) return null;

    return (
      edge: nearestEdge,
      x: closestX,
      y: closestY,
      distanceToEdge: minDistance,
    );
  }

  /// Snap heading to edge direction if deviation is too large
  /// 
  /// Returns corrected heading in degrees (0-360, where 0 = North)
  /// 
  /// WHY THIS MATTERS:
  /// - Compass readings can be unreliable indoors
  /// - Users may turn their phone while walking
  /// - This keeps the navigation arrow pointing in the right direction
  double snapToEdge({
    required double currentHeading,
    required Edge edge,
    required Map<String, Node> nodeMap,
    bool forceSnap = false,
  }) {
    final fromNode = nodeMap[edge.fromNodeId];
    final toNode = nodeMap[edge.toNodeId];

    if (fromNode == null || toNode == null) {
      return currentHeading;
    }

    // Calculate edge direction
    final edgeHeading = _calculateHeading(
      fromNode.x, fromNode.y,
      toNode.x, toNode.y,
    );

    // Calculate deviation
    final deviation = _angleDifference(currentHeading, edgeHeading);

    // Snap if deviation exceeds threshold or forced
    if (forceSnap || deviation.abs() > maxDeviationAngle) {
      return edgeHeading;
    }

    return currentHeading;
  }

  /// Check if position is significantly off-path
  /// 
  /// Returns true if user has drifted too far from valid edges.
  /// This can trigger a "lost" state or rerouting.
  bool isOffPath({
    required double currentX,
    required double currentY,
    required List<Edge> availableEdges,
    required Map<String, Node> nodeMap,
    String? currentFloorId,
  }) {
    final nearest = getNearestEdge(
      currentX: currentX,
      currentY: currentY,
      availableEdges: availableEdges,
      nodeMap: nodeMap,
      currentFloorId: currentFloorId,
    );

    if (nearest == null) return true;

    return nearest.distanceToEdge > maxEdgeDistance;
  }

  /// Snap position to nearest valid point on path
  /// 
  /// Returns corrected (x, y) coordinates.
  /// Use this to prevent the user dot from appearing in walls.
  ({double x, double y}) snapPosition({
    required double currentX,
    required double currentY,
    required List<Edge> availableEdges,
    required Map<String, Node> nodeMap,
    String? currentFloorId,
  }) {
    final nearest = getNearestEdge(
      currentX: currentX,
      currentY: currentY,
      availableEdges: availableEdges,
      nodeMap: nodeMap,
      currentFloorId: currentFloorId,
    );

    if (nearest == null || nearest.distanceToEdge <= maxEdgeDistance) {
      // Position is valid, no snapping needed
      return (x: currentX, y: currentY);
    }

    // Snap to nearest point on edge
    return (x: nearest.x, y: nearest.y);
  }

  // ===========================================================================
  // PRIVATE HELPER METHODS
  // ===========================================================================

  /// Find closest point on line segment to a given point
  ({double x, double y, double distance}) _closestPointOnSegment(
    double px, double py,
    double x1, double y1,
    double x2, double y2,
  ) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final lengthSquared = dx * dx + dy * dy;

    if (lengthSquared == 0) {
      // Segment is a point
      final dist = sqrt((px - x1) * (px - x1) + (py - y1) * (py - y1));
      return (x: x1, y: y1, distance: dist);
    }

    // Calculate projection parameter
    final t = ((px - x1) * dx + (py - y1) * dy) / lengthSquared;
    final clampedT = t.clamp(0.0, 1.0);

    // Calculate closest point
    final closestX = x1 + clampedT * dx;
    final closestY = y1 + clampedT * dy;

    // Calculate distance
    final distX = px - closestX;
    final distY = py - closestY;
    final distance = sqrt(distX * distX + distY * distY);

    return (x: closestX, y: closestY, distance: distance);
  }

  /// Calculate heading from point A to point B in degrees (0 = North)
  double _calculateHeading(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    
    // atan2 returns radians, convert to degrees
    // atan2(dy, dx) gives angle from East, we want from North
    final radians = atan2(dx, dy);
    final degrees = radians * 180 / pi;
    
    // Normalize to 0-360
    return (degrees + 360) % 360;
  }

  /// Calculate smallest angle difference between two headings
  double _angleDifference(double angle1, double angle2) {
    double diff = (angle2 - angle1 + 180) % 360 - 180;
    return diff < -180 ? diff + 360 : diff;
  }
}
