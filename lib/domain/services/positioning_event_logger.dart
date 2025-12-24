/// CampusNav - Positioning Event Logger
///
/// PHASE 3: Local logging of positioning events for debugging.
///
/// LOGGED EVENTS:
/// - Mode changes (Smart → Assisted → Manual)
/// - QR resets
/// - Visual landmark overrides
/// - Sensor failures
/// - Position corrections
///
/// STORAGE: Local file for admin debugging

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// =============================================================================
// POSITIONING LOG ENTRY
// =============================================================================

class PositioningLogEntry {
  final String eventType;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  
  PositioningLogEntry({
    required this.eventType,
    required this.message,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
  
  @override
  String toString() => '${timestamp.toIso8601String()} [$eventType] $message';
}

// =============================================================================
// POSITIONING EVENT LOGGER
// =============================================================================

class PositioningEventLogger {
  final List<PositioningLogEntry> _entries = [];
  static const int maxEntries = 1000;
  
  File? _logFile;
  bool _isInitialized = false;
  
  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================
  
  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/positioning_log.txt');
      _isInitialized = true;
      
      print('📝 Positioning logger initialized: ${_logFile!.path}');
    } catch (e) {
      print('❌ Failed to initialize logger: $e');
    }
  }
  
  // ===========================================================================
  // LOGGING
  // ===========================================================================
  
  /// Log a positioning event
  void log(String eventType, String message, {Map<String, dynamic>? metadata}) {
    final entry = PositioningLogEntry(
      eventType: eventType,
      message: message,
      metadata: metadata,
    );
    
    _entries.add(entry);
    
    // Limit entries to prevent memory issues
    if (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
    
    // Write to file asynchronously
    _writeToFile(entry);
    
    // Also print to console for debugging
    print('📍 $entry');
  }
  
  /// Write entry to log file
  Future<void> _writeToFile(PositioningLogEntry entry) async {
    if (!_isInitialized || _logFile == null) return;
    
    try {
      await _logFile!.writeAsString(
        '${entry.toString()}\n',
        mode: FileMode.append,
      );
    } catch (e) {
      print('❌ Failed to write log: $e');
    }
  }
  
  // ===========================================================================
  // RETRIEVAL
  // ===========================================================================
  
  /// Get all log entries
  List<PositioningLogEntry> getEntries() => List.unmodifiable(_entries);
  
  /// Get entries by type
  List<PositioningLogEntry> getEntriesByType(String eventType) {
    return _entries.where((e) => e.eventType == eventType).toList();
  }
  
  /// Get recent entries
  List<PositioningLogEntry> getRecentEntries(int count) {
    final start = _entries.length - count;
    if (start < 0) return _entries;
    return _entries.sublist(start);
  }
  
  // ===========================================================================
  // EXPORT
  // ===========================================================================
  
  /// Export log as JSON
  Future<String> exportAsJson() async {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'entryCount': _entries.length,
      'entries': _entries.map((e) => e.toJson()).toList(),
    };
    
    return jsonEncode(data);
  }
  
  /// Export log to file
  Future<File?> exportToFile() async {
    if (!_isInitialized) return null;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportFile = File(
        '${directory.path}/positioning_log_export_${DateTime.now().millisecondsSinceEpoch}.json'
      );
      
      final jsonData = await exportAsJson();
      await exportFile.writeAsString(jsonData);
      
      print('📤 Log exported to: ${exportFile.path}');
      return exportFile;
    } catch (e) {
      print('❌ Failed to export log: $e');
      return null;
    }
  }
  
  // ===========================================================================
  // MANAGEMENT
  // ===========================================================================
  
  /// Clear all log entries
  void clear() {
    _entries.clear();
    print('🗑️ Log cleared');
  }
  
  /// Clear log file
  Future<void> clearFile() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.delete();
      await _logFile!.create();
      print('🗑️ Log file cleared');
    }
  }
}

// =============================================================================
// GLOBAL LOGGER INSTANCE
// =============================================================================

final positioningLogger = PositioningEventLogger();
