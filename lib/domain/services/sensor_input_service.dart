/// CampusNav - Sensor Input Service
///
/// PHASE 3: Abstraction layer for device sensors.
///
/// WHY ABSTRACTION:
/// - Raw sensor data is noisy and unreliable
/// - Different devices behave differently
/// - We need stable, predictable interface
/// - Allows easy mocking for testing
///
/// SENSORS USED:
/// - Accelerometer → Step counting
/// - Magnetometer → Compass heading
/// - Gyroscope → Device tilt
/// - Activity Recognition → Walking state
///
/// CRITICAL PRINCIPLE:
/// We are NOT building perfect indoor GPS.
/// We are building "best possible with graceful degradation".

import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// =============================================================================
// SENSOR CONFIDENCE LEVELS
// =============================================================================

enum SensorConfidence {
  HIGH,    // Sensor data reliable, use normally
  MEDIUM,  // Sensor data questionable, apply heavy filtering
  LOW,     // Sensor data unreliable, use fallback
}

enum WalkingState {
  WALKING,   // User is moving
  STILL,     // User is stationary
  UNKNOWN,   // Cannot determine
}

// =============================================================================
// SENSOR INPUT SERVICE
// =============================================================================

class SensorInputService {
  // Sensor streams
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  
  // Current sensor state
  int _stepCount = 0;
  double _compassHeading = 0.0; // 0-360 degrees, 0 = North
  double _deviceTilt = 0.0; // 0-90 degrees
  WalkingState _walkingState = WalkingState.UNKNOWN;
  SensorConfidence _headingConfidence = SensorConfidence.MEDIUM;
  
  // Step detection state
  double _lastAccelMagnitude = 0.0;
  DateTime _lastStepTime = DateTime.now();
  static const double stepThreshold = 12.0; // Acceleration threshold
  static const int minStepIntervalMs = 300; // Min time between steps
  
  // Heading smoothing
  final List<double> _headingHistory = [];
  static const int headingHistorySize = 5;
  
  // Tilt detection
  bool _isDeviceTilted = false;
  
  // Permissions
  bool _hasPermissions = false;
  
  // Stream controllers
  final _stepController = StreamController<int>.broadcast();
  final _headingController = StreamController<double>.broadcast();
  final _walkingStateController = StreamController<WalkingState>.broadcast();
  
  // Getters
  int get stepCount => _stepCount;
  double get compassHeading => _compassHeading;
  double get deviceTilt => _deviceTilt;
  WalkingState get walkingState => _walkingState;
  SensorConfidence get headingConfidence => _headingConfidence;
  bool get isDeviceTilted => _isDeviceTilted;
  bool get hasPermissions => _hasPermissions;
  
  Stream<int> get stepStream => _stepController.stream;
  Stream<double> get headingStream => _headingController.stream;
  Stream<WalkingState> get walkingStateStream => _walkingStateController.stream;
  
  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================
  
  /// Initialize sensor service and request permissions
  Future<bool> initialize() async {
    // Request sensor permissions
    _hasPermissions = await _requestPermissions();
    
    if (!_hasPermissions) {
      print('⚠️ Sensor permissions denied. Using fallback mode.');
      return false;
    }
    
    // Start listening to sensors
    _startAccelerometer();
    _startMagnetometer();
    _startGyroscope();
    
    print('✅ Sensor service initialized');
    return true;
  }
  
  /// Request necessary permissions
  Future<bool> _requestPermissions() async {
    // Note: sensors_plus doesn't require explicit permissions on most platforms
    // but we check activity recognition if available
    final status = await Permission.sensors.request();
    return status.isGranted || status.isLimited;
  }
  
  // ===========================================================================
  // STEP COUNTING (ACCELEROMETER)
  // ===========================================================================
  
  /// Start accelerometer for step detection
  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      _processAccelerometerData(event);
    });
  }
  
  /// Process accelerometer data for step detection
  /// 
  /// ALGORITHM:
  /// 1. Calculate magnitude of acceleration vector
  /// 2. Detect peaks above threshold
  /// 3. Debounce to prevent double-counting
  /// 4. Update walking state
  void _processAccelerometerData(AccelerometerEvent event) {
    // Calculate magnitude of acceleration
    final magnitude = sqrt(
      event.x * event.x + 
      event.y * event.y + 
      event.z * event.z
    );
    
    // Detect step (peak detection)
    final now = DateTime.now();
    final timeSinceLastStep = now.difference(_lastStepTime).inMilliseconds;
    
    if (magnitude > stepThreshold && 
        _lastAccelMagnitude < stepThreshold &&
        timeSinceLastStep > minStepIntervalMs) {
      // Step detected!
      _stepCount++;
      _lastStepTime = now;
      _stepController.add(_stepCount);
      
      // Update walking state
      _updateWalkingState(true);
    }
    
    _lastAccelMagnitude = magnitude;
    
    // Check if user is still (no significant movement for 2 seconds)
    if (timeSinceLastStep > 2000) {
      _updateWalkingState(false);
    }
  }
  
  /// Get current step count
  int getStepCount() => _stepCount;
  
  /// Reset step counter
  void resetStepCount() {
    _stepCount = 0;
    _stepController.add(_stepCount);
  }
  
  // ===========================================================================
  // COMPASS HEADING (MAGNETOMETER)
  // ===========================================================================
  
  /// Start magnetometer for compass heading
  void _startMagnetometer() {
    _magnetometerSubscription = magnetometerEvents.listen((event) {
      _processMagnetometerData(event);
    });
  }
  
  /// Process magnetometer data for heading
  /// 
  /// IMPORTANT: Indoor compass is UNRELIABLE
  /// - Metal structures interfere
  /// - Electronic devices cause drift
  /// - We apply heavy smoothing and confidence scoring
  void _processMagnetometerData(MagnetometerEvent event) {
    // Calculate heading from magnetometer
    // atan2(y, x) gives angle from East, we want from North
    final rawHeading = atan2(event.y, event.x) * 180 / pi;
    final normalizedHeading = (rawHeading + 360) % 360;
    
    // Add to history for smoothing
    _headingHistory.add(normalizedHeading);
    if (_headingHistory.length > headingHistorySize) {
      _headingHistory.removeAt(0);
    }
    
    // Calculate smoothed heading (weighted average)
    _compassHeading = _calculateSmoothedHeading();
    _headingController.add(_compassHeading);
    
    // Update confidence based on variance
    _updateHeadingConfidence();
  }
  
  /// Calculate smoothed heading using weighted average
  double _calculateSmoothedHeading() {
    if (_headingHistory.isEmpty) return 0.0;
    
    // Weighted average (more recent = higher weight)
    double sum = 0.0;
    double weightSum = 0.0;
    
    for (int i = 0; i < _headingHistory.length; i++) {
      final weight = (i + 1).toDouble(); // Linear weighting
      sum += _headingHistory[i] * weight;
      weightSum += weight;
    }
    
    return sum / weightSum;
  }
  
  /// Update heading confidence based on variance
  void _updateHeadingConfidence() {
    if (_headingHistory.length < 3) {
      _headingConfidence = SensorConfidence.LOW;
      return;
    }
    
    // Calculate variance
    final mean = _headingHistory.reduce((a, b) => a + b) / _headingHistory.length;
    final variance = _headingHistory
        .map((h) => (h - mean) * (h - mean))
        .reduce((a, b) => a + b) / _headingHistory.length;
    
    // Set confidence based on variance
    if (variance < 100) {
      _headingConfidence = SensorConfidence.HIGH;
    } else if (variance < 500) {
      _headingConfidence = SensorConfidence.MEDIUM;
    } else {
      _headingConfidence = SensorConfidence.LOW;
    }
    
    // If device is tilted, reduce confidence
    if (_isDeviceTilted) {
      _headingConfidence = SensorConfidence.LOW;
    }
  }
  
  /// Get current compass heading (0-360, 0 = North)
  double getCompassHeading() => _compassHeading;
  
  /// Get heading confidence level
  SensorConfidence getHeadingConfidence() => _headingConfidence;
  
  // ===========================================================================
  // DEVICE TILT (GYROSCOPE)
  // ===========================================================================
  
  /// Start gyroscope for tilt detection
  void _startGyroscope() {
    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
      _processGyroscopeData(event);
    });
  }
  
  /// Process gyroscope data for tilt detection
  /// 
  /// If device is tilted > 45°, compass becomes unreliable
  void _processGyroscopeData(GyroscopeEvent event) {
    // Calculate approximate tilt from gyroscope
    // This is simplified - in production would use sensor fusion
    final tiltMagnitude = sqrt(
      event.x * event.x + 
      event.y * event.y
    );
    
    _deviceTilt = tiltMagnitude * 180 / pi; // Convert to degrees
    _isDeviceTilted = _deviceTilt > 45.0;
    
    // Update heading confidence if tilted
    if (_isDeviceTilted) {
      _headingConfidence = SensorConfidence.LOW;
    }
  }
  
  /// Get current device tilt angle (degrees)
  double getDeviceTiltAngle() => _deviceTilt;
  
  // ===========================================================================
  // WALKING STATE
  // ===========================================================================
  
  /// Update walking state based on step detection
  void _updateWalkingState(bool isWalking) {
    final newState = isWalking ? WalkingState.WALKING : WalkingState.STILL;
    
    if (newState != _walkingState) {
      _walkingState = newState;
      _walkingStateController.add(_walkingState);
    }
  }
  
  /// Get current walking state
  WalkingState getWalkingState() => _walkingState;
  
  /// Manually set walking state (for testing/demo)
  void setWalkingState(WalkingState state) {
    _walkingState = state;
    _walkingStateController.add(_walkingState);
  }
  
  // ===========================================================================
  // RESOURCE MANAGEMENT
  // ===========================================================================
  
  /// Stop all sensor listeners
  void dispose() {
    _accelerometerSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    
    _stepController.close();
    _headingController.close();
    _walkingStateController.close();
  }
  
  /// Pause sensor listening (battery saving)
  void pause() {
    _accelerometerSubscription?.pause();
    _magnetometerSubscription?.pause();
    _gyroscopeSubscription?.pause();
  }
  
  /// Resume sensor listening
  void resume() {
    _accelerometerSubscription?.resume();
    _magnetometerSubscription?.resume();
    _gyroscopeSubscription?.resume();
  }
}
