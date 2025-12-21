/// CampusNav - Person Entity
///
/// Domain entity representing a person in the campus directory.

// =============================================================================
// PERSON ENTITY
// =============================================================================

class Person {
  final String id;
  final String name;
  final String? department;
  final String? designation;
  final String? email;
  final String? phone;
  final String? officeLocationId;
  final String? imageUrl;
  final List<String>? tags;

  const Person({
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

  /// Get display title
  String get displayTitle {
    if (designation != null) {
      return '$name - $designation';
    }
    return name;
  }

  /// Get subtitle (department)
  String? get subtitle => department;

  /// Check if person has office location
  bool get hasOfficeLocation => officeLocationId != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Person($name)';
}
