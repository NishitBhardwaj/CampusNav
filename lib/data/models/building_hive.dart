/// CampusNav - Building Model (Hive)
///
/// Data model for campus buildings.
/// Uses Hive for offline-first local storage.

import 'package:hive/hive.dart';

part 'building_hive.g.dart';

// =============================================================================
// BUILDING MODEL
// =============================================================================

@HiveType(typeId: 0)
class BuildingHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? shortCode; // e.g., "ENG", "LIB", "ADMIN"

  @HiveField(4)
  final int floorCount;

  @HiveField(5)
  final double? latitude;

  @HiveField(6)
  final double? longitude;

  @HiveField(7)
  final String? imageAssetPath;

  @HiveField(8)
  final bool isAccessible;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final String? createdBy; // Admin who added this

  BuildingHive({
    required this.id,
    required this.name,
    this.description,
    this.shortCode,
    this.floorCount = 1,
    this.latitude,
    this.longitude,
    this.imageAssetPath,
    this.isAccessible = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdBy,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy with updated fields
  BuildingHive copyWith({
    String? id,
    String? name,
    String? description,
    String? shortCode,
    int? floorCount,
    double? latitude,
    double? longitude,
    String? imageAssetPath,
    bool? isAccessible,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return BuildingHive(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortCode: shortCode ?? this.shortCode,
      floorCount: floorCount ?? this.floorCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      isAccessible: isAccessible ?? this.isAccessible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
