/// CampusNav - Person Model
///
/// Data model for personnel directory.
/// Used for locating people within the campus.

// =============================================================================
// PERSON MODEL
// =============================================================================

class PersonModel {
  final String id;
  final String name;
  final String? department;
  final String? designation;
  final String? email;
  final String? phone;
  final String? officeLocationId; // References LocationModel
  final String? imageUrl;
  final List<String>? tags; // For search (e.g., "professor", "HOD")

  PersonModel({
    required this.id,
    required this.name,
    this.department,
    this.designation,
    this.email,
    this.phone,
    this.officeLocationId,
    this.imageUrl,
    this.tags,
  });

  /// Create from JSON map
  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'] as String,
      name: json['name'] as String,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      officeLocationId: json['office_location_id'] as String?,
      imageUrl: json['image_url'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'designation': designation,
      'email': email,
      'phone': phone,
      'office_location_id': officeLocationId,
      'image_url': imageUrl,
      'tags': tags,
    };
  }

  /// Get display title (name + designation)
  String get displayTitle {
    if (designation != null) {
      return '$name - $designation';
    }
    return name;
  }
}
