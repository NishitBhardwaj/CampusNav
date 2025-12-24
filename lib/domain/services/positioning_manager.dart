/// CampusNav - Positioning Manager
///
/// PHASE 3: Orchestrates the complete hybrid positioning pipeline.
///
/// PIPELINE ORDER:
/// 1. Check walking state
/// 2. If still → freeze position
/// 3. If walking → move dot forward (0.7m per step)
/// 4. Apply rail-snapping correction
/// 5. If heading deviates > 25° from corridor → snap to corridor angle
/// 6. If device tilt > 45° → ignore compass, assume forward direction
///
/// POSITIONING MODES:
/// - Mode A (Smart): Full sensor fusion + QR
/// - Mode B (Assisted): Snap-to-route only
/// - Mode C (Manual): Tap-through visual steps
///
/// AUTO-SWITCH LOGIC:
/// - Sensors unstable → Drop to Mode B
/// - Multiple corrections needed → Suggest Mode C
/// - AR unavailable → No crash, just message

import 'dart:async';
import '../entities/node.dart';
import '../entities/edge.dart';
import '../navigation/graph.dart';
import 'sensor_input_service.dart';
import 'movement_fusion_engine.dart';
import 'rail_snapping_service.dart';

// =============================================================================
// POSITIONING MODES
// =============================================================================

enum PositioningMode {
  SMART,     // Mode A: Full sensor fusion + QR + visual
  ASSISTED,  // Mode B: Snap-to-route only, no sensors
  MANUAL,    // Mode C: Tap-through visual steps
}

// =============================================================================
// POSITIONING EVENT
// =============================================================================

class PositioningEvent {
  final String type;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  
  PositioningEvent({
    required this.type,
    required this.message,
    DateTime? timestamp,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();
  
  @override
  String toString() => '[$type] $message';
}

// =============================================================================
// POSITIONING MANAGER
// =============================================================================

class PositioningManager {
  final SensorInputService _sensors;
  final MovementFusionEngine _fusion;
  final RailSnappingService _railSnapping;
  final NavigationGraph _graph;
  
  // Current state
  PositioningMode _currentMode = PositioningMode.SMART;
  FusedPosition? _lastPosition;
  int _lastStepCount = 0;
  int _correctionCount = 0;
  DateTime _lastCorrectionTime = DateTime.now();
  
  // Configuration
  static const double maxHeadingDeviation = 25.0; // degrees
  static const double maxTiltAngle = 45.0; // degrees
  static const int maxCorrectionsBeforeSuggestManual = 5;
  static const Duration correctionResetDuration = Duration(minutes: 2);
  
  // Streams
  final _eventController = StreamController<PositioningEvent>.broadcast();
  Stream<PositioningEvent> get eventStream => _eventController.stream;
  
  // Subscriptions
  StreamSubscription? _stepSubscription;
  StreamSubscription? _walkingStateSubscription;
  
  PositioningManager({
    required SensorInputService sensors,
    required MovementFusionEngine fusion,
    required RailSnappingService railSnapping,
    required NavigationGraph graph,
  }) : _sensors = sensors,
       _fusion = fusion,
       _railSnapping = railSnapping,
       _graph = graph {
    _initializeListeners();
  }
  
  // Getters
  PositioningMode get currentMode => _currentMode;
  FusedPosition? get currentPosition => _lastPosition;
  
  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================
  
  void _initializeListeners() {
    // Listen to step events
    _stepSubscription = _sensors.stepStream.listen((stepCount) {
      if (_currentMode == PositioningMode.SMART) {
        _onStepDetected(stepCount);
      }
    });
    
    // Listen to walking state changes
    _walkingStateSubscription = _sensors.walkingStateStream.listen((state) {
      _onWalkingStateChanged(state);
    });
  }
  
  // ===========================================================================
  // MAIN POSITIONING PIPELINE
  // ===========================================================================
  
  /// Update position - main entry point
  /// 
  /// This is called periodically (e.g., every 100ms) during navigation
  Future<FusedPosition?> updatePosition() async {
    switch (_currentMode) {
      case PositioningMode.SMART:
        return _updatePositionSmart();
      case PositioningMode.ASSISTED:
        return _updatePositionAssisted();
      case PositioningMode.MANUAL:
        // Manual mode doesn't auto-update
        return _lastPosition;
    }
  }
  
  /// Smart mode: Full sensor fusion
  Future<FusedPosition?> _updatePositionSmart() async {
    // 1. Check walking state
    final walkingState = _sensors.getWalkingState();
    
    // 2. If still → freeze position
    if (walkingState == WalkingState.STILL) {
      _logEvent('FREEZE', 'User is stationary');
      return _lastPosition;
    }
    
    // 3. If walking → move dot forward
    if (walkingState == WalkingState.WALKING) {
      final currentSteps = _sensors.getStepCount();
      final newSteps = currentSteps - _lastStepCount;
      
      if (newSteps > 0) {
        // Get heading
        var heading = _sensors.getCompassHeading();
        final headingConfidence = _sensors.getHeadingConfidence();
        final tilt = _sensors.getDeviceTiltAngle();
        
        // 6. If device tilt > 45° → ignore compass
        if (tilt > maxTiltAngle) {
          _logEvent('TILT_OVERRIDE', 'Device tilted, using forward direction');
          // Use last known heading or path direction
          heading = _lastPosition?.heading ?? heading;
        }
        
        // Update position from sensors
        _fusion.updateFromSensors(
          steps: newSteps,
          heading: heading,
          headingConfidence: headingConfidence,
          walkingState: walkingState,
        );
        
        _lastStepCount = currentSteps;
      }
    }
    
    // 4. Apply rail-snapping correction
    final snappedPosition = _fusion.applyRailSnapping();
    
    if (snappedPosition != null) {
      // 5. Check heading deviation from corridor
      final deviation = _checkHeadingDeviation(snappedPosition);
      
      if (deviation > maxHeadingDeviation) {
        _logEvent('HEADING_SNAP', 'Heading corrected to corridor direction');
        _correctionCount++;
        _lastCorrectionTime = DateTime.now();
        
        // Check if too many corrections
        _checkCorrectionThreshold();
      }
      
      _lastPosition = snappedPosition;
    }
    
    return _lastPosition;
  }
  
  /// Assisted mode: Snap-to-route only
  Future<FusedPosition?> _updatePositionAssisted() async {
    if (_lastPosition == null) return null;
    
    // Only apply rail snapping, no sensor movement
    final snapped = _fusion.applyRailSnapping();
    
    if (snapped != null) {
      _lastPosition = snapped;
    }
    
    return _lastPosition;
  }
  
  // ===========================================================================
  // EVENT HANDLERS
  // ===========================================================================
  
  void _onStepDetected(int stepCount) {
    // Steps are handled in updatePosition()
  }
  
  void _onWalkingStateChanged(WalkingState state) {
    if (state == WalkingState.STILL) {
      _logEvent('STATE_CHANGE', 'User stopped moving');
    } else if (state == WalkingState.WALKING) {
      _logEvent('STATE_CHANGE', 'User started walking');
    }
  }
  
  // ===========================================================================
  // HEADING DEVIATION CHECK
  // ===========================================================================
  
  /// Check if heading deviates from corridor direction
  double _checkHeadingDeviation(FusedPosition position) {
    final floorEdges = _graph.getEdgesByFloor(position.floorId);
    
    final nearest = _railSnapping.getNearestEdge(
      currentX: position.x,
      currentY: position.y,
      availableEdges: floorEdges,
      nodeMap: _graph.nodeMap,
      currentFloorId: position.floorId,
    );
    
    if (nearest == null) return 0.0;
    
    // Calculate corridor direction
    final fromNode = _graph.nodeMap[nearest.edge.fromNodeId];
    final toNode = _graph.nodeMap[nearest.edge.toNodeId];
    
    if (fromNode == null || toNode == null) return 0.0;
    
    final dx = toNode.x - fromNode.x;
    final dy = toNode.y - fromNode.y;
    final corridorHeading = atan2(dx, dy) * 180 / pi;
    
    // Calculate deviation
    var deviation = (position.heading - corridorHeading).abs();
    if (deviation > 180) deviation = 360 - deviation;
    
    return deviation;
  }
  
  // ===========================================================================
  // MODE SWITCHING
  // ===========================================================================
  
  /// Switch positioning mode
  void setMode(PositioningMode mode) {
    if (_currentMode == mode) return;
    
    final oldMode = _currentMode;
    _currentMode = mode;
    
    _logEvent('MODE_SWITCH', 'Changed from ${oldMode.name} to ${mode.name}');
    
    // Reset correction count on mode change
    _correctionCount = 0;
  }
  
  /// Check if too many corrections, suggest manual mode
  void _checkCorrectionThreshold() {
    // Reset counter if enough time has passed
    if (DateTime.now().difference(_lastCorrectionTime) > correctionResetDuration) {
      _correctionCount = 0;
      return;
    }
    
    if (_correctionCount >= maxCorrectionsBeforeSuggestManual) {
      _logEvent('SUGGEST_MANUAL', 
        'Multiple corrections needed. Consider switching to Manual mode.');
      _correctionCount = 0; // Reset to avoid spam
    }
  }
  
  /// Auto-switch to assisted mode if sensors unstable
  void handleSensorInstability() {
    if (_currentMode == PositioningMode.SMART) {
      setMode(PositioningMode.ASSISTED);
      _logEvent('AUTO_SWITCH', 'Sensors unstable, switched to Assisted mode');
    }
  }
  
  // ===========================================================================
  // QR CHECKPOINT RESET
  // ===========================================================================
  
  /// Reset position from QR scan (hard reset)
  void resetFromQR({
    required Node scannedNode,
    double? heading,
  }) {
    _fusion.updateFromQR(
      scannedNode: scannedNode,
      heading: heading,
    );
    
    _lastPosition = _fusion.currentPosition;
    _lastStepCount = _sensors.getStepCount();
    _correctionCount = 0;
    
    _logEvent('QR_RESET', 'Position synced to ${scannedNode.label ?? scannedNode.id}');
  }
  
  // ===========================================================================
  // VISUAL LANDMARK RESET
  // ===========================================================================
  
  /// Reset position from visual landmark
  void resetFromVisualLandmark({
    required Node landmarkNode,
    required double confidenceScore,
  }) {
    if (confidenceScore < 0.8) {
      _logEvent('LANDMARK_REJECTED', 
        'Visual match confidence too low: ${(confidenceScore * 100).toStringAsFixed(0)}%');
      return;
    }
    
    _fusion.updateFromVisualLandmark(
      landmarkNode: landmarkNode,
      confidenceScore: confidenceScore,
    );
    
    _lastPosition = _fusion.currentPosition;
    
    _logEvent('LANDMARK_RESET', 
      'Position synced to ${landmarkNode.label ?? landmarkNode.id} (${(confidenceScore * 100).toStringAsFixed(0)}% confidence)');
  }
  
  // ===========================================================================
  // MANUAL OVERRIDE
  // ===========================================================================
  
  /// Manually set position
  void setManualPosition({
    required double x,
    required double y,
    required String floorId,
    double? heading,
  }) {
    _fusion.updateFromManual(
      x: x,
      y: y,
      floorId: floorId,
      heading: heading,
    );
    
    _lastPosition = _fusion.currentPosition;
    _lastStepCount = _sensors.getStepCount();
    
    _logEvent('MANUAL_OVERRIDE', 'Position manually set');
  }
  
  /// Manually change floor
  void changeFloor(String newFloorId) {
    if (_lastPosition == null) return;
    
    _fusion.updateFromManual(
      x: _lastPosition!.x,
      y: _lastPosition!.y,
      floorId: newFloorId,
      heading: _lastPosition!.heading,
    );
    
    _lastPosition = _fusion.currentPosition;
    
    _logEvent('FLOOR_CHANGE', 'Floor changed to $newFloorId');
  }
  
  // ===========================================================================
  // LOGGING
  // ===========================================================================
  
  void _logEvent(String type, String message, {Map<String, dynamic>? data}) {
    final event = PositioningEvent(
      type: type,
      message: message,
      data: data,
    );
    
    _eventController.add(event);
    print('📍 $event');
  }
  
  // ===========================================================================
  // RESOURCE MANAGEMENT
  // ===========================================================================
  
  void dispose() {
    _stepSubscription?.cancel();
    _walkingStateSubscription?.cancel();
    _eventController.close();
  }
}

import 'dart:math' show atan2, pi;
