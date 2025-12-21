/// CampusNav - Feedback Repository
///
/// Manages storage and retrieval of user feedback.
/// Implements the human-in-the-loop learning pattern.
///
/// ============================================================================
/// HUMAN-IN-THE-LOOP DESIGN
/// ============================================================================
///
/// This is NOT reinforcement learning. Key differences:
///
/// 1. FEEDBACK IS STORED, NOT APPLIED: User feedback is queued for admin review.
///    The system does not automatically learn from feedback.
///
/// 2. ADMIN VERIFICATION: Only admins can approve corrections. This maintains
///    data integrity and prevents malicious or incorrect changes.
///
/// 3. EXPLICIT UPDATES: When admin approves, the change is explicitly applied
///    to the data model, not learned through optimization.
///
/// 4. AUDIT TRAIL: Every feedback and action is logged. We know exactly what
///    changed, when, and who approved it.
///
/// ============================================================================

import 'package:hive/hive.dart';
import '../models/user_feedback.dart';

// =============================================================================
// FEEDBACK REPOSITORY
// =============================================================================

class FeedbackRepository {
  static const String _boxName = 'user_feedback';
  Box<UserFeedbackHive>? _box;

  /// Initialize the repository
  Future<void> initialize() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<UserFeedbackHive>(_boxName);
    }
  }

  /// Ensure box is open
  Future<Box<UserFeedbackHive>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
    return _box!;
  }

  // ===========================================================================
  // USER OPERATIONS
  // ===========================================================================

  /// Submit new feedback from user
  Future<void> submitFeedback({
    required FeedbackType type,
    required String entityType,
    required String entityId,
    required bool isCorrect,
    String? comment,
    String? suggestedCorrection,
    String? correctionField,
  }) async {
    final box = await _getBox();

    final feedback = UserFeedbackHive(
      id: _generateId(),
      type: type,
      entityType: entityType,
      entityId: entityId,
      isCorrect: isCorrect,
      comment: comment,
      status: FeedbackStatus.pending,
      createdAt: DateTime.now(),
    );

    await box.put(feedback.id, feedback);
  }

  /// Get user's submitted feedback
  Future<List<UserFeedbackHive>> getUserFeedback({String? userId}) async {
    final box = await _getBox();
    return box.values.where((f) => f.userId == userId).toList();
  }

  // ===========================================================================
  // ADMIN OPERATIONS
  // ===========================================================================

  /// Get all pending feedback for admin review
  Future<List<UserFeedbackHive>> getPendingFeedback() async {
    final box = await _getBox();
    return box.values
        .where((f) => f.status == FeedbackStatus.pending)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get feedback statistics
  Future<FeedbackStats> getStats() async {
    final box = await _getBox();
    final all = box.values.toList();

    return FeedbackStats(
      total: all.length,
      pending: all.where((f) => f.status == FeedbackStatus.pending).length,
      reviewed: all.where((f) => f.status == FeedbackStatus.reviewed).length,
      resolved: all.where((f) => f.status == FeedbackStatus.resolved).length,
      dismissed: all.where((f) => f.status == FeedbackStatus.dismissed).length,
      correctCount: all.where((f) => f.isCorrect).length,
      incorrectCount: all.where((f) => !f.isCorrect).length,
    );
  }

  /// Approve feedback and mark as resolved
  /// This triggers an update to the source data
  Future<void> approveFeedback({
    required String feedbackId,
    required String adminId,
    String? adminNotes,
  }) async {
    final box = await _getBox();
    final feedback = box.get(feedbackId);

    if (feedback != null) {
      final updated = feedback.copyWith(
        status: FeedbackStatus.resolved,
        reviewedAt: DateTime.now(),
        reviewedBy: adminId,
        adminNotes: adminNotes,
      );
      await box.put(feedbackId, updated);

      // TODO: Trigger actual data update based on feedback
      // This would call the appropriate repository to update the entity
    }
  }

  /// Reject/dismiss feedback
  Future<void> dismissFeedback({
    required String feedbackId,
    required String adminId,
    String? reason,
  }) async {
    final box = await _getBox();
    final feedback = box.get(feedbackId);

    if (feedback != null) {
      final updated = feedback.copyWith(
        status: FeedbackStatus.dismissed,
        reviewedAt: DateTime.now(),
        reviewedBy: adminId,
        adminNotes: reason,
      );
      await box.put(feedbackId, updated);
    }
  }

  /// Mark feedback as reviewed (but not yet resolved)
  Future<void> markAsReviewed({
    required String feedbackId,
    required String adminId,
  }) async {
    final box = await _getBox();
    final feedback = box.get(feedbackId);

    if (feedback != null) {
      final updated = feedback.copyWith(
        status: FeedbackStatus.reviewed,
        reviewedAt: DateTime.now(),
        reviewedBy: adminId,
      );
      await box.put(feedbackId, updated);
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  String _generateId() {
    return 'fb_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Clear all feedback (for testing)
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}

// =============================================================================
// FEEDBACK STATISTICS
// =============================================================================

class FeedbackStats {
  final int total;
  final int pending;
  final int reviewed;
  final int resolved;
  final int dismissed;
  final int correctCount;
  final int incorrectCount;

  FeedbackStats({
    required this.total,
    required this.pending,
    required this.reviewed,
    required this.resolved,
    required this.dismissed,
    required this.correctCount,
    required this.incorrectCount,
  });

  /// Percentage of "correct" feedback
  double get accuracyRate {
    if (total == 0) return 100.0;
    return (correctCount / total) * 100;
  }
}
