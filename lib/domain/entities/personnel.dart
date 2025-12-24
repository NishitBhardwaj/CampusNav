/// CampusNav - Personnel Entity
///
/// PHASE 5: Personnel data model for admin management.

import 'package:hive/hive.dart';

part 'personnel.g.dart';

@HiveType(typeId: 5)
class Personnel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String title; // Dean, Registrar, HOD, Professor, etc.
  
  @HiveField(3)
  String department;
  
  @HiveField(4)
  String? roomId;
  
  @HiveField(5)
  String? email;
  
  @HiveField(6)
  String? phone;
  
  @HiveField(7)
  String? photoUri;
  
  @HiveField(8)
  DateTime createdAt;
  
  @HiveField(9)
  DateTime updatedAt;
  
  @HiveField(10)
  String updatedBy;
  
  Personnel({
    required this.id,
    required this.name,
    required this.title,
    required this.department,
    this.roomId,
    this.email,
    this.phone,
    this.photoUri,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.updatedBy = 'System',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  Personnel copyWith({
    String? id,
    String? name,
    String? title,
    String? department,
    String? roomId,
    String? email,
    String? phone,
    String? photoUri,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return Personnel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      department: department ?? this.department,
      roomId: roomId ?? this.roomId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUri: photoUri ?? this.photoUri,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
  
  @override
  String toString() => 'Personnel($name - $title)';
}
