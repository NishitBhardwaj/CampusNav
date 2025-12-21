/// CampusNav - User Role Entity
///
/// Defines user roles for role-based access control.
/// - User: Read-only access + feedback submission
/// - Admin: Full access to add/edit campus data

// =============================================================================
// USER ROLE ENUM
// =============================================================================

/// Available roles in the CampusNav system
enum UserRole {
  /// Standard user with read-only access
  /// Can: view navigation, search, provide feedback
  /// Cannot: modify campus data
  user,

  /// Administrator with full access
  /// Can: add/edit buildings, rooms, personnel, etc.
  admin,
}

// =============================================================================
// ROLE EXTENSIONS
// =============================================================================

extension UserRoleExtension on UserRole {
  /// Get display name for the role
  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  /// Get description of role capabilities
  String get description {
    switch (this) {
      case UserRole.user:
        return 'Navigate campus, search locations, and provide feedback';
      case UserRole.admin:
        return 'Manage campus data, buildings, rooms, and personnel';
    }
  }

  /// Check if role can edit data
  bool get canEditData => this == UserRole.admin;

  /// Check if role can submit feedback
  bool get canSubmitFeedback => true; // All roles can submit feedback

  /// Check if role can view analytics
  bool get canViewAnalytics => this == UserRole.admin;
}

// =============================================================================
// APP USER
// =============================================================================

/// Represents the current app user
class AppUser {
  final String id;
  final String? name;
  final UserRole role;
  final DateTime lastActive;

  const AppUser({
    required this.id,
    this.name,
    required this.role,
    required this.lastActive,
  });

  /// Create a guest user (default)
  factory AppUser.guest() {
    return AppUser(
      id: 'guest',
      name: null,
      role: UserRole.user,
      lastActive: DateTime.now(),
    );
  }

  /// Create an admin user
  factory AppUser.admin({String? name}) {
    return AppUser(
      id: 'admin',
      name: name ?? 'Administrator',
      role: UserRole.admin,
      lastActive: DateTime.now(),
    );
  }

  /// Check if user is guest
  bool get isGuest => id == 'guest';

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  @override
  String toString() => 'AppUser(id: $id, role: ${role.displayName})';
}
