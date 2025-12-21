/// CampusNav - Sensor Service
///
/// Abstract service for sensor-based movement tracking.
/// This provides an interface for accelerometer and gyroscope data
/// to track user movement in indoor environments.

// =============================================================================
// SENSOR DATA MODELS
// =============================================================================

/// Represents accelerometer reading
class AccelerometerData {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  AccelerometerData({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  /// Calculate magnitude of acceleration
  double get magnitude => (x * x + y * y + z * z);
}

/// Represents gyroscope reading
class GyroscopeData {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  GyroscopeData({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });
}

// =============================================================================
// SENSOR SERVICE INTERFACE
// =============================================================================

/// Abstract interface for sensor operations
abstract class SensorService {
  /// Start listening to sensor updates
  Future<void> startListening();

  /// Stop listening to sensor updates
  Future<void> stopListening();

  /// Get stream of accelerometer data
  Stream<AccelerometerData> get accelerometerStream;

  /// Get stream of gyroscope data
  Stream<GyroscopeData> get gyroscopeStream;

  /// Detect if user has taken a step
  bool detectStep(AccelerometerData data);

  /// Get current heading/orientation
  double getCurrentHeading();
}

// =============================================================================
// MOCK SENSOR SERVICE (for testing/demo)
// =============================================================================

/// Mock implementation for testing without real sensors
class MockSensorService implements SensorService {
  double _currentHeading = 0.0;

  @override
  Future<void> startListening() async {
    // TODO: Implement actual sensor listening
  }

  @override
  Future<void> stopListening() async {
    // TODO: Implement sensor cleanup
  }

  @override
  Stream<AccelerometerData> get accelerometerStream => Stream.empty();

  @override
  Stream<GyroscopeData> get gyroscopeStream => Stream.empty();

  @override
  bool detectStep(AccelerometerData data) {
    // Simplified step detection - check for acceleration spike
    return data.magnitude > 12.0;
  }

  @override
  double getCurrentHeading() => _currentHeading;

  /// Update heading for testing
  void setHeading(double heading) {
    _currentHeading = heading;
  }
}
