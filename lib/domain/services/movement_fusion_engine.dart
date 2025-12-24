/// CampusNav - Movement Fusion Engine
///
/// PHASE 3: Combines multiple positioning inputs with priority-based fusion.
///
/// INPUT PRIORITY (highest to lowest):
/// 1. QR Location - Absolute trust (100% accurate)
/// 2. Visual Landmark - High confidence (80%+ match)
/// 3. Step + Heading - Medium confidence (sensor-based)
/// 4. Manual Override - Explicit user trust
///
/// CONFIDENCE MODEL:
/// - HIGH: Normal movement, all sensors reliable
/// - MEDIUM: Slower updates, enforce rail snapping
/// - LOW: Freeze movement, request user confirmation
///
/// KEY PRINCIPLE:
/// We prioritize RELIABILITY over PRECISION.
/// Better to move slowly and correctly than fast and wrong.

import 'dart:async';
import '../entities/node.dart';
import '../navigation/graph.dart';
import 'sensor_input_service.dart';
import 'rail_snapping_service.dart';

// =============================================================================
// POSITIONING CONFIDENCE
// =============================================================================

enum PositioningConfidence {
  HIGH,    // 80-100% - Trust fully, normal movement
  MEDIUM,  // 50-79% - Apply corrections, slower updates
  LOW,     // 0-49% - Freeze or request confirmation
}

// =============================================================================
// POSITIONING SOURCE
// =============================================================================

enum PositioningSource {
  QR_SCAN,           // QR code scanned
  VISUAL_LANDMARK,   // Visual recognition match
  SENSOR_FUSION,     // Step + compass
  MANUAL_OVERRIDE,   // User correction
  RAIL_SNAP,         // Snapped to path
  DEMO_MODE,         // Simulated
}

// =============================================================================
// FUSED POSITION
// =============================================================================

class FusedPosition {
  final double x;
  final double y;
  final String floorId;
  final double heading;
  final PositioningConfidence confidence;
  final PositioningSource source;
  final DateTime timestamp;
  
  FusedPosition({
    required this.x,
    required this.y,
    required this.floorId,
    required this.heading,
    required this.confidence,
    required this.source,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// Convert to confidence percentage (0-100)
  int get confidencePercent {
    switch (confidence) {
      case PositioningConfidence.HIGH:
        return 90;
      case PositioningConfidence.MEDIUM:
        return 65;
      case PositioningConfidence.LOW:
        return 30;
    }
  }
  
  @override
  String toString() => 'FusedPosition($x, $y) on $floorId, ${confidencePercent}% [$source]';
}

// =============================================================================
// MOVEMENT FUSION ENGINE
// =============================================================================

class MovementFusionEngine {
  final SensorInputService _sensors;
  final RailSnappingService _railSnapping;
  final NavigationGraph _graph;
  
  // Current fused state
  FusedPosition? _currentPosition;
  PositioningConfidence _overallConfidence = PositioningConfidence.MEDIUM;
  
  // Heading smoothing
  final List<double> _headingHistory = [];
  static const int headingHistorySize = 5;
  
  // Confidence factors
  double _sensorConfidenceFactor = 0.7;
  double _positionDriftFactor = 1.0;
  
  // Stream
  final _positionController = StreamController<FusedPosition>.broadcast();
  Stream<FusedPosition> get positionStream => _positionController.stream;
  
  MovementFusionEngine({
    required SensorInputService sensors,
    required RailSnappingService railSnapping,
    required NavigationGraph graph,
  }) : _sensors = sensors,
       _railSnapping = railSnapping,
       _graph = graph;
  
  // Getters
  FusedPosition? get currentPosition => _currentPosition;
  PositioningConfidence get overallConfidence => _overallConfidence;
  
  // ===========================================================================
  // POSITION FUSION (PRIORITY-BASED)
  // ===========================================================================
  
  /// Update position from QR scan (HIGHEST PRIORITY)
  /// 
  /// QR provides absolute ground truth - we trust it completely
  void updateFromQR({
    required Node scannedNode,
    double? heading,
  }) {
    _currentPosition = FusedPosition(
      x: scannedNode.x,
      y: scannedNode.y,
      floorId: scannedNode.floorId,
      heading: heading ?? _currentPosition?.heading ?? 0.0,
      confidence: PositioningConfidence.HIGH,
      source: PositioningSource.QR_SCAN,
    );
    
    // Reset confidence factors
    _sensorConfidenceFactor = 1.0;
    _positionDriftFactor = 1.0;
    _overallConfidence = PositioningConfidence.HIGH;
    
    // Clear heading history for fresh start
    _headingHistory.clear();
    
    _emitPosition();
  }
  
  /// Update position from visual landmark (HIGH PRIORITY)
  /// 
  /// Visual recognition with high confidence match
  void updateFromVisualLandmark({
    required Node landmarkNode,
    required double confidenceScore,
  }) {
    if (confidenceScore < 0.8) {
      // Don't trust low-confidence matches
      return;
    }
    
    _currentPosition = FusedPosition(
      x: landmarkNode.x,
      y: landmarkNode.y,
      floorId: landmarkNode.floorId,
      heading: _currentPosition?.heading ?? 0.0,
      confidence: PositioningConfidence.HIGH,
      source: PositioningSource.VISUAL_LANDMARK,
    );
    
    // Boost confidence
    _sensorConfidenceFactor = 0.9;
    _positionDriftFactor = 0.9;
    _overallConfidence = PositioningConfidence.HIGH;
    
    _emitPosition();
  }
  
  /// Update position from sensors (MEDIUM PRIORITY)
  /// 
  /// Combines step counting and compass heading
  void updateFromSensors({
    required int steps,
    required double heading,
    required SensorConfidence headingConfidence,
    required WalkingState walkingState,
  }) {
    if (_currentPosition == null) {
      // Need initial position first
      return;
    }
    
    // Don't move if user is still
    if (walkingState == WalkingState.STILL) {
      return;
    }
    
    // Calculate movement based on steps
    const stepLength = 0.7; // meters per step
    final distance = steps * stepLength;
    
    // Use smoothed heading
    final smoothedHeading = _addAndSmoothHeading(heading);
    
    // Calculate new position
    final radians = smoothedHeading * (pi / 180);
    final dx = distance * sin(radians);
    final dy = distance * cos(radians);
    
    final newX = _currentPosition!.x + dx;
    final newY = _currentPosition!.y + dy;
    
    // Determine confidence based on sensor quality
    final confidence = _calculateSensorConfidence(headingConfidence);
    
    _currentPosition = FusedPosition(
      x: newX,
      y: newY,
      floorId: _currentPosition!.floorId,
      heading: smoothedHeading,
      confidence: confidence,
      source: PositioningSource.SENSOR_FUSION,
    );
    
    // Degrade confidence over time (drift accumulates)
    _positionDriftFactor *= 0.98;
    _updateOverallConfidence();
    
    _emitPosition();
  }
  
  /// Update position from manual override (EXPLICIT TRUST)
  void updateFromManual({
    required double x,
    required double y,
    required String floorId,
    double? heading,
  }) {
    _currentPosition = FusedPosition(
      x: x,
      y: y,
      floorId: floorId,
      heading: heading ?? _currentPosition?.heading ?? 0.0,
      confidence: PositioningConfidence.MEDIUM,
      source: PositioningSource.MANUAL_OVERRIDE,
    );
    
    _sensorConfidenceFactor = 0.7;
    _positionDriftFactor = 0.9;
    _overallConfidence = PositioningConfidence.MEDIUM;
    
    _emitPosition();
  }
  
  /// Apply rail snapping correction
  /// 
  /// Keeps position on valid paths
  FusedPosition? applyRailSnapping() {
    if (_currentPosition == null) return null;
    
    final floorEdges = _graph.getEdgesByFloor(_currentPosition!.floorId);
    
    final nearest = _railSnapping.getNearestEdge(
      currentX: _currentPosition!.x,
      currentY: _currentPosition!.y,
      availableEdges: floorEdges,
      nodeMap: _graph.nodeMap,
      currentFloorId: _currentPosition!.floorId,
    );
    
    if (nearest == null) return _currentPosition;
    
    // Snap heading to edge direction
    final snappedHeading = _railSnapping.snapToEdge(
      currentHeading: _currentPosition!.heading,
      edge: nearest.edge,
      nodeMap: _graph.nodeMap,
    );
    
    _currentPosition = FusedPosition(
      x: nearest.x,
      y: nearest.y,
      floorId: _currentPosition!.floorId,
      heading: snappedHeading,
      confidence: _currentPosition!.confidence,
      source: PositioningSource.RAIL_SNAP,
    );
    
    // Rail snapping improves confidence slightly
    _positionDriftFactor = (_positionDriftFactor * 1.05).clamp(0.0, 1.0);
    _updateOverallConfidence();
    
    _emitPosition();
    return _currentPosition;
  }
  
  // ===========================================================================
  // CONFIDENCE CALCULATION
  // ===========================================================================
  
  /// Calculate confidence from sensor quality
  PositioningConfidence _calculateSensorConfidence(SensorConfidence sensorConf) {
    double baseConfidence;
    
    switch (sensorConf) {
      case SensorConfidence.HIGH:
        baseConfidence = 0.9;
        break;
      case SensorConfidence.MEDIUM:
        baseConfidence = 0.7;
        break;
      case SensorConfidence.LOW:
        baseConfidence = 0.4;
        break;
    }
    
    // Apply drift factor
    final finalConfidence = baseConfidence * _positionDriftFactor;
    
    if (finalConfidence >= 0.8) {
      return PositioningConfidence.HIGH;
    } else if (finalConfidence >= 0.5) {
      return PositioningConfidence.MEDIUM;
    } else {
      return PositioningConfidence.LOW;
    }
  }
  
  /// Update overall confidence based on all factors
  void _updateOverallConfidence() {
    final combinedFactor = _sensorConfidenceFactor * _positionDriftFactor;
    
    if (combinedFactor >= 0.8) {
      _overallConfidence = PositioningConfidence.HIGH;
    } else if (combinedFactor >= 0.5) {
      _overallConfidence = PositioningConfidence.MEDIUM;
    } else {
      _overallConfidence = PositioningConfidence.LOW;
    }
  }
  
  // ===========================================================================
  // HEADING SMOOTHING
  // ===========================================================================
  
  /// Add heading to history and return smoothed value
  double _addAndSmoothHeading(double heading) {
    _headingHistory.add(heading);
    if (_headingHistory.length > headingHistorySize) {
      _headingHistory.removeAt(0);
    }
    
    if (_headingHistory.isEmpty) return heading;
    
    // Weighted average (more recent = higher weight)
    double sum = 0.0;
    double weightSum = 0.0;
    
    for (int i = 0; i < _headingHistory.length; i++) {
      final weight = (i + 1).toDouble();
      sum += _headingHistory[i] * weight;
      weightSum += weight;
    }
    
    return sum / weightSum;
  }
  
  // ===========================================================================
  // HELPERS
  // ===========================================================================
  
  void _emitPosition() {
    if (_currentPosition != null) {
      _positionController.add(_currentPosition!);
    }
  }
  
  void dispose() {
    _positionController.close();
  }
}

import 'dart:math' show pi, sin, cos;
