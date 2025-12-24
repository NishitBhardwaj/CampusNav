/// CampusNav - Authentication Service
///
/// PHASE 7: Firebase authentication with offline-first support.
///
/// FEATURES:
/// - Google Sign-In
/// - Email/Password Sign-In
/// - Email/Password Sign-Up
/// - Password Reset
/// - Offline session management

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/user_profile.dart';

// =============================================================================
// AUTHENTICATION SERVICE
// =============================================================================

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Box<UserProfile>? _profileBox;
  
  static const String _tokenKey = 'auth_token';
  static const String _uidKey = 'user_uid';
  
  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current user
  User? get currentUser => _auth.currentUser;
  
  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================
  
  Future<void> initialize() async {
    _profileBox = await Hive.openBox<UserProfile>('user_profile');
    print('🔐 Auth service initialized');
  }
  
  // ===========================================================================
  // GOOGLE SIGN-IN
  // ===========================================================================
  
  /// Sign in with Google
  Future<UserProfile?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled
        return null;
      }
      
      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Save session
      await _saveSession(userCredential.user!);
      
      // Create/update profile
      final profile = await _createOrUpdateProfile(userCredential.user!);
      
      print('✅ Google sign-in successful: ${profile.name}');
      return profile;
    } catch (e) {
      print('❌ Google sign-in failed: $e');
      rethrow;
    }
  }
  
  // ===========================================================================
  // EMAIL/PASSWORD SIGN-IN
  // ===========================================================================
  
  /// Sign in with email and password
  Future<UserProfile?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save session
      await _saveSession(userCredential.user!);
      
      // Get profile
      final profile = await _createOrUpdateProfile(userCredential.user!);
      
      print('✅ Email sign-in successful: ${profile.name}');
      return profile;
    } catch (e) {
      print('❌ Email sign-in failed: $e');
      rethrow;
    }
  }
  
  // ===========================================================================
  // EMAIL/PASSWORD SIGN-UP
  // ===========================================================================
  
  /// Sign up with email and password
  Future<UserProfile?> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }
      
      // Save session
      await _saveSession(userCredential.user!);
      
      // Create profile
      final profile = await _createOrUpdateProfile(userCredential.user!);
      
      print('✅ Sign-up successful: ${profile.name}');
      return profile;
    } catch (e) {
      print('❌ Sign-up failed: $e');
      rethrow;
    }
  }
  
  // ===========================================================================
  // PASSWORD RESET
  // ===========================================================================
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to $email');
    } catch (e) {
      print('❌ Password reset failed: $e');
      rethrow;
    }
  }
  
  // ===========================================================================
  // SIGN OUT
  // ===========================================================================
  
  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _clearSession();
      
      print('✅ Sign-out successful');
    } catch (e) {
      print('❌ Sign-out failed: $e');
      rethrow;
    }
  }
  
  // ===========================================================================
  // SESSION MANAGEMENT
  // ===========================================================================
  
  /// Save session to secure storage
  Future<void> _saveSession(User user) async {
    final token = await user.getIdToken();
    
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _uidKey, value: user.uid);
  }
  
  /// Clear session
  Future<void> _clearSession() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _uidKey);
  }
  
  /// Check if session exists
  Future<bool> hasSession() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null;
  }
  
  /// Get stored UID
  Future<String?> getStoredUid() async {
    return await _secureStorage.read(key: _uidKey);
  }
  
  /// Refresh token silently
  Future<bool> refreshToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      final token = await user.getIdToken(true); // Force refresh
      await _secureStorage.write(key: _tokenKey, value: token);
      
      return true;
    } catch (e) {
      print('❌ Token refresh failed: $e');
      return false;
    }
  }
  
  // ===========================================================================
  // PROFILE MANAGEMENT
  // ===========================================================================
  
  /// Create or update local profile
  Future<UserProfile> _createOrUpdateProfile(User user) async {
    final existingProfile = _profileBox?.get(user.uid);
    
    if (existingProfile != null) {
      // Update existing profile
      existingProfile.name = user.displayName ?? existingProfile.name;
      existingProfile.email = user.email ?? existingProfile.email;
      existingProfile.photoUrl = user.photoURL;
      existingProfile.updateLastSynced();
      
      await existingProfile.save();
      return existingProfile;
    } else {
      // Create new profile
      final profile = UserProfile(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      );
      
      await _profileBox?.put(user.uid, profile);
      return profile;
    }
  }
  
  /// Get current user profile
  UserProfile? getCurrentProfile() {
    final user = currentUser;
    if (user == null) return null;
    
    return _profileBox?.get(user.uid);
  }
  
  /// Update profile
  Future<void> updateProfile(UserProfile profile) async {
    await _profileBox?.put(profile.uid, profile);
  }
}
