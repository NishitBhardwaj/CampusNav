/// CampusNav - Navigation Positioning Service
///
/// PHASE 2: Hybrid positioning system for indoor navigation.
///
/// WHY NO GPS:
/// - GPS doesn't work indoors (buildings block satellite signals)
/// - Even if it did, accuracy would be 5-15 meters (useless for rooms)
/// - We need sub-meter accuracy for turn-by-turn navigation
///
/// OUR APPROACH - HYBRID POSITIONING:
/// 1. Step counting → estimate forward movement (0.7m per step)
/// 2. Compass → estimate direction (with heavy filtering)
/// 3. QR checkpoints → absolute position reset (ground truth)
/// 4. Rail snapping → keep position on valid paths
/// 5. Manual overrides → user can correct when system fails
///
/// This is MORE RELIABLE than trying to use GPS or complex sensor fusion.

import 'dart:async';
import '../entities/node.dart';

// =============================================================================
// POSITIONING SERVICE
// =============================================================================

class NavigationPositioningService {
  /// Average step length in meters
  /// Based on typical adult walking stride
  static const double stepLength = 0.7;
  
  /// Minimum confidence threshold for compass readings (0-1)
  /// Below this, we ignore compass and use path direction instead
  static const double compassConfidenceThreshold = 0.6;

  // Current position state
  double _currentX = 0;
  double _currentY = 0;
  String _currentFloorId = '';
  double _currentHeading = 0; // degrees, 0 = North
  int _stepCount = 0;
  
  // Confidence metrics
  double _positionConfidence = 0.0; // 0-1
  double _headingConfidence = 0.0; // 0-1

  // Stream controllers for real-time updates
  final _positionController = StreamController<PositionUpdate>.broadcast();
  final _stepController = StreamController<int>.broadcast();

  // Getters
  double get currentX => _currentX;
  double get currentY => _currentY;
  String get currentFloorId => _currentFloorId;
  double get currentHeading => _currentHeading;
  int get stepCount => _stepCount;
  double get positionConfidence => _positionConfidence;
  double get headingConfidence => _headingConfidence;

  Stream<PositionUpdate> get positionStream => _positionController.stream;
  Stream<int> get stepStream => _stepController.stream;

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initialize position from QR code scan or manual selection
  /// This provides absolute ground truth position
  void initializePosition({
    required double x,
    required double y,
    required String floorId,
    double? heading,
  }) {
    _currentX = x;
    _currentY = y;
    _currentFloorId = floorId;
    _currentHeading = heading ?? 0;
    _stepCount = 0;
    _positionConfidence = 1.0; // High confidence from QR
    _headingConfidence = heading != null ? 0.8 : 0.3;

    _emitPositionUpdate(source: 'QR_INIT');
  }

  // ===========================================================================
  // STEP COUNTING (TODO: Implement with accelerometer)
  // ===========================================================================

  /// Process step detection from accelerometer
  /// 
  /// TODO PHASE 2.5: Implement actual accelerometer integration
  /// For now, this is a placeholder that can be called manually or in demo mode
  void onStepDetected() {
    _stepCount++;
    _stepController.add(_stepCount);

    // Move forward in current heading direction
    _moveForward(stepLength);
  }

  /// Simulate multiple steps (for demo mode)
  void simulateSteps(int count) {
    for (int i = 0; i < count; i++) {
      onStepDetected();
    }
  }

  /// Reset step counter
  void resetStepCount() {
    _stepCount = 0;
    _stepController.add(_stepCount);
  }

  // ===========================================================================
  // COMPASS / HEADING (TODO: Implement with magnetometer)
  // ===========================================================================

  /// Update heading from compass sensor
  /// 
  /// TODO PHASE 2.5: Implement actual magnetometer integration
  /// 
  /// IMPORTANT: Indoor compass is UNRELIABLE due to:
  /// - Metal structures in buildings
  /// - Electronic interference
  /// - Phone orientation changes
  /// 
  /// We apply heavy filtering and only use when confidence is high.
  void updateHeading(double heading, {double confidence = 0.5}) {
    if (confidence < compassConfidenceThreshold) {
      // Compass unreliable, ignore
      _headingConfidence = confidence;
      return;
    }

    // Apply smoothing to reduce jitter
    _currentHeading = _smoothHeading(_currentHeading, heading);
    _headingConfidence = confidence;

    _emitPositionUpdate(source: 'COMPASS');
  }

  /// Set heading manually (for demo mode or when compass fails)
  void setHeading(double heading) {
    _currentHeading = heading;
    _headingConfidence = 0.5; // Medium confidence for manual
    _emitPositionUpdate(source: 'MANUAL_HEADING');
  }

  // ===========================================================================
  // QR CHECKPOINT OVERRIDE
  // ===========================================================================

  /// Reset position to QR checkpoint (absolute ground truth)
  /// 
  /// This is the MOST RELIABLE positioning method.
  /// When user scans a QR code, we know EXACTLY where they are.
  /// This corrects any accumulated drift from step counting.
  void resetToCheckpoint({
    required Node checkpointNode,
  }) {
    _currentX = checkpointNode.x;
    _currentY = checkpointNode.y;
    _currentFloorId = checkpointNode.floorId;
    _positionConfidence = 1.0; // Perfect confidence
    
    _emitPositionUpdate(source: 'QR_CHECKPOINT');
  }

  // ===========================================================================
  // MANUAL OVERRIDES
  // ===========================================================================

  /// Manually set position (for testing or when all else fails)
  void setPosition({
    required double x,
    required double y,
    String? floorId,
  }) {
    _currentX = x;
    _currentY = y;
    if (floorId != null) {
      _currentFloorId = floorId;
    }
    _positionConfidence = 0.7; // Medium-high confidence for manual
    
    _emitPositionUpdate(source: 'MANUAL_POSITION');
  }

  /// Change floor manually (when automatic detection fails)
  void changeFloor(String newFloorId) {
    _currentFloorId = newFloorId;
    _positionConfidence *= 0.8; // Reduce confidence slightly
    
    _emitPositionUpdate(source: 'MANUAL_FLOOR_CHANGE');
  }

  // ===========================================================================
  // POSITION UPDATES (INTERNAL)
  // ===========================================================================

  /// Move forward in current heading direction
  void _moveForward(double distance) {
    // Convert heading to radians (0° = North = positive Y)
    final radians = _currentHeading * (3.14159 / 180);
    
    // Calculate movement delta
    final dx = distance * radians.sin();
    final dy = distance * radians.cos();
    
    _currentX += dx;
    _currentY += dy;
    
    // Reduce confidence slightly with each step (drift accumulates)
    _positionConfidence = (_positionConfidence * 0.98).clamp(0.3, 1.0);
    
    _emitPositionUpdate(source: 'STEP');
  }

  /// Apply position correction from rail snapping
  void applyRailSnap({
    required double snappedX,
    required double snappedY,
    required double snappedHeading,
  }) {
    _currentX = snappedX;
    _currentY = snappedY;
    _currentHeading = snappedHeading;
    
    // Rail snapping improves confidence
    _positionConfidence = (_positionConfidence * 1.1).clamp(0.0, 1.0);
    
    _emitPositionUpdate(source: 'RAIL_SNAP');
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Smooth heading changes to reduce jitter
  double _smoothHeading(double current, double target) {
    // Use exponential smoothing
    const alpha = 0.3; // Smoothing factor (0 = no change, 1 = instant)
    
    // Handle angle wrapping (359° → 1° should be smooth)
    double diff = target - current;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    
    return (current + alpha * diff) % 360;
  }

  /// Emit position update to listeners
  void _emitPositionUpdate({required String source}) {
    _positionController.add(PositionUpdate(
      x: _currentX,
      y: _currentY,
      floorId: _currentFloorId,
      heading: _currentHeading,
      confidence: _positionConfidence,
      headingConfidence: _headingConfidence,
      source: source,
      timestamp: DateTime.now(),
    ));
  }

  /// Clean up resources
  void dispose() {
    _positionController.close();
    _stepController.close();
  }
}

// =============================================================================
// POSITION UPDATE MODEL
// =============================================================================

class PositionUpdate {
  final double x;
  final double y;
  final String floorId;
  final double heading;
  final double confidence;
  final double headingConfidence;
  final String source;
  final DateTime timestamp;

  PositionUpdate({
    required this.x,
    required this.y,
    required this.floorId,
    required this.heading,
    required this.confidence,
    required this.headingConfidence,
    required this.source,
    required this.timestamp,
  });

  @override
  String toString() => 'Position($x, $y) on $floorId, heading: ${heading.toStringAsFixed(0)}°, confidence: ${(confidence * 100).toStringAsFixed(0)}% [$source]';
}
