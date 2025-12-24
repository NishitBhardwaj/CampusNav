/// CampusNav - Global State Providers
///
/// PHASE 4: Riverpod providers for app-wide state management.
///
/// PROVIDERS:
/// - NavigationStateProvider - Current navigation state
/// - SensorStatusProvider - Sensor health status
/// - UserRoleProvider - User/Admin role
/// - UIConfidenceProvider - Positioning confidence for UI

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/path.dart';
import '../../domain/navigation/navigation_engine.dart';
import '../../domain/services/sensor_input_service.dart';
import '../../domain/services/movement_fusion_engine.dart';
import '../../domain/services/positioning_manager.dart';

// =============================================================================
// NAVIGATION STATE
// =============================================================================

class NavigationState {
  final NavigationStatus status;
  final Path? currentPath;
  final int currentStepIndex;
  final String? destinationName;
  final bool isDemoMode;
  
  NavigationState({
    this.status = NavigationStatus.idle,
    this.currentPath,
    this.currentStepIndex = 0,
    this.destinationName,
    this.isDemoMode = false,
  });
  
  NavigationState copyWith({
    NavigationStatus? status,
    Path? currentPath,
    int? currentStepIndex,
    String? destinationName,
    bool? isDemoMode,
  }) {
    return NavigationState(
      status: status ?? this.status,
      currentPath: currentPath ?? this.currentPath,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      destinationName: destinationName ?? this.destinationName,
      isDemoMode: isDemoMode ?? this.isDemoMode,
    );
  }
}

class NavigationStateNotifier extends StateNotifier<NavigationState> {
  NavigationStateNotifier() : super(NavigationState());
  
  void updateStatus(NavigationStatus status) {
    state = state.copyWith(status: status);
  }
  
  void setPath(Path path, String destinationName) {
    state = state.copyWith(
      currentPath: path,
      destinationName: destinationName,
      status: NavigationStatus.navigating,
    );
  }
  
  void updateStepIndex(int index) {
    state = state.copyWith(currentStepIndex: index);
  }
  
  void toggleDemoMode() {
    state = state.copyWith(isDemoMode: !state.isDemoMode);
  }
  
  void reset() {
    state = NavigationState();
  }
}

final navigationStateProvider = StateNotifierProvider<NavigationStateNotifier, NavigationState>(
  (ref) => NavigationStateNotifier(),
);

// =============================================================================
// SENSOR STATUS
// =============================================================================

enum SensorHealth {
  HEALTHY,      // All sensors working
  DEGRADED,     // Some sensors unreliable
  FAILED,       // Sensors not working
  UNAVAILABLE,  // Sensors not initialized
}

class SensorStatus {
  final SensorHealth health;
  final SensorConfidence headingConfidence;
  final WalkingState walkingState;
  final bool isDeviceTilted;
  final String? statusMessage;
  
  SensorStatus({
    this.health = SensorHealth.UNAVAILABLE,
    this.headingConfidence = SensorConfidence.MEDIUM,
    this.walkingState = WalkingState.UNKNOWN,
    this.isDeviceTilted = false,
    this.statusMessage,
  });
  
  SensorStatus copyWith({
    SensorHealth? health,
    SensorConfidence? headingConfidence,
    WalkingState? walkingState,
    bool? isDeviceTilted,
    String? statusMessage,
  }) {
    return SensorStatus(
      health: health ?? this.health,
      headingConfidence: headingConfidence ?? this.headingConfidence,
      walkingState: walkingState ?? this.walkingState,
      isDeviceTilted: isDeviceTilted ?? this.isDeviceTilted,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class SensorStatusNotifier extends StateNotifier<SensorStatus> {
  SensorStatusNotifier() : super(SensorStatus());
  
  void updateFromSensors(SensorInputService sensors) {
    final headingConf = sensors.getHeadingConfidence();
    final walking = sensors.getWalkingState();
    final tilted = sensors.isDeviceTilted;
    
    // Determine overall health
    SensorHealth health;
    if (!sensors.hasPermissions) {
      health = SensorHealth.UNAVAILABLE;
    } else if (headingConf == SensorConfidence.LOW) {
      health = SensorHealth.FAILED;
    } else if (headingConf == SensorConfidence.MEDIUM || tilted) {
      health = SensorHealth.DEGRADED;
    } else {
      health = SensorHealth.HEALTHY;
    }
    
    state = SensorStatus(
      health: health,
      headingConfidence: headingConf,
      walkingState: walking,
      isDeviceTilted: tilted,
    );
  }
  
  void setStatusMessage(String message) {
    state = state.copyWith(statusMessage: message);
  }
  
  void clearStatusMessage() {
    state = state.copyWith(statusMessage: null);
  }
}

final sensorStatusProvider = StateNotifierProvider<SensorStatusNotifier, SensorStatus>(
  (ref) => SensorStatusNotifier(),
);

// =============================================================================
// USER ROLE
// =============================================================================

final userRoleProvider = StateProvider<Role>((ref) => Role.user);

// =============================================================================
// UI CONFIDENCE
// =============================================================================

class UIConfidence {
  final PositioningConfidence confidence;
  final int confidencePercent;
  final PositioningMode mode;
  final String currentFloor;
  
  UIConfidence({
    this.confidence = PositioningConfidence.MEDIUM,
    this.confidencePercent = 65,
    this.mode = PositioningMode.SMART,
    this.currentFloor = 'ground',
  });
  
  UIConfidence copyWith({
    PositioningConfidence? confidence,
    int? confidencePercent,
    PositioningMode? mode,
    String? currentFloor,
  }) {
    return UIConfidence(
      confidence: confidence ?? this.confidence,
      confidencePercent: confidencePercent ?? this.confidencePercent,
      mode: mode ?? this.mode,
      currentFloor: currentFloor ?? this.currentFloor,
    );
  }
}

class UIConfidenceNotifier extends StateNotifier<UIConfidence> {
  UIConfidenceNotifier() : super(UIConfidence());
  
  void updateFromFusion(FusedPosition? position, PositioningMode mode) {
    if (position == null) return;
    
    state = UIConfidence(
      confidence: position.confidence,
      confidencePercent: position.confidencePercent,
      mode: mode,
      currentFloor: position.floorId,
    );
  }
  
  void setMode(PositioningMode mode) {
    state = state.copyWith(mode: mode);
  }
  
  void setFloor(String floor) {
    state = state.copyWith(currentFloor: floor);
  }
}

final uiConfidenceProvider = StateNotifierProvider<UIConfidenceNotifier, UIConfidence>(
  (ref) => UIConfidenceNotifier(),
);

// =============================================================================
// DEMO MODE
// =============================================================================

final demoModeProvider = StateProvider<bool>((ref) => false);
