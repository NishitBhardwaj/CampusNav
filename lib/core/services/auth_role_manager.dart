/// CampusNav - Auth Role Manager
///
/// PHASE 5: Lightweight role-based access control.
///
/// ROLES:
/// - User: Search, navigate, submit feedback
/// - Admin: Manage data, approve feedback, configure system
///
/// WHY LIGHTWEIGHT:
/// - No OAuth/JWT complexity
/// - Offline-first design
/// - Simple PIN-based admin access
/// - Role stored locally

import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/role.dart';

// =============================================================================
// AUTH ROLE MANAGER
// =============================================================================

class AuthRoleManager {
  static const String _roleBoxName = 'auth_role';
  static const String _roleKey = 'current_role';
  static const String _adminPinKey = 'admin_pin';
  
  // Default admin PIN (should be changed on first use)
  static const String defaultAdminPin = '1234';
  
  Box? _roleBox;
  
  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================
  
  Future<void> initialize() async {
    _roleBox = await Hive.openBox(_roleBoxName);
    
    // Set default admin PIN if not exists
    if (_roleBox!.get(_adminPinKey) == null) {
      await _roleBox!.put(_adminPinKey, defaultAdminPin);
    }
    
    // Default to user role
    if (_roleBox!.get(_roleKey) == null) {
      await _roleBox!.put(_roleKey, Role.user.toString());
    }
  }
  
  // ===========================================================================
  // ROLE MANAGEMENT
  // ===========================================================================
  
  /// Get current role
  Role getCurrentRole() {
    if (_roleBox == null) return Role.user;
    
    final roleStr = _roleBox!.get(_roleKey, defaultValue: Role.user.toString());
    return roleStr == Role.admin.toString() ? Role.admin : Role.user;
  }
  
  /// Set current role
  Future<void> setRole(Role role) async {
    await _roleBox?.put(_roleKey, role.toString());
  }
  
  /// Check if current user is admin
  bool isAdmin() {
    return getCurrentRole() == Role.admin;
  }
  
  // ===========================================================================
  // ADMIN LOGIN
  // ===========================================================================
  
  /// Attempt admin login with PIN
  Future<bool> loginAsAdmin(String pin) async {
    final storedPin = _roleBox?.get(_adminPinKey, defaultValue: defaultAdminPin);
    
    if (pin == storedPin) {
      await setRole(Role.admin);
      return true;
    }
    
    return false;
  }
  
  /// Logout (return to user role)
  Future<void> logout() async {
    await setRole(Role.user);
  }
  
  // ===========================================================================
  // ADMIN PIN MANAGEMENT
  // ===========================================================================
  
  /// Change admin PIN
  Future<bool> changeAdminPin({
    required String currentPin,
    required String newPin,
  }) async {
    final storedPin = _roleBox?.get(_adminPinKey, defaultValue: defaultAdminPin);
    
    if (currentPin != storedPin) {
      return false; // Current PIN incorrect
    }
    
    await _roleBox?.put(_adminPinKey, newPin);
    return true;
  }
  
  /// Reset admin PIN (requires confirmation)
  Future<void> resetAdminPin() async {
    await _roleBox?.put(_adminPinKey, defaultAdminPin);
  }
  
  // ===========================================================================
  // HELPERS
  // ===========================================================================
  
  /// Check if admin PIN is still default (security warning)
  bool isUsingDefaultPin() {
    final storedPin = _roleBox?.get(_adminPinKey, defaultValue: defaultAdminPin);
    return storedPin == defaultAdminPin;
  }
}

// =============================================================================
// RIVERPOD PROVIDER
// =============================================================================

final authRoleManagerProvider = Provider<AuthRoleManager>((ref) {
  return AuthRoleManager();
});
