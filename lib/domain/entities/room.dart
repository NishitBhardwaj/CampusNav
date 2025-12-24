/// CampusNav - Room Entity
///
/// PHASE 5: Room data model for admin management.

import 'package:hive/hive.dart';

part 'room.g.dart';

@HiveType(typeId: 3)
class Room extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String roomName;
  
  @HiveField(2)
  String roomNumber;
  
  @HiveField(3)
  String floorId;
  
  @HiveField(4)
  RoomType type;
  
  @HiveField(5)
  String? associatedPersonId;
  
  @HiveField(6)
  String? photoUri;
  
  @HiveField(7)
  String? description;
  
  @HiveField(8)
  DateTime createdAt;
  
  @HiveField(9)
  DateTime updatedAt;
  
  @HiveField(10)
  String updatedBy;
  
  Room({
    required this.id,
    required this.roomName,
    required this.roomNumber,
    required this.floorId,
    required this.type,
    this.associatedPersonId,
    this.photoUri,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.updatedBy = 'System',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  Room copyWith({
    String? id,
    String? roomName,
    String? roomNumber,
    String? floorId,
    RoomType? type,
    String? associatedPersonId,
    String? photoUri,
    String? description,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return Room(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      roomNumber: roomNumber ?? this.roomNumber,
      floorId: floorId ?? this.floorId,
      type: type ?? this.type,
      associatedPersonId: associatedPersonId ?? this.associatedPersonId,
      photoUri: photoUri ?? this.photoUri,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
  
  @override
  String toString() => 'Room($roomNumber: $roomName)';
}

@HiveType(typeId: 4)
enum RoomType {
  @HiveField(0)
  OFFICE,
  
  @HiveField(1)
  LAB,
  
  @HiveField(2)
  CLASSROOM,
  
  @HiveField(3)
  DEPARTMENT,
  
  @HiveField(4)
  COMMON_AREA,
  
  @HiveField(5)
  RESTROOM,
  
  @HiveField(6)
  OTHER,
}
