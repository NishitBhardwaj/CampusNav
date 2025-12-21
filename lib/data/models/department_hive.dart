/// CampusNav - Department Model (Hive)
///
/// Data model for academic/administrative departments.
/// Departments group personnel and may span multiple buildings.

import 'package:hive/hive.dart';

part 'department_hive.g.dart';

// =============================================================================
// DEPARTMENT MODEL
// =============================================================================

@HiveType(typeId: 3)
class DepartmentHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? shortCode; // e.g., "CS", "EE", "ADMIN"

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String? headOfDepartmentId; // Personnel ID

  @HiveField(5)
  final String? mainOfficeRoomId; // Primary office room

  @HiveField(6)
  final String? primaryBuildingId;

  @HiveField(7)
  final String? phone;

  @HiveField(8)
  final String? email;

  @HiveField(9)
  final String? website;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  DepartmentHive({
    required this.id,
    required this.name,
    this.shortCode,
    this.description,
    this.headOfDepartmentId,
    this.mainOfficeRoomId,
    this.primaryBuildingId,
    this.phone,
    this.email,
    this.website,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Get display name with short code
  String get displayName {
    if (shortCode != null) {
      return '$name ($shortCode)';
    }
    return name;
  }

  /// Create a copy with updated fields
  DepartmentHive copyWith({
    String? id,
    String? name,
    String? shortCode,
    String? description,
    String? headOfDepartmentId,
    String? mainOfficeRoomId,
    String? primaryBuildingId,
    String? phone,
    String? email,
    String? website,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepartmentHive(
      id: id ?? this.id,
      name: name ?? this.name,
      shortCode: shortCode ?? this.shortCode,
      description: description ?? this.description,
      headOfDepartmentId: headOfDepartmentId ?? this.headOfDepartmentId,
      mainOfficeRoomId: mainOfficeRoomId ?? this.mainOfficeRoomId,
      primaryBuildingId: primaryBuildingId ?? this.primaryBuildingId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
