/// CampusNav - Feedback Provider (Riverpod)
///
/// State management for the feedback system.
/// Provides reactive updates for feedback submission and admin review.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_feedback.dart';
import '../../data/repositories/feedback_repository.dart';

// =============================================================================
// FEEDBACK STATE
// =============================================================================

class FeedbackState {
  final List<UserFeedbackHive> pendingFeedback;
  final FeedbackStats? stats;
  final bool isLoading;
  final String? error;

  const FeedbackState({
    this.pendingFeedback = const [],
    this.stats,
    this.isLoading = false,
    this.error,
  });

  FeedbackState copyWith({
    List<UserFeedbackHive>? pendingFeedback,
    FeedbackStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return FeedbackState(
      pendingFeedback: pendingFeedback ?? this.pendingFeedback,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// =============================================================================
// FEEDBACK NOTIFIER
// =============================================================================

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  final FeedbackRepository _repository;

  FeedbackNotifier(this._repository) : super(const FeedbackState());

  /// Initialize and load pending feedback
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.initialize();
      await refresh();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize: $e',
      );
    }
  }

  /// Refresh feedback data
  Future<void> refresh() async {
    try {
      final pending = await _repository.getPendingFeedback();
      final stats = await _repository.getStats();

      state = state.copyWith(
        pendingFeedback: pending,
        stats: stats,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load feedback: $e',
      );
    }
  }

  /// Submit new feedback
  Future<bool> submitFeedback({
    required FeedbackType type,
    required String entityType,
    required String entityId,
    required bool isCorrect,
    String? comment,
  }) async {
    try {
      await _repository.submitFeedback(
        type: type,
        entityType: entityType,
        entityId: entityId,
        isCorrect: isCorrect,
        comment: comment,
      );
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to submit feedback: $e');
      return false;
    }
  }

  /// Approve feedback (admin only)
  Future<bool> approveFeedback(String feedbackId, String adminId) async {
    try {
      await _repository.approveFeedback(
        feedbackId: feedbackId,
        adminId: adminId,
      );
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to approve: $e');
      return false;
    }
  }

  /// Dismiss feedback (admin only)
  Future<bool> dismissFeedback(
    String feedbackId,
    String adminId, {
    String? reason,
  }) async {
    try {
      await _repository.dismissFeedback(
        feedbackId: feedbackId,
        adminId: adminId,
        reason: reason,
      );
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to dismiss: $e');
      return false;
    }
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Provider for feedback repository
final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository();
});

/// Provider for feedback state
final feedbackProvider =
    StateNotifierProvider<FeedbackNotifier, FeedbackState>((ref) {
  final repo = ref.watch(feedbackRepositoryProvider);
  return FeedbackNotifier(repo);
});

/// Provider for pending feedback count
final pendingFeedbackCountProvider = Provider<int>((ref) {
  return ref.watch(feedbackProvider).pendingFeedback.length;
});

/// Provider for feedback stats
final feedbackStatsProvider = Provider<FeedbackStats?>((ref) {
  return ref.watch(feedbackProvider).stats;
});
