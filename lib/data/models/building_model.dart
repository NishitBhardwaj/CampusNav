/// CampusNav - Building Model
///
/// Data model for building information.
/// A building contains multiple floors and associated metadata.

// =============================================================================
// BUILDING MODEL
// =============================================================================

class BuildingModel {
  final String id;
  final String name;
  final String? description;
  final List<FloorModel> floors;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;

  BuildingModel({
    required this.id,
    required this.name,
    this.description,
    this.floors = const [],
    this.latitude,
    this.longitude,
    this.imageUrl,
  });

  /// Create from JSON map
  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    return BuildingModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      floors: (json['floors'] as List?)
              ?.map((f) => FloorModel.fromJson(f))
              .toList() ??
          [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'floors': floors.map((f) => f.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
    };
  }
}

// =============================================================================
// FLOOR MODEL
// =============================================================================

class FloorModel {
  final String id;
  final String name;
  final int level; // Floor number (0 = ground, -1 = basement, etc.)
  final String? mapImagePath;
  final double? width;
  final double? height;
  final double pixelsPerMeter;

  FloorModel({
    required this.id,
    required this.name,
    required this.level,
    this.mapImagePath,
    this.width,
    this.height,
    this.pixelsPerMeter = 10.0,
  });

  /// Create from JSON map
  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as int,
      mapImagePath: json['map_image_path'] as String?,
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      pixelsPerMeter: (json['pixels_per_meter'] as num?)?.toDouble() ?? 10.0,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'map_image_path': mapImagePath,
      'width': width,
      'height': height,
      'pixels_per_meter': pixelsPerMeter,
    };
  }
}
