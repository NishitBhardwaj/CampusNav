/// CampusNav - Location Entity
///
/// Domain entity representing a location in the campus.
/// This is a pure domain object without data layer dependencies.

// =============================================================================
// LOCATION ENTITY
// =============================================================================

class Location {
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

  const Location({
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

  /// Get position as a tuple
  (double, double) get position => (x, y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Location($name)';
}
