/// CampusNav - Floor Model (Hive)
///
/// Data model for building floors.
/// Each building can have multiple floors.

import 'package:hive/hive.dart';

part 'floor_hive.g.dart';

// =============================================================================
// FLOOR MODEL
// =============================================================================

@HiveType(typeId: 1)
class FloorHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String buildingId;

  @HiveField(2)
  final String name; // e.g., "Ground Floor", "1st Floor"

  @HiveField(3)
  final int level; // Numeric level (0 = ground, -1 = basement)

  @HiveField(4)
  final String? mapAssetPath; // Path to floor plan image

  @HiveField(5)
  final double? mapWidth; // Map image width in pixels

  @HiveField(6)
  final double? mapHeight; // Map image height in pixels

  @HiveField(7)
  final double pixelsPerMeter; // Scale factor

  @HiveField(8)
  final bool isAccessible;

  @HiveField(9)
  final bool hasElevator;

  @HiveField(10)
  final bool hasStairs;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  FloorHive({
    required this.id,
    required this.buildingId,
    required this.name,
    required this.level,
    this.mapAssetPath,
    this.mapWidth,
    this.mapHeight,
    this.pixelsPerMeter = 10.0,
    this.isAccessible = true,
    this.hasElevator = false,
    this.hasStairs = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Get formatted floor name
  String get displayName {
    if (level == 0) return 'Ground Floor';
    if (level < 0) return 'Basement ${level.abs()}';
    return 'Floor $level';
  }

  /// Create a copy with updated fields
  FloorHive copyWith({
    String? id,
    String? buildingId,
    String? name,
    int? level,
    String? mapAssetPath,
    double? mapWidth,
    double? mapHeight,
    double? pixelsPerMeter,
    bool? isAccessible,
    bool? hasElevator,
    bool? hasStairs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FloorHive(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      name: name ?? this.name,
      level: level ?? this.level,
      mapAssetPath: mapAssetPath ?? this.mapAssetPath,
      mapWidth: mapWidth ?? this.mapWidth,
      mapHeight: mapHeight ?? this.mapHeight,
      pixelsPerMeter: pixelsPerMeter ?? this.pixelsPerMeter,
      isAccessible: isAccessible ?? this.isAccessible,
      hasElevator: hasElevator ?? this.hasElevator,
      hasStairs: hasStairs ?? this.hasStairs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
