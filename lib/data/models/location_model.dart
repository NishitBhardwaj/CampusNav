/// CampusNav - Location Model
///
/// Data model for location data, used for serialization/deserialization
/// with local storage and optional backend sync.

// =============================================================================
// LOCATION MODEL
// =============================================================================

class LocationModel {
  final String id;
  final String name;
  final String buildingId;
  final String floorId;
  final double x;
  final double y;
  final String? description;
  final String? category;
  final List<String>? tags;
  final bool isAccessible;

  LocationModel({
    required this.id,
    required this.name,
    required this.buildingId,
    required this.floorId,
    required this.x,
    required this.y,
    this.description,
    this.category,
    this.tags,
    this.isAccessible = true,
  });

  /// Create from JSON map
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      buildingId: json['building_id'] as String,
      floorId: json['floor_id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      description: json['description'] as String?,
      category: json['category'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
      isAccessible: json['is_accessible'] as bool? ?? true,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'building_id': buildingId,
      'floor_id': floorId,
      'x': x,
      'y': y,
      'description': description,
      'category': category,
      'tags': tags,
      'is_accessible': isAccessible,
    };
  }

  /// Create a copy with updated fields
  LocationModel copyWith({
    String? id,
    String? name,
    String? buildingId,
    String? floorId,
    double? x,
    double? y,
    String? description,
    String? category,
    List<String>? tags,
    bool? isAccessible,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      buildingId: buildingId ?? this.buildingId,
      floorId: floorId ?? this.floorId,
      x: x ?? this.x,
      y: y ?? this.y,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isAccessible: isAccessible ?? this.isAccessible,
    );
  }
}
