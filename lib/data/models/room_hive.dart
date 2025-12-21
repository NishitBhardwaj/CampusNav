/// CampusNav - Room Model (Hive)
///
/// Data model for rooms within floors.
/// Rooms are the primary navigation destinations.

import 'package:hive/hive.dart';

part 'room_hive.g.dart';

// =============================================================================
// ROOM TYPE ENUM
// =============================================================================

@HiveType(typeId: 10)
enum RoomType {
  @HiveField(0)
  classroom,

  @HiveField(1)
  lab,

  @HiveField(2)
  office,

  @HiveField(3)
  restroom,

  @HiveField(4)
  cafeteria,

  @HiveField(5)
  library,

  @HiveField(6)
  auditorium,

  @HiveField(7)
  meetingRoom,

  @HiveField(8)
  storage,

  @HiveField(9)
  entrance,

  @HiveField(10)
  staircase,

  @HiveField(11)
  elevator,

  @HiveField(12)
  other,
}

// =============================================================================
// ROOM MODEL
// =============================================================================

@HiveType(typeId: 2)
class RoomHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String floorId;

  @HiveField(2)
  final String buildingId;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final String? roomNumber; // e.g., "101", "A-203"

  @HiveField(5)
  final RoomType roomType;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final double x; // X coordinate on floor map

  @HiveField(8)
  final double y; // Y coordinate on floor map

  @HiveField(9)
  final String? departmentId;

  @HiveField(10)
  final int? capacity;

  @HiveField(11)
  final bool isAccessible;

  @HiveField(12)
  final List<String>? tags; // Search tags

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  RoomHive({
    required this.id,
    required this.floorId,
    required this.buildingId,
    required this.name,
    this.roomNumber,
    this.roomType = RoomType.other,
    this.description,
    required this.x,
    required this.y,
    this.departmentId,
    this.capacity,
    this.isAccessible = true,
    this.tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Get display name with room number
  String get displayName {
    if (roomNumber != null) {
      return '$roomNumber - $name';
    }
    return name;
  }

  /// Get room type display name
  String get roomTypeDisplayName {
    switch (roomType) {
      case RoomType.classroom:
        return 'Classroom';
      case RoomType.lab:
        return 'Laboratory';
      case RoomType.office:
        return 'Office';
      case RoomType.restroom:
        return 'Restroom';
      case RoomType.cafeteria:
        return 'Cafeteria';
      case RoomType.library:
        return 'Library';
      case RoomType.auditorium:
        return 'Auditorium';
      case RoomType.meetingRoom:
        return 'Meeting Room';
      case RoomType.storage:
        return 'Storage';
      case RoomType.entrance:
        return 'Entrance';
      case RoomType.staircase:
        return 'Staircase';
      case RoomType.elevator:
        return 'Elevator';
      case RoomType.other:
        return 'Other';
    }
  }
}
