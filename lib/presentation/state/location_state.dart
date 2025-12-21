/// CampusNav - Location State
///
/// State management for current user location.

import 'package:flutter/foundation.dart';
import '../../core/services/qr_service.dart';
import '../../domain/entities/location.dart';

// =============================================================================
// LOCATION STATE
// =============================================================================

class LocationStateManager extends ChangeNotifier {
  double? _currentX;
  double? _currentY;
  String? _currentFloorId;
  String? _currentBuildingId;
  Location? _currentLocation;
  double _heading = 0.0;
  bool _isLocationSet = false;
  DateTime? _lastUpdated;

  // Getters
  double? get currentX => _currentX;
  double? get currentY => _currentY;
  String? get currentFloorId => _currentFloorId;
  String? get currentBuildingId => _currentBuildingId;
  Location? get currentLocation => _currentLocation;
  double get heading => _heading;
  bool get isLocationSet => _isLocationSet;
  DateTime? get lastUpdated => _lastUpdated;

  /// Set location from QR code scan
  void setLocationFromQr(QrLocationData qrData) {
    _currentX = qrData.x;
    _currentY = qrData.y;
    _currentFloorId = qrData.floorId;
    _currentBuildingId = qrData.buildingId;
    _isLocationSet = true;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Update position from sensor data
  void updatePosition({
    required double x,
    required double y,
    double? heading,
  }) {
    _currentX = x;
    _currentY = y;
    if (heading != null) {
      _heading = heading;
    }
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Set floor (e.g., after using stairs/elevator)
  void setFloor(String floorId) {
    _currentFloorId = floorId;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Set associated location
  void setCurrentLocation(Location location) {
    _currentLocation = location;
    notifyListeners();
  }

  /// Clear location (reset)
  void clearLocation() {
    _currentX = null;
    _currentY = null;
    _currentFloorId = null;
    _currentBuildingId = null;
    _currentLocation = null;
    _isLocationSet = false;
    _lastUpdated = null;
    notifyListeners();
  }

  /// Set demo/mock location
  void setDemoLocation() {
    _currentX = 100;
    _currentY = 300;
    _currentFloorId = 'main_floor_0';
    _currentBuildingId = 'main_building';
    _isLocationSet = true;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }
}
