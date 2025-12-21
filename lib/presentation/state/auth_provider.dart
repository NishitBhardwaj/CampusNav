/// CampusNav - Auth Provider (Riverpod)
///
/// Manages authentication state and user role.
/// Uses Riverpod for reactive state management.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/role.dart';

// =============================================================================
// AUTH STATE
// =============================================================================

/// State class for authentication
class AuthState {
  final AppUser user;
  final bool isInitialized;

  const AuthState({
    required this.user,
    this.isInitialized = false,
  });

  /// Initial state with guest user
  factory AuthState.initial() {
    return AuthState(
      user: AppUser.guest(),
      isInitialized: false,
    );
  }

  /// Copy with updated values
  AuthState copyWith({
    AppUser? user,
    bool? isInitialized,
  }) {
    return AuthState(
      user: user ?? this.user,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// =============================================================================
// AUTH NOTIFIER
// =============================================================================

/// Notifier for managing auth state
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  /// Initialize auth state
  Future<void> initialize() async {
    // TODO: Load saved role from local storage
    await Future.delayed(const Duration(milliseconds: 100));
    state = state.copyWith(isInitialized: true);
  }

  /// Switch to user role
  void switchToUser() {
    state = state.copyWith(
      user: AppUser.guest(),
    );
  }

  /// Switch to admin role
  /// In production, this would require authentication
  void switchToAdmin({String? name}) {
    state = state.copyWith(
      user: AppUser.admin(name: name),
    );
  }

  /// Toggle between user and admin (for demo purposes)
  void toggleRole() {
    if (state.user.isAdmin) {
      switchToUser();
    } else {
      switchToAdmin();
    }
  }

  /// Check if current user can edit
  bool get canEdit => state.user.role.canEditData;

  /// Get current role
  UserRole get currentRole => state.user.role;
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Provider for current user
final currentUserProvider = Provider<AppUser>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider for current role
final currentRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(currentUserProvider).role;
});

/// Provider to check if user can edit
final canEditProvider = Provider<bool>((ref) {
  return ref.watch(currentRoleProvider).canEditData;
});

/// Provider to check if user is admin
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider).isAdmin;
});
