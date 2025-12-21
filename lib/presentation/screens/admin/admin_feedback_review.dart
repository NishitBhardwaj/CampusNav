/// CampusNav - Admin Feedback Review Screen
///
/// Allows admins to review, approve, or dismiss user feedback.
/// Implements human-in-the-loop data verification.
///
/// ============================================================================
/// HUMAN-IN-THE-LOOP LEARNING - NOT REINFORCEMENT LEARNING
/// ============================================================================
///
/// This screen is the critical control point where HUMANS (admins) decide
/// whether to accept or reject suggested changes. Unlike RL systems where
/// feedback automatically adjusts model weights, here:
///
/// 1. Each feedback item is individually reviewed
/// 2. Admin makes explicit approve/reject decision
/// 3. Approved changes are applied as data updates, not model updates
/// 4. Full audit trail is maintained
///
/// This ensures data integrity and accountability.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/animation_config.dart';
import '../../../data/models/user_feedback.dart';
import '../../state/feedback_provider.dart';
import '../../state/auth_provider.dart';

class AdminFeedbackReviewScreen extends ConsumerStatefulWidget {
  const AdminFeedbackReviewScreen({super.key});

  @override
  ConsumerState<AdminFeedbackReviewScreen> createState() =>
      _AdminFeedbackReviewScreenState();
}

class _AdminFeedbackReviewScreenState
    extends ConsumerState<AdminFeedbackReviewScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize feedback data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedbackProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final feedbackState = ref.watch(feedbackProvider);

    if (!isAdmin) {
      return _buildAccessDenied(context);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Review Feedback'),
        backgroundColor: AppColors.accent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(feedbackProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats header
          if (feedbackState.stats != null) _buildStatsHeader(feedbackState.stats!),

          // Pending feedback list
          Expanded(
            child: feedbackState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : feedbackState.pendingFeedback.isEmpty
                    ? _buildEmptyState()
                    : _buildFeedbackList(feedbackState.pendingFeedback),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Denied')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Admin access required', style: AppTextStyles.heading3),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(FeedbackStats stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Pending', stats.pending, AppColors.warning),
          _buildStatItem('Resolved', stats.resolved, AppColors.success),
          _buildStatItem('Dismissed', stats.dismissed, AppColors.textSecondary),
          _buildStatItem(
            'Accuracy',
            '${stats.accuracyRate.toStringAsFixed(0)}%',
            AppColors.primary,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AnimationDurations.standard);
  }

  Widget _buildStatItem(String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending feedback to review',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList(List<UserFeedbackHive> feedback) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: feedback.length,
      itemBuilder: (context, index) {
        return _buildFeedbackCard(feedback[index], index);
      },
    );
  }

  Widget _buildFeedbackCard(UserFeedbackHive feedback, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: feedback.isCorrect
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feedback.isCorrect ? Icons.check : Icons.close,
                    color: feedback.isCorrect
                        ? AppColors.success
                        : AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.typeDisplayName,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${feedback.entityType ?? "Unknown"} • ${_formatDate(feedback.createdAt)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(feedback.status),
              ],
            ),

            // User response
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feedback.isCorrect
                        ? 'User confirmed: CORRECT'
                        : 'User reported: INCORRECT',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (feedback.comment != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"${feedback.comment}"',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showDismissDialog(feedback),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Dismiss'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _handleApprove(feedback),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: AnimationDurations.standard,
        )
        .slideX(begin: 0.05);
  }

  Widget _buildStatusBadge(FeedbackStatus status) {
    Color color;
    String text;

    switch (status) {
      case FeedbackStatus.pending:
        color = AppColors.warning;
        text = 'Pending';
        break;
      case FeedbackStatus.reviewed:
        color = AppColors.info;
        text = 'Reviewing';
        break;
      case FeedbackStatus.resolved:
        color = AppColors.success;
        text = 'Resolved';
        break;
      case FeedbackStatus.dismissed:
        color = AppColors.textSecondary;
        text = 'Dismissed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleApprove(UserFeedbackHive feedback) async {
    final currentUser = ref.read(currentUserProvider);

    final success = await ref.read(feedbackProvider.notifier).approveFeedback(
      feedback.id,
      currentUser.id,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback approved - data will be updated'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showDismissDialog(UserFeedbackHive feedback) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dismiss Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Provide a reason (optional):'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for dismissal...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final currentUser = ref.read(currentUserProvider);

              await ref.read(feedbackProvider.notifier).dismissFeedback(
                feedback.id,
                currentUser.id,
                reason: reasonController.text.isNotEmpty
                    ? reasonController.text
                    : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}
