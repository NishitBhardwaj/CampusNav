/// CampusNav - Storage Stability Service
///
/// PHASE 6: Prevent crashes from storage issues.
///
/// FEATURES:
/// - Auto cleanup stale cached images
/// - Try/catch isolation around DB operations
/// - Read-only fallback mode
/// - Auto-restore on corruption

import 'dart:async';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'backup_restore_service.dart';

// =============================================================================
// STORAGE STABILITY SERVICE
// =============================================================================

class StorageStabilityService {
  final BackupRestoreService _backupService;
  
  bool _isReadOnly = false;
  DateTime? _lastCleanup;
  
  static const Duration cleanupInterval = Duration(days: 7);
  static const int maxCachedImages = 100;
  static const Duration imageCacheExpiry = Duration(days: 30);
  
  bool get isReadOnly => _isReadOnly;
  
  StorageStabilityService({
    required BackupRestoreService backupService,
  }) : _backupService = backupService;
  
  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================
  
  Future<void> initialize() async {
    // Check if cleanup needed
    if (_shouldRunCleanup()) {
      await cleanupStaleCache();
    }
    
    print('💾 Storage stability service initialized');
  }
  
  // ===========================================================================
  // SAFE DB OPERATIONS
  // ===========================================================================
  
  /// Safe write to Hive box
  Future<bool> safeWrite<T>({
    required String boxName,
    required dynamic key,
    required T value,
  }) async {
    if (_isReadOnly) {
      print('⚠️ Storage in read-only mode, write blocked');
      return false;
    }
    
    try {
      final box = await Hive.openBox<T>(boxName);
      await box.put(key, value);
      return true;
    } catch (e) {
      print('❌ Safe write failed: $e');
      await _handleWriteFailure(e);
      return false;
    }
  }
  
  /// Safe read from Hive box
  Future<T?> safeRead<T>({
    required String boxName,
    required dynamic key,
  }) async {
    try {
      final box = await Hive.openBox<T>(boxName);
      return box.get(key);
    } catch (e) {
      print('❌ Safe read failed: $e');
      return null;
    }
  }
  
  /// Safe delete from Hive box
  Future<bool> safeDelete({
    required String boxName,
    required dynamic key,
  }) async {
    if (_isReadOnly) {
      print('⚠️ Storage in read-only mode, delete blocked');
      return false;
    }
    
    try {
      final box = await Hive.openBox(boxName);
      await box.delete(key);
      return true;
    } catch (e) {
      print('❌ Safe delete failed: $e');
      await _handleWriteFailure(e);
      return false;
    }
  }
  
  // ===========================================================================
  // CACHE CLEANUP
  // ===========================================================================
  
  /// Clean up stale cached images
  Future<void> cleanupStaleCache() async {
    try {
      print('🧹 Starting cache cleanup...');
      
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/cache/images');
      
      if (!await cacheDir.exists()) {
        print('✅ No cache to clean');
        return;
      }
      
      final now = DateTime.now();
      int deletedCount = 0;
      
      await for (final file in cacheDir.list()) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);
          
          if (age > imageCacheExpiry) {
            await file.delete();
            deletedCount++;
          }
        }
      }
      
      _lastCleanup = DateTime.now();
      
      print('✅ Cache cleanup complete: $deletedCount files deleted');
    } catch (e) {
      print('❌ Cache cleanup failed: $e');
    }
  }
  
  /// Check if cleanup should run
  bool _shouldRunCleanup() {
    if (_lastCleanup == null) return true;
    
    final timeSinceCleanup = DateTime.now().difference(_lastCleanup!);
    return timeSinceCleanup > cleanupInterval;
  }
  
  // ===========================================================================
  // FAILURE HANDLING
  // ===========================================================================
  
  /// Handle write failure
  Future<void> _handleWriteFailure(dynamic error) async {
    final errorStr = error.toString().toLowerCase();
    
    // Check for DB lock
    if (errorStr.contains('lock') || errorStr.contains('busy')) {
      print('🔒 Database locked, entering read-only mode');
      _isReadOnly = true;
      
      // Try to recover after delay
      Future.delayed(Duration(seconds: 5), () async {
        await _attemptRecovery();
      });
    }
    
    // Check for corruption
    else if (errorStr.contains('corrupt') || errorStr.contains('invalid')) {
      print('💥 Database corruption detected');
      await _handleCorruption();
    }
  }
  
  /// Attempt to recover from read-only mode
  Future<void> _attemptRecovery() async {
    try {
      // Try a test write
      final testBox = await Hive.openBox('test_write');
      await testBox.put('test', DateTime.now().toString());
      await testBox.delete('test');
      
      // Success - exit read-only mode
      _isReadOnly = false;
      print('✅ Recovered from read-only mode');
    } catch (e) {
      print('❌ Recovery failed, staying in read-only mode');
    }
  }
  
  /// Handle database corruption
  Future<void> _handleCorruption() async {
    print('🛡️ Handling database corruption...');
    
    // Get last stable backup
    final lastBackup = await _backupService.getLastStableBackup();
    
    if (lastBackup != null) {
      print('♻️ Restoring from backup: $lastBackup');
      final restored = await _backupService.restoreFromBackup(lastBackup);
      
      if (restored) {
        print('✅ Database restored successfully');
        _isReadOnly = false;
      } else {
        print('❌ Restore failed, entering SafeMode');
        _backupService.enterSafeMode();
        _isReadOnly = true;
      }
    } else {
      print('❌ No backup available, entering SafeMode');
      _backupService.enterSafeMode();
      _isReadOnly = true;
    }
  }
  
  // ===========================================================================
  // STORAGE HEALTH
  // ===========================================================================
  
  /// Get storage health info
  Future<Map<String, dynamic>> getStorageHealth() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = await directory.stat();
      
      return {
        'isReadOnly': _isReadOnly,
        'lastCleanup': _lastCleanup?.toIso8601String(),
        'path': directory.path,
        'exists': await directory.exists(),
      };
    } catch (e) {
      return {
        'isReadOnly': _isReadOnly,
        'error': e.toString(),
      };
    }
  }
}
