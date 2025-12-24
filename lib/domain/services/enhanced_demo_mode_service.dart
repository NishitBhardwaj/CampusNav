/// CampusNav - Enhanced Demo Mode Service
///
/// PHASE 6: Guaranteed success for hackathon judging.
///
/// FEATURES:
/// - Virtual movement (no walking needed)
/// - Forced event triggers
/// - AI confidence indicators
/// - Purple "DEMO" label
/// - 100% success guarantee

import 'dart:async';
import '../entities/path.dart';
import '../entities/node.dart';
import '../services/movement_fusion_engine.dart';

// =============================================================================
// DEMO EVENT
// =============================================================================

enum DemoEventType {
  COMPASS_DRIFT,
  REROUTING_BLOCKAGE,
  QR_SCAN_SUCCESS,
  FLOOR_CHANGE,
  ARRIVAL,
}

class DemoEvent {
  final DemoEventType type;
  final String message;
  final DateTime timestamp;
  
  DemoEvent({
    required this.type,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// =============================================================================
// ENHANCED DEMO MODE SERVICE
// =============================================================================

class EnhancedDemoModeService {
  bool _isEnabled = false;
  bool _isSimulating = false;
  
  Path? _demoPath;
  int _currentStepIndex = 0;
  double _simulationSpeed = 1.0;
  Timer? _simulationTimer;
  
  final _eventController = StreamController<DemoEvent>.broadcast();
  final _positionController = StreamController<FusedPosition>.broadcast();
  
  Stream<DemoEvent> get eventStream => _eventController.stream;
  Stream<FusedPosition> get positionStream => _positionController.stream;
  
  bool get isEnabled => _isEnabled;
  bool get isSimulating => _isSimulating;
  double get progress => _demoPath == null ? 0.0 : _currentStepIndex / _demoPath!.nodes.length;
  
  // ===========================================================================
  // DEMO MODE CONTROL
  // ===========================================================================
  
  /// Enable demo judge mode
  void enableDemoMode() {
    _isEnabled = true;
    print('🎭 Demo Judge Mode ENABLED');
  }
  
  /// Disable demo mode
  void disableDemoMode() {
    _isEnabled = false;
    stopSimulation();
    print('🎭 Demo Judge Mode DISABLED');
  }
  
  /// Toggle demo mode
  void toggleDemoMode() {
    if (_isEnabled) {
      disableDemoMode();
    } else {
      enableDemoMode();
    }
  }
  
  // ===========================================================================
  // VIRTUAL MOVEMENT SIMULATION
  // ===========================================================================
  
  /// Start virtual movement simulation
  void startSimulation(Path path) {
    if (!_isEnabled) {
      print('⚠️ Demo mode not enabled');
      return;
    }
    
    _demoPath = path;
    _currentStepIndex = 0;
    _isSimulating = true;
    
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(
      Duration(milliseconds: (1000 / _simulationSpeed).round()),
      (_) => _simulateStep(),
    );
    
    print('🎭 Demo simulation started');
  }
  
  /// Stop simulation
  void stopSimulation() {
    _simulationTimer?.cancel();
    _isSimulating = false;
    _currentStepIndex = 0;
    print('🎭 Demo simulation stopped');
  }
  
  /// Pause simulation
  void pauseSimulation() {
    _simulationTimer?.cancel();
    _isSimulating = false;
  }
  
  /// Resume simulation
  void resumeSimulation() {
    if (_demoPath == null) return;
    
    _isSimulating = true;
    _simulationTimer = Timer.periodic(
      Duration(milliseconds: (1000 / _simulationSpeed).round()),
      (_) => _simulateStep(),
    );
  }
  
  /// Set simulation speed
  void setSpeed(double speed) {
    _simulationSpeed = speed.clamp(0.5, 5.0);
    
    if (_isSimulating) {
      pauseSimulation();
      resumeSimulation();
    }
  }
  
  /// Simulate one step
  void _simulateStep() {
    if (_demoPath == null || _currentStepIndex >= _demoPath!.nodes.length) {
      stopSimulation();
      _triggerEvent(DemoEventType.ARRIVAL, 'Destination reached!');
      return;
    }
    
    final node = _demoPath!.nodes[_currentStepIndex];
    
    // Emit position update
    final position = FusedPosition(
      x: node.x,
      y: node.y,
      floorId: node.floorId,
      heading: 0.0, // TODO: Calculate from next node
      confidence: PositioningConfidence.HIGH,
      source: PositioningSource.DEMO_MODE,
    );
    
    _positionController.add(position);
    
    _currentStepIndex++;
  }
  
  /// Jump to specific progress
  void jumpToProgress(double progress) {
    if (_demoPath == null) return;
    
    _currentStepIndex = (progress * _demoPath!.nodes.length).round();
    _currentStepIndex = _currentStepIndex.clamp(0, _demoPath!.nodes.length - 1);
  }
  
  // ===========================================================================
  // FORCED EVENT TRIGGERS
  // ===========================================================================
  
  /// Trigger compass drift event
  void triggerCompassDrift() {
    _triggerEvent(
      DemoEventType.COMPASS_DRIFT,
      'Compass drift detected - snapping to corridor',
    );
  }
  
  /// Trigger rerouting event
  void triggerRerouting() {
    _triggerEvent(
      DemoEventType.REROUTING_BLOCKAGE,
      'Path blocked - calculating alternative route',
    );
  }
  
  /// Trigger QR scan success
  void triggerQRScan() {
    _triggerEvent(
      DemoEventType.QR_SCAN_SUCCESS,
      'Location synced via QR code',
    );
  }
  
  /// Trigger floor change
  void triggerFloorChange() {
    _triggerEvent(
      DemoEventType.FLOOR_CHANGE,
      'Floor change detected - confirm stairs taken',
    );
  }
  
  /// Internal event trigger
  void _triggerEvent(DemoEventType type, String message) {
    final event = DemoEvent(type: type, message: message);
    _eventController.add(event);
    print('🎭 Demo event: $message');
  }
  
  // ===========================================================================
  // PRELOADED MOCK ROUTES
  // ===========================================================================
  
  /// Get preloaded demo route
  Path? getPreloadedRoute(String routeName) {
    // TODO: Load from mock data
    // For now, return null
    return null;
  }
  
  /// List available demo routes
  List<String> getAvailableRoutes() {
    return [
      'Main Entrance to Dean Office',
      'Library to Cafeteria',
      'Lab Block to Auditorium',
    ];
  }
  
  // ===========================================================================
  // RESOURCE MANAGEMENT
  // ===========================================================================
  
  void dispose() {
    _simulationTimer?.cancel();
    _eventController.close();
    _positionController.close();
  }
}
