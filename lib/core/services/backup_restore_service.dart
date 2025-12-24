/// CampusNav - Backup and Restore Service
///
/// PHASE 5: Fail-safe system for data integrity.
///
/// FEATURES:
/// - Auto-backup after admin changes
/// - Restore from backup on corruption
/// - SafeMode when critical data missing
/// - Version history

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

// =============================================================================
// BACKUP AND RESTORE SERVICE
// =============================================================================

class BackupRestoreService {
  static const int maxBackups = 10; // Keep last 10 backups
  
  bool _isInSafeMode = false;
  
  bool get isInSafeMode => _isInSafeMode;
  
  // ===========================================================================
  // BACKUP CREATION
  // ===========================================================================
  
  /// Create backup of all Hive boxes
  Future<String?> createBackup({String? description}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupId = 'backup_$timestamp';
      
      print('💾 Creating backup: $backupId');
      
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      final backupFile = File('${backupDir.path}/$backupId.json');
      
      // Collect data from all boxes
      final backupData = {
        'id': backupId,
        'timestamp': timestamp,
        'description': description ?? 'Auto-backup',
        'data': await _collectAllData(),
      };
      
      await backupFile.writeAsString(jsonEncode(backupData));
      
      // Clean old backups
      await _cleanOldBackups(backupDir);
      
      print('✅ Backup created: ${backupFile.path}');
      return backupId;
    } catch (e) {
      print('❌ Backup failed: $e');
      return null;
    }
  }
  
  /// Collect data from all Hive boxes
  Future<Map<String, dynamic>> _collectAllData() async {
    final data = <String, dynamic>{};
    
    // List of boxes to backup
    final boxNames = [
      'rooms',
      'personnel',
      'navigation_nodes',
      'navigation_edges',
      'feedback_reports',
      'data_versions',
      'system_config',
    ];
    
    for (final boxName in boxNames) {
      try {
        final box = await Hive.openBox(boxName);
        data[boxName] = box.toMap();
      } catch (e) {
        print('⚠️ Could not backup box: $boxName - $e');
      }
    }
    
    return data;
  }
  
  // ===========================================================================
  // BACKUP RESTORATION
  // ===========================================================================
  
  /// Restore from backup
  Future<bool> restoreFromBackup(String backupId) async {
    try {
      print('♻️ Restoring from backup: $backupId');
      
      final directory = await getApplicationDocumentsDirectory();
      final backupFile = File('${directory.path}/backups/$backupId.json');
      
      if (!await backupFile.exists()) {
        print('❌ Backup file not found: $backupId');
        return false;
      }
      
      final backupJson = await backupFile.readAsString();
      final backupData = jsonDecode(backupJson);
      
      // Restore each box
      final data = backupData['data'] as Map<String, dynamic>;
      
      for (final entry in data.entries) {
        await _restoreBox(entry.key, entry.value);
      }
      
      _isInSafeMode = false;
      
      print('✅ Restore complete from: $backupId');
      return true;
    } catch (e) {
      print('❌ Restore failed: $e');
      return false;
    }
  }
  
  /// Restore a single box
  Future<void> _restoreBox(String boxName, dynamic boxData) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.clear();
      
      if (boxData is Map) {
        for (final entry in boxData.entries) {
          await box.put(entry.key, entry.value);
        }
      }
      
      print('✅ Restored box: $boxName');
    } catch (e) {
      print('❌ Failed to restore box: $boxName - $e');
    }
  }
  
  // ===========================================================================
  // BACKUP MANAGEMENT
  // ===========================================================================
  
  /// Get list of available backups
  Future<List<Map<String, dynamic>>> getAvailableBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        return [];
      }
      
      final backups = <Map<String, dynamic>>[];
      
      await for (final file in backupDir.list()) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final content = await file.readAsString();
            final data = jsonDecode(content);
            
            backups.add({
              'id': data['id'],
              'timestamp': data['timestamp'],
              'description': data['description'],
              'date': DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
            });
          } catch (e) {
            print('⚠️ Could not read backup file: ${file.path}');
          }
        }
      }
      
      // Sort by timestamp (newest first)
      backups.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      
      return backups;
    } catch (e) {
      print('❌ Failed to list backups: $e');
      return [];
    }
  }
  
  /// Clean old backups (keep only last N)
  Future<void> _cleanOldBackups(Directory backupDir) async {
    final backups = await getAvailableBackups();
    
    if (backups.length > maxBackups) {
      final toDelete = backups.skip(maxBackups);
      
      for (final backup in toDelete) {
        final file = File('${backupDir.path}/${backup['id']}.json');
        if (await file.exists()) {
          await file.delete();
          print('🗑️ Deleted old backup: ${backup['id']}');
        }
      }
    }
  }
  
  // ===========================================================================
  // SAFE MODE
  // ===========================================================================
  
  /// Check for critical data corruption
  Future<bool> checkDataIntegrity() async {
    try {
      // Check if essential boxes exist and have data
      final essentialBoxes = ['rooms', 'personnel', 'navigation_nodes'];
      
      for (final boxName in essentialBoxes) {
        final box = await Hive.openBox(boxName);
        
        if (box.isEmpty) {
          print('⚠️ Critical box is empty: $boxName');
          _isInSafeMode = true;
          return false;
        }
      }
      
      _isInSafeMode = false;
      return true;
    } catch (e) {
      print('❌ Data integrity check failed: $e');
      _isInSafeMode = true;
      return false;
    }
  }
  
  /// Enter safe mode
  void enterSafeMode() {
    _isInSafeMode = true;
    print('🛡️ Entered SafeMode - critical data missing');
  }
  
  /// Exit safe mode
  void exitSafeMode() {
    _isInSafeMode = false;
    print('✅ Exited SafeMode');
  }
  
  /// Get last stable backup
  Future<String?> getLastStableBackup() async {
    final backups = await getAvailableBackups();
    return backups.isNotEmpty ? backups.first['id'] : null;
  }
}
