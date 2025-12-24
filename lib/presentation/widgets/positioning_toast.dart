/// CampusNav - Positioning Status Toast
///
/// PHASE 3: Transparent feedback for positioning events.
///
/// Shows user what's happening with their position:
/// - "Compass unstable, snapping to hallway"
/// - "Location synced via QR"
/// - "Floor change detected — confirm?"

import 'package:flutter/material.dart';

enum ToastType {
  INFO,
  SUCCESS,
  WARNING,
  ERROR,
}

class PositioningToast {
  /// Show a positioning status toast
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.INFO,
    Duration duration = const Duration(seconds: 3),
  }) {
    final (color, icon) = _getToastStyle(type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  static (Color, IconData) _getToastStyle(ToastType type) {
    switch (type) {
      case ToastType.INFO:
        return (Colors.blue.shade700, Icons.info_outline);
      case ToastType.SUCCESS:
        return (Colors.green.shade700, Icons.check_circle_outline);
      case ToastType.WARNING:
        return (Colors.orange.shade700, Icons.warning_amber);
      case ToastType.ERROR:
        return (Colors.red.shade700, Icons.error_outline);
    }
  }
}

// =============================================================================
// COMMON POSITIONING MESSAGES
// =============================================================================

class PositioningMessages {
  // QR Scanning
  static const qrSynced = 'Location synced via QR';
  static const qrFailed = 'QR code not recognized';
  
  // Sensor Status
  static const compassUnstable = 'Compass unstable, snapping to hallway';
  static const deviceTilted = 'Device tilted, using path direction';
  static const sensorsLost = 'Sensors unavailable, using assisted mode';
  
  // Movement
  static const userStopped = 'Movement paused';
  static const userWalking = 'Tracking movement';
  static const offPath = 'You may be off the path';
  
  // Floor Changes
  static const floorChangeDetected = 'Floor change detected — confirm?';
  static const floorChanged = 'Floor changed successfully';
  
  // Mode Changes
  static const switchedToAssisted = 'Switched to Assisted mode';
  static const switchedToManual = 'Switched to Manual mode';
  static const switchedToSmart = 'Switched to Smart mode';
  
  // Corrections
  static const positionCorrected = 'Position corrected to path';
  static const headingCorrected = 'Heading aligned to corridor';
  static const multipleCorrections = 'Multiple corrections needed. Consider Manual mode.';
  
  // Visual Landmarks
  static const landmarkRecognized = 'Landmark recognized';
  static const landmarkLowConfidence = 'Landmark match confidence too low';
}
