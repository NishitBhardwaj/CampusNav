/// CampusNav - System Health Monitor
///
/// PHASE 6: Global monitoring for crash prevention.
///
/// MONITORS:
/// - Sensor reliability
/// - State consistency
/// - Path validity
/// - Storage health
///
/// ON FAILURE: Auto-fallback to safe mode

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/sensor_input_service.dart';
import '../domain/navigation/navigation_engine.dart';
import '../core/services/backup_restore_service.dart';

// =============================================================================
// SYSTEM HEALTH STATUS
// =============================================================================

enum SystemHealth {
  HEALTHY,      // All systems operational
  DEGRADED,     // Some issues, can continue
  CRITICAL,     // Major issues, fallback required
  SAFE_MODE,    // Running in safe mode
}

class SystemHealthStatus {
  final SystemHealth overall;
  final bool sensorsHealthy;
  final bool navigationHealthy;
  final bool storageHealthy;
  final List<String> issues;
  final DateTime lastCheck;
  
  SystemHealthStatus({
    required this.overall,
    required this.sensorsHealthy,
    required this.navigationHealthy,
    required this.storageHealthy,
    required this.issues,
    DateTime? lastCheck,
  }) : lastCheck = lastCheck ?? DateTime.now();
  
  bool get isHealthy => overall == SystemHealth.HEALTHY;
  bool get needsFallback => overall == SystemHealth.CRITICAL;
}

// =============================================================================
// SYSTEM HEALTH MONITOR
// =============================================================================

class SystemHealthMonitor {
  final SensorInputService? _sensors;
  final NavigationEngine? _navigationEngine;
  final BackupRestoreService? _backupService;
  
  Timer? _monitorTimer;
  SystemHealthStatus _currentStatus = SystemHealthStatus(
    overall: SystemHealth.HEALTHY,
    sensorsHealthy: true,
    navigationHealthy: true,
    storageHealthy: true,
    issues: [],
  );
  
  final _statusController = StreamController<SystemHealthStatus>.broadcast();
  Stream<SystemHealthStatus> get statusStream => _statusController.stream;
  
  SystemHealthMonitor({
    SensorInputService? sensors,
    NavigationEngine? navigationEngine,
    BackupRestoreService? backupService,
  }) : _sensors = sensors,
       _navigationEngine = navigationEngine,
       _backupService = backupService;
  
  SystemHealthStatus get currentStatus => _currentStatus;
  
  // ===========================================================================
  // MONITORING
  // ===========================================================================
  
  /// Start continuous monitoring
  void startMonitoring({Duration interval = const Duration(seconds: 5)}) {
    _monitorTimer?.cancel();
    
    _monitorTimer = Timer.periodic(interval, (_) {
      checkSystemHealth();
    });
    
    print('🔍 System health monitoring started');
  }
  
  /// Stop monitoring
  void stopMonitoring() {
    _monitorTimer?.cancel();
    print('🔍 System health monitoring stopped');
  }
  
  /// Perform health check
  Future<SystemHealthStatus> checkSystemHealth() async {
    final issues = <String>[];
    
    // Check sensors
    final sensorsHealthy = _checkSensors(issues);
    
    // Check navigation
    final navigationHealthy = _checkNavigation(issues);
    
    // Check storage
    final storageHealthy = await _checkStorage(issues);
    
    // Determine overall health
    SystemHealth overall;
    if (issues.isEmpty) {
      overall = SystemHealth.HEALTHY;
    } else if (issues.length <= 2) {
      overall = SystemHealth.DEGRADED;
    } else {
      overall = SystemHealth.CRITICAL;
    }
    
    _currentStatus = SystemHealthStatus(
      overall: overall,
      sensorsHealthy: sensorsHealthy,
      navigationHealthy: navigationHealthy,
      storageHealthy: storageHealthy,
      issues: issues,
    );
    
    _statusController.add(_currentStatus);
    
    // Log issues
    if (issues.isNotEmpty) {
      print('⚠️ System health issues detected:');
      for (final issue in issues) {
        print('   - $issue');
      }
    }
    
    return _currentStatus;
  }
  
  // ===========================================================================
  // INDIVIDUAL CHECKS
  // ===========================================================================
  
  /// Check sensor health
  bool _checkSensors(List<String> issues) {
    if (_sensors == null) {
      issues.add('Sensors not initialized');
      return false;
    }
    
    if (!_sensors!.hasPermissions) {
      issues.add('Sensor permissions denied');
      return false;
    }
    
    if (_sensors!.getHeadingConfidence() == SensorConfidence.LOW) {
      issues.add('Compass unreliable');
    }
    
    if (_sensors!.isDeviceTilted) {
      issues.add('Device tilted excessively');
    }
    
    return issues.isEmpty;
  }
  
  /// Check navigation health
  bool _checkNavigation(List<String> issues) {
    if (_navigationEngine == null) {
      issues.add('Navigation engine not initialized');
      return false;
    }
    
    final status = _navigationEngine!.status;
    
    if (status == NavigationStatus.error) {
      issues.add('Navigation in error state');
      return false;
    }
    
    // Check if path exists when navigating
    if (status == NavigationStatus.navigating) {
      final currentPath = _navigationEngine!.currentPath;
      
      if (currentPath == null || currentPath.nodes.isEmpty) {
        issues.add('Invalid navigation path');
        return false;
      }
    }
    
    return true;
  }
  
  /// Check storage health
  Future<bool> _checkStorage(List<String> issues) async {
    if (_backupService == null) {
      return true; // Optional service
    }
    
    final isHealthy = await _backupService!.checkDataIntegrity();
    
    if (!isHealthy) {
      issues.add('Data integrity check failed');
      return false;
    }
    
    if (_backupService!.isInSafeMode) {
      issues.add('System in SafeMode');
      return false;
    }
    
    return true;
  }
  
  // ===========================================================================
  // FAIL-SAFE ACTIONS
  // ===========================================================================
  
  /// Trigger fallback to assisted mode
  void triggerAssistedModeFallback() {
    print('🛡️ Triggering assisted mode fallback');
    
    // This will be called by UI when critical issues detected
    // UI should switch to photo-based turn cards
  }
  
  /// Attempt auto-recovery
  Future<bool> attemptAutoRecovery() async {
    print('🔧 Attempting auto-recovery...');
    
    // Try to restore from backup if storage corrupted
    if (!_currentStatus.storageHealthy && _backupService != null) {
      final lastBackup = await _backupService!.getLastStableBackup();
      
      if (lastBackup != null) {
        final restored = await _backupService!.restoreFromBackup(lastBackup);
        
        if (restored) {
          print('✅ Auto-recovery successful');
          return true;
        }
      }
    }
    
    print('❌ Auto-recovery failed');
    return false;
  }
  
  // ===========================================================================
  // RESOURCE MANAGEMENT
  // ===========================================================================
  
  void dispose() {
    _monitorTimer?.cancel();
    _statusController.close();
  }
}

// =============================================================================
// RIVERPOD PROVIDER
// =============================================================================

final systemHealthMonitorProvider = Provider<SystemHealthMonitor>((ref) {
  // TODO: Wire actual services
  return SystemHealthMonitor();
});
