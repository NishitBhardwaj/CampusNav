/// CampusNav - Personnel Model (Hive)
///
/// Data model for campus personnel (faculty, staff).
/// Used for the personnel locator feature.

import 'package:hive/hive.dart';

part 'personnel_hive.g.dart';

// =============================================================================
// PERSONNEL MODEL
// =============================================================================

@HiveType(typeId: 4)
class PersonnelHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? designation; // e.g., "Professor", "Lab Assistant"

  @HiveField(3)
  final String? departmentId;

  @HiveField(4)
  final String? officeRoomId; // Primary office location

  @HiveField(5)
  final String? email;

  @HiveField(6)
  final String? phone;

  @HiveField(7)
  final String? imageAssetPath;

  @HiveField(8)
  final List<String>? tags; // Search tags: ["HOD", "AI", "ML"]

  @HiveField(9)
  final String? officeHours; // e.g., "Mon-Fri 10AM-4PM"

  @HiveField(10)
  final bool isAvailable; // Currently available for meetings

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  PersonnelHive({
    required this.id,
    required this.name,
    this.designation,
    this.departmentId,
    this.officeRoomId,
    this.email,
    this.phone,
    this.imageAssetPath,
    this.tags,
    this.officeHours,
    this.isAvailable = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Get display title (name with designation)
  String get displayTitle {
    if (designation != null) {
      return '$name - $designation';
    }
    return name;
  }

  /// Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  /// Create a copy with updated fields
  PersonnelHive copyWith({
    String? id,
    String? name,
    String? designation,
    String? departmentId,
    String? officeRoomId,
    String? email,
    String? phone,
    String? imageAssetPath,
    List<String>? tags,
    String? officeHours,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonnelHive(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      departmentId: departmentId ?? this.departmentId,
      officeRoomId: officeRoomId ?? this.officeRoomId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      tags: tags ?? this.tags,
      officeHours: officeHours ?? this.officeHours,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
