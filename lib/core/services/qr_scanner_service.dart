/// CampusNav - Enhanced QR Scanner Service
///
/// PHASE 3: Full QR scanning implementation with mobile_scanner.
///
/// Handles QR code scanning for position reset with visual feedback.

import 'dart:async';
import 'package:mobile_scanner/mobile_scanner.dart';

// =============================================================================
// QR SCAN RESULT
// =============================================================================

class QRScanResult {
  final String nodeId;
  final QRCodeType type;
  final String rawData;
  final DateTime timestamp;
  
  QRScanResult({
    required this.nodeId,
    required this.type,
    required this.rawData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  @override
  String toString() => 'QRScan($type: $nodeId)';
}

enum QRCodeType {
  NODE,      // Generic navigation node
  ROOM,      // Room entrance
  STAIRS,    // Staircase
  ELEVATOR,  // Elevator
  UNKNOWN,   // Unrecognized format
}

// =============================================================================
// QR SCANNER SERVICE
// =============================================================================

class QRScannerService {
  MobileScannerController? _controller;
  
  final _scanController = StreamController<QRScanResult>.broadcast();
  Stream<QRScanResult> get scanStream => _scanController.stream;
  
  bool _isScanning = false;
  DateTime? _lastScanTime;
  static const Duration scanCooldown = Duration(seconds: 2);
  
  bool get isScanning => _isScanning;
  
  // ===========================================================================
  // SCANNER CONTROL
  // ===========================================================================
  
  /// Initialize QR scanner
  Future<bool> initialize() async {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      
      return true;
    } catch (e) {
      print('❌ QR Scanner initialization failed: $e');
      return false;
    }
  }
  
  /// Start scanning
  Future<void> startScanning() async {
    if (_controller == null) {
      await initialize();
    }
    
    _isScanning = true;
    await _controller?.start();
  }
  
  /// Stop scanning
  Future<void> stopScanning() async {
    _isScanning = false;
    await _controller?.stop();
  }
  
  /// Process barcode detection
  void onDetect(BarcodeCapture capture) {
    // Cooldown to prevent multiple scans
    if (_lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!) < scanCooldown) {
      return;
    }
    
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;
    
    if (rawValue == null || rawValue.isEmpty) return;
    
    // Parse QR code
    final result = _parseQRCode(rawValue);
    if (result != null) {
      _lastScanTime = DateTime.now();
      _scanController.add(result);
    }
  }
  
  // ===========================================================================
  // QR CODE PARSING
  // ===========================================================================
  
  /// Parse QR code data
  /// 
  /// Supported formats:
  /// - NODE:<node_id>
  /// - ROOM:<room_id>
  /// - STAIRS:<node_id>
  /// - ELEVATOR:<node_id>
  QRScanResult? _parseQRCode(String data) {
    final parts = data.split(':');
    if (parts.length != 2) {
      return QRScanResult(
        nodeId: data,
        type: QRCodeType.UNKNOWN,
        rawData: data,
      );
    }
    
    final typeStr = parts[0].toUpperCase();
    final nodeId = parts[1];
    
    QRCodeType type;
    switch (typeStr) {
      case 'NODE':
        type = QRCodeType.NODE;
        break;
      case 'ROOM':
        type = QRCodeType.ROOM;
        break;
      case 'STAIRS':
        type = QRCodeType.STAIRS;
        break;
      case 'ELEVATOR':
        type = QRCodeType.ELEVATOR;
        break;
      default:
        type = QRCodeType.UNKNOWN;
    }
    
    return QRScanResult(
      nodeId: nodeId,
      type: type,
      rawData: data,
    );
  }
  
  // ===========================================================================
  // RESOURCE MANAGEMENT
  // ===========================================================================
  
  void dispose() {
    _controller?.dispose();
    _scanController.close();
  }
  
  /// Toggle torch/flashlight
  Future<void> toggleTorch() async {
    await _controller?.toggleTorch();
  }
  
  /// Get controller for UI integration
  MobileScannerController? get controller => _controller;
}
