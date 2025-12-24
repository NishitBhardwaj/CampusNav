/// CampusNav - Demo Mode Service
///
/// PHASE 2: Demo-safe navigation simulation for hackathon presentations.
///
/// WHY DEMO MODE IS CRITICAL:
/// - Live sensor data is UNPREDICTABLE during presentations
/// - Judges need to see the app work PERFECTLY
/// - No time to debug sensor issues on stage
/// - Simulated movement is RELIABLE and REPEATABLE
///
/// DEMO MODE FEATURES:
/// - Simulated smooth movement along calculated path
/// - No sensor dependencies
/// - Adjustable speed for presentation
/// - Can pause/resume at any point
/// - Perfect for screenshots and videos

import 'dart:async';
import '../entities/node.dart';
import '../entities/path.dart';

// =============================================================================
// DEMO MODE SERVICE
// =============================================================================

class DemoModeService {
  bool _isDemoMode = false;
  bool _isSimulating = false;
  Timer? _simulationTimer;
  
  Path? _currentPath;
  int _currentNodeIndex = 0;
  double _progressOnEdge = 0.0; // 0.0 to 1.0
  
  /// Speed multiplier for demo (1.0 = normal walking speed ~1.4 m/s)
  double _speedMultiplier = 2.0;
  
  /// Update interval in milliseconds
  static const int updateIntervalMs = 100;

  // Stream for position updates
  final _positionController = StreamController<DemoPosition>.broadcast();
  Stream<DemoPosition> get positionStream => _positionController.stream;

  // Getters
  bool get isDemoMode => _isDemoMode;
  bool get isSimulating => _isSimulating;
  double get speedMultiplier => _speedMultiplier;
  double get progress => _currentPath == null ? 0.0 : _currentNodeIndex / _currentPath!.nodes.length;

  // ===========================================================================
  // DEMO MODE CONTROL
  // ===========================================================================

  /// Enable demo mode
  void enableDemoMode() {
    _isDemoMode = true;
  }

  /// Disable demo mode
  void disableDemoMode() {
    _isDemoMode = false;
    stopSimulation();
  }

  /// Toggle demo mode
  void toggleDemoMode() {
    _isDemoMode = !_isDemoMode;
    if (!_isDemoMode) {
      stopSimulation();
    }
  }

  /// Set simulation speed (1.0 = normal, 2.0 = 2x faster, etc.)
  void setSpeed(double multiplier) {
    _speedMultiplier = multiplier.clamp(0.5, 5.0);
  }

  // ===========================================================================
  // SIMULATION CONTROL
  // ===========================================================================

  /// Start simulating movement along a path
  void startSimulation(Path path) {
    if (!_isDemoMode) return;
    
    _currentPath = path;
    _currentNodeIndex = 0;
    _progressOnEdge = 0.0;
    _isSimulating = true;

    // Start simulation timer
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(
      Duration(milliseconds: updateIntervalMs),
      _onSimulationTick,
    );

    // Emit initial position
    _emitCurrentPosition();
  }

  /// Pause simulation
  void pauseSimulation() {
    _isSimulating = false;
    _simulationTimer?.cancel();
  }

  /// Resume simulation
  void resumeSimulation() {
    if (!_isDemoMode || _currentPath == null) return;
    
    _isSimulating = true;
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(
      Duration(milliseconds: updateIntervalMs),
      _onSimulationTick,
    );
  }

  /// Stop simulation
  void stopSimulation() {
    _isSimulating = false;
    _simulationTimer?.cancel();
    _currentPath = null;
    _currentNodeIndex = 0;
    _progressOnEdge = 0.0;
  }

  /// Jump to specific progress (0.0 to 1.0)
  void jumpToProgress(double progress) {
    if (_currentPath == null) return;
    
    final targetIndex = (progress * (_currentPath!.nodes.length - 1)).floor();
    _currentNodeIndex = targetIndex.clamp(0, _currentPath!.nodes.length - 1);
    _progressOnEdge = 0.0;
    
    _emitCurrentPosition();
  }

  // ===========================================================================
  // SIMULATION LOGIC
  // ===========================================================================

  /// Called on each simulation tick
  void _onSimulationTick(Timer timer) {
    if (!_isSimulating || _currentPath == null) {
      timer.cancel();
      return;
    }

    final nodes = _currentPath!.nodes;
    if (_currentNodeIndex >= nodes.length - 1) {
      // Reached destination
      stopSimulation();
      _emitCurrentPosition(arrived: true);
      return;
    }

    // Calculate movement increment
    // Normal walking speed ~1.4 m/s, update every 100ms = 0.14m per tick
    const baseSpeed = 0.14; // meters per tick
    final speed = baseSpeed * _speedMultiplier;

    // Get current edge
    final currentNode = nodes[_currentNodeIndex];
    final nextNode = nodes[_currentNodeIndex + 1];
    
    final dx = nextNode.x - currentNode.x;
    final dy = nextNode.y - currentNode.y;
    final edgeLength = (dx * dx + dy * dy);

    if (edgeLength == 0) {
      // Nodes are at same position, skip to next
      _currentNodeIndex++;
      _progressOnEdge = 0.0;
      _emitCurrentPosition();
      return;
    }

    // Increment progress
    final progressIncrement = speed / edgeLength;
    _progressOnEdge += progressIncrement;

    if (_progressOnEdge >= 1.0) {
      // Reached next node
      _currentNodeIndex++;
      _progressOnEdge = 0.0;
    }

    _emitCurrentPosition();
  }

  /// Emit current interpolated position
  void _emitCurrentPosition({bool arrived = false}) {
    if (_currentPath == null) return;

    final nodes = _currentPath!.nodes;
    if (_currentNodeIndex >= nodes.length) return;

    final currentNode = nodes[_currentNodeIndex];
    
    if (_currentNodeIndex >= nodes.length - 1 || arrived) {
      // At destination
      _positionController.add(DemoPosition(
        x: currentNode.x,
        y: currentNode.y,
        floorId: currentNode.floorId,
        heading: 0,
        nodeIndex: _currentNodeIndex,
        progress: 1.0,
        arrived: true,
      ));
      return;
    }

    final nextNode = nodes[_currentNodeIndex + 1];

    // Interpolate position
    final x = currentNode.x + (nextNode.x - currentNode.x) * _progressOnEdge;
    final y = currentNode.y + (nextNode.y - currentNode.y) * _progressOnEdge;

    // Calculate heading
    final dx = nextNode.x - currentNode.x;
    final dy = nextNode.y - currentNode.y;
    final heading = _calculateHeading(dx, dy);

    _positionController.add(DemoPosition(
      x: x,
      y: y,
      floorId: currentNode.floorId,
      heading: heading,
      nodeIndex: _currentNodeIndex,
      progress: _progressOnEdge,
      arrived: false,
    ));
  }

  /// Calculate heading from delta x and y
  double _calculateHeading(double dx, double dy) {
    final radians = atan2(dx, dy);
    final degrees = radians * 180 / 3.14159;
    return (degrees + 360) % 360;
  }

  /// Clean up resources
  void dispose() {
    _simulationTimer?.cancel();
    _positionController.close();
  }
}

// =============================================================================
// DEMO POSITION MODEL
// =============================================================================

class DemoPosition {
  final double x;
  final double y;
  final String floorId;
  final double heading;
  final int nodeIndex;
  final double progress; // 0.0 to 1.0 on current edge
  final bool arrived;

  DemoPosition({
    required this.x,
    required this.y,
    required this.floorId,
    required this.heading,
    required this.nodeIndex,
    required this.progress,
    this.arrived = false,
  });

  @override
  String toString() => 'DemoPosition($x, $y) on $floorId, heading: ${heading.toStringAsFixed(0)}°, node: $nodeIndex, progress: ${(progress * 100).toStringAsFixed(0)}%';
}

// Import for atan2
import 'dart:math' show atan2;
