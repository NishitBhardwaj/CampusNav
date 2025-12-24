/// CampusNav - QR Service
///
class QrLocationData {
  final String buildingId;
  final String floorId;
  final double x;
  final double y;
  final String? locationName;
  final DateTime scannedAt;

  QrLocationData({
    required this.buildingId,
    required this.floorId,
    required this.x,
    required this.y,
    this.locationName,
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now();

  /// Create from QR code string
  /// Expected format: "campusnav://building_id/floor_id/x/y/name"
  factory QrLocationData.fromQrString(String qrData) {
    try {
      final uri = Uri.parse(qrData);
      final segments = uri.pathSegments;

      if (segments.length < 4) {
        throw FormatException('Invalid QR code format');
      }

      return QrLocationData(
        buildingId: segments[0],
        floorId: segments[1],
        x: double.parse(segments[2]),
        y: double.parse(segments[3]),
        locationName: segments.length > 4 ? segments[4] : null,
      );
    } catch (e) {
      throw FormatException('Failed to parse QR code: $e');
    }
  }

  @override
  String toString() {
    return 'QrLocationData(building: $buildingId, floor: $floorId, x: $x, y: $y)';
  }
}

// =============================================================================
// QR SERVICE INTERFACE
// =============================================================================

/// Result of a QR scan operation
enum QrScanResult {
  success,
  cancelled,
  invalidFormat,
  cameraError,
}

/// Abstract interface for QR operations
abstract class QrService {
  /// Scan a QR code and return location data
  Future<(QrScanResult, QrLocationData?)> scanQrCode();

  /// Validate if a QR code string is valid CampusNav format
  bool isValidCampusNavQr(String qrData);
}

// =============================================================================
// MOCK QR SERVICE (for testing/demo)
// =============================================================================

/// Mock implementation for testing without camera
class MockQrService implements QrService {
  @override
  Future<(QrScanResult, QrLocationData?)> scanQrCode() async {
    // Simulate scan delay
    await Future.delayed(Duration(milliseconds: 500));

    // Return mock data for demo
    return (
      QrScanResult.success,
      QrLocationData(
        buildingId: 'main_building',
        floorId: 'floor_1',
        x: 100.0,
        y: 150.0,
        locationName: 'Main Entrance',
      ),
    );
  }

  @override
  bool isValidCampusNavQr(String qrData) {
    return qrData.startsWith('campusnav://');
  }
}
