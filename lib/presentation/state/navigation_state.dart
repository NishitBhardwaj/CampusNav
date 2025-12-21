/// CampusNav - Navigation State
///
/// State management for navigation operations.
/// Uses ChangeNotifier for simple state management.

import 'package:flutter/foundation.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/path.dart';
import '../../domain/navigation/navigation_engine.dart';

// =============================================================================
// NAVIGATION STATE
// =============================================================================

class NavigationStateManager extends ChangeNotifier {
  final NavigationEngine _engine;

  NavigationStatus _status = NavigationStatus.idle;
  Path? _currentPath;
  Location? _origin;
  Location? _destination;
  String? _currentInstruction;
  double _progress = 0.0;
  String? _errorMessage;

  NavigationStateManager(this._engine);

  // Getters
  NavigationStatus get status => _status;
  Path? get currentPath => _currentPath;
  Location? get origin => _origin;
  Location? get destination => _destination;
  String? get currentInstruction => _currentInstruction;
  double get progress => _progress;
  String? get errorMessage => _errorMessage;
  bool get isNavigating => _status == NavigationStatus.navigating;
  bool get hasArrived => _status == NavigationStatus.arrived;

  /// Start navigation from origin to destination
  Future<bool> startNavigation({
    required double fromX,
    required double fromY,
    required String fromFloorId,
    required Location toLocation,
  }) async {
    _status = NavigationStatus.calculating;
    _destination = toLocation;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = CurrentPosition(
        x: fromX,
        y: fromY,
        floorId: fromFloorId,
      );

      _currentPath = await _engine.startNavigation(
        from: position,
        to: toLocation,
      );

      if (_currentPath == null || !_currentPath!.isValid) {
        _status = NavigationStatus.error;
        _errorMessage = 'Could not find a path to the destination';
        notifyListeners();
        return false;
      }

      _status = NavigationStatus.navigating;
      _updateInstruction();
      notifyListeners();
      return true;
    } catch (e) {
      _status = NavigationStatus.error;
      _errorMessage = 'Navigation error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update current position during navigation
  void updatePosition(double x, double y, String floorId) {
    if (_status != NavigationStatus.navigating) return;

    _engine.updatePosition(CurrentPosition(
      x: x,
      y: y,
      floorId: floorId,
    ));

    _status = _engine.status;

    if (_status == NavigationStatus.arrived) {
      _progress = 1.0;
    } else {
      // Calculate progress
      _updateProgress(x, y);
      _updateInstruction();
    }

    notifyListeners();
  }

  /// Update navigation instruction
  void _updateInstruction() {
    final instruction = _engine.getCurrentInstruction();
    if (instruction != null) {
      _currentInstruction = instruction.text;
    }
  }

  /// Calculate navigation progress
  void _updateProgress(double x, double y) {
    if (_currentPath == null || _currentPath!.nodes.isEmpty) return;

    final dest = _currentPath!.destination;
    if (dest == null) return;

    final origin = _currentPath!.origin;
    if (origin == null) return;

    // Simple progress calculation based on distance
    final totalDist = _distance(origin.x, origin.y, dest.x, dest.y);
    final remainingDist = _distance(x, y, dest.x, dest.y);

    if (totalDist > 0) {
      _progress = 1.0 - (remainingDist / totalDist);
      _progress = _progress.clamp(0.0, 1.0);
    }
  }

  double _distance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return (dx * dx + dy * dy);
  }

  /// Stop current navigation
  void stopNavigation() {
    _engine.stopNavigation();
    _status = NavigationStatus.idle;
    _currentPath = null;
    _destination = null;
    _progress = 0.0;
    _currentInstruction = null;
    notifyListeners();
  }

  /// Recalculate route
  Future<void> recalculateRoute() async {
    _status = NavigationStatus.rerouting;
    notifyListeners();

    _currentPath = await _engine.recalculateRoute();

    if (_currentPath == null) {
      _status = NavigationStatus.error;
      _errorMessage = 'Could not recalculate route';
    } else {
      _status = NavigationStatus.navigating;
      _updateInstruction();
    }

    notifyListeners();
  }
}
