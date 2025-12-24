/// CampusNav - Feedback Report Entity
///
/// PHASE 5: User feedback for human-in-the-loop AI training.

import 'package:hive/hive.dart';

part 'feedback_report.g.dart';

@HiveType(typeId: 6)
class FeedbackReport extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  FeedbackType type;
  
  @HiveField(2)
  String targetId; // ID of room/person/location being reported
  
  @HiveField(3)
  String targetName;
  
  @HiveField(4)
  String issue; // What's wrong
  
  @HiveField(5)
  String? suggestedCorrection;
  
  @HiveField(6)
  FeedbackStatus status;
  
  @HiveField(7)
  String? adminNotes;
  
  @HiveField(8)
  DateTime createdAt;
  
  @HiveField(9)
  DateTime? reviewedAt;
  
  @HiveField(10)
  String? reviewedBy;
  
  FeedbackReport({
    required this.id,
    required this.type,
    required this.targetId,
    required this.targetName,
    required this.issue,
    this.suggestedCorrection,
    this.status = FeedbackStatus.PENDING,
    this.adminNotes,
    DateTime? createdAt,
    this.reviewedAt,
    this.reviewedBy,
  }) : createdAt = createdAt ?? DateTime.now();
  
  FeedbackReport copyWith({
    FeedbackStatus? status,
    String? adminNotes,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return FeedbackReport(
      id: id,
      type: type,
      targetId: targetId,
      targetName: targetName,
      issue: issue,
      suggestedCorrection: suggestedCorrection,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }
  
  @override
  String toString() => 'FeedbackReport($type: $targetName - $status)';
}

@HiveType(typeId: 7)
enum FeedbackType {
  @HiveField(0)
  INCORRECT_LOCATION,
  
  @HiveField(1)
  INCORRECT_PERSON,
  
  @HiveField(2)
  OUTDATED_INFO,
  
  @HiveField(3)
  MISSING_DATA,
  
  @HiveField(4)
  OTHER,
}

@HiveType(typeId: 8)
enum FeedbackStatus {
  @HiveField(0)
  PENDING,
  
  @HiveField(1)
  APPROVED,
  
  @HiveField(2)
  REJECTED,
  
  @HiveField(3)
  NEEDS_CHECK, // Requires on-ground verification
}
