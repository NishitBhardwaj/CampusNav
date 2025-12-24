/// CampusNav - Sync Queue Entity
///
/// PHASE 5: Queue for pending backend synchronization.
///
/// FUTURE: Spring Boot backend integration

import 'package:hive/hive.dart';

part 'sync_queue.g.dart';

@HiveType(typeId: 10)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  SyncOperation operation;
  
  @HiveField(2)
  String entityType; // 'room', 'personnel', 'node', etc.
  
  @HiveField(3)
  String entityId;
  
  @HiveField(4)
  Map<String, dynamic> data;
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  int retryCount;
  
  @HiveField(7)
  SyncStatus status;
  
  SyncQueueItem({
    required this.id,
    required this.operation,
    required this.entityType,
    required this.entityId,
    required this.data,
    DateTime? createdAt,
    this.retryCount = 0,
    this.status = SyncStatus.PENDING,
  }) : createdAt = createdAt ?? DateTime.now();
  
  @override
  String toString() => 'SyncQueueItem($operation $entityType:$entityId - $status)';
}

@HiveType(typeId: 11)
enum SyncOperation {
  @HiveField(0)
  CREATE,
  
  @HiveField(1)
  UPDATE,
  
  @HiveField(2)
  DELETE,
}

@HiveType(typeId: 12)
enum SyncStatus {
  @HiveField(0)
  PENDING,
  
  @HiveField(1)
  IN_PROGRESS,
  
  @HiveField(2)
  COMPLETED,
  
  @HiveField(3)
  FAILED,
}
