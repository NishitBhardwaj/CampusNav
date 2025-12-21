/// CampusNav - User Feedback Model (Hive)
///
/// Data model for user feedback on data accuracy.
/// Enables crowdsourced data verification without AI hallucination.

import 'package:hive/hive.dart';

part 'user_feedback.g.dart';

// =============================================================================
// FEEDBACK TYPE ENUM
// =============================================================================

@HiveType(typeId: 11)
enum FeedbackType {
  @HiveField(0)
  dataAccuracy, // "Is this information correct?"

  @HiveField(1)
  locationError, // Room/location is wrong

  @HiveField(2)
  navigationIssue, // Path was incorrect

  @HiveField(3)
  suggestion, // General suggestion

  @HiveField(4)
  other,
}

// =============================================================================
// FEEDBACK STATUS ENUM
// =============================================================================

@HiveType(typeId: 12)
enum FeedbackStatus {
  @HiveField(0)
  pending, // Awaiting admin review

  @HiveField(1)
  reviewed, // Admin has seen it

  @HiveField(2)
  resolved, // Issue was fixed

  @HiveField(3)
  dismissed, // Marked as invalid
}

// =============================================================================
// USER FEEDBACK MODEL
// =============================================================================

@HiveType(typeId: 5)
class UserFeedbackHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final FeedbackType type;

  @HiveField(2)
  final String? entityType; // "building", "room", "personnel", etc.

  @HiveField(3)
  final String? entityId; // ID of the entity being reported

  @HiveField(4)
  final bool isCorrect; // "Yes" or "No" response

  @HiveField(5)
  final String? comment; // Optional user comment

  @HiveField(6)
  final FeedbackStatus status;

  @HiveField(7)
  final String? userId; // Who submitted (if available)

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime? reviewedAt;

  @HiveField(10)
  final String? reviewedBy; // Admin who reviewed

  @HiveField(11)
  final String? adminNotes;

  UserFeedbackHive({
    required this.id,
    required this.type,
    this.entityType,
    this.entityId,
    required this.isCorrect,
    this.comment,
    this.status = FeedbackStatus.pending,
    this.userId,
    DateTime? createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.adminNotes,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get feedback type display name
  String get typeDisplayName {
    switch (type) {
      case FeedbackType.dataAccuracy:
        return 'Data Accuracy';
      case FeedbackType.locationError:
        return 'Location Error';
      case FeedbackType.navigationIssue:
        return 'Navigation Issue';
      case FeedbackType.suggestion:
        return 'Suggestion';
      case FeedbackType.other:
        return 'Other';
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case FeedbackStatus.pending:
        return 'Pending Review';
      case FeedbackStatus.reviewed:
        return 'Under Review';
      case FeedbackStatus.resolved:
        return 'Resolved';
      case FeedbackStatus.dismissed:
        return 'Dismissed';
    }
  }

  /// Check if feedback is actionable
  bool get isActionable =>
      status == FeedbackStatus.pending || status == FeedbackStatus.reviewed;

  /// Create a copy with updated fields
  UserFeedbackHive copyWith({
    String? id,
    FeedbackType? type,
    String? entityType,
    String? entityId,
    bool? isCorrect,
    String? comment,
    FeedbackStatus? status,
    String? userId,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? adminNotes,
  }) {
    return UserFeedbackHive(
      id: id ?? this.id,
      type: type ?? this.type,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      isCorrect: isCorrect ?? this.isCorrect,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}
