/// CampusNav - Feedback Widget
///
/// Reusable widget for collecting user feedback on data accuracy.
/// "Is this information correct?" - Yes/No with optional comment.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/animation_config.dart';

/// Callback when feedback is submitted
typedef FeedbackCallback = void Function(bool isCorrect, String? comment);

class FeedbackWidget extends StatefulWidget {
  /// Type of entity being reviewed (e.g., "Room", "Personnel")
  final String entityType;

  /// Name of the entity being reviewed
  final String entityName;

  /// Entity ID for storing feedback
  final String entityId;

  /// Callback when feedback is submitted
  final FeedbackCallback? onFeedbackSubmitted;

  /// Show expanded form initially
  final bool initiallyExpanded;

  const FeedbackWidget({
    super.key,
    required this.entityType,
    required this.entityName,
    required this.entityId,
    this.onFeedbackSubmitted,
    this.initiallyExpanded = false,
  });

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  bool _isExpanded = false;
  bool? _selectedResponse;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_selectedResponse == null) return;

    setState(() => _isSubmitting = true);

    // Simulate submission delay
    await Future.delayed(AnimationDurations.standard);

    widget.onFeedbackSubmitted?.call(
      _selectedResponse!,
      _commentController.text.isNotEmpty ? _commentController.text : null,
    );

    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _buildThankYouCard();
    }

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.info.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - always visible
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Is this information correct?',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.info,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          AnimatedSize(
            duration: AnimationDurations.standard,
            curve: AnimationCurves.standard,
            child: _isExpanded ? _buildExpandedContent() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),

          // Entity info
          Text(
            '${widget.entityType}: ${widget.entityName}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),

          // Yes/No buttons
          Row(
            children: [
              Expanded(
                child: _buildResponseButton(
                  label: 'Yes, correct',
                  icon: Icons.check_circle,
                  isSelected: _selectedResponse == true,
                  color: AppColors.success,
                  onTap: () => setState(() => _selectedResponse = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResponseButton(
                  label: 'No, incorrect',
                  icon: Icons.cancel,
                  isSelected: _selectedResponse == false,
                  color: AppColors.error,
                  onTap: () => setState(() => _selectedResponse = false),
                ),
              ),
            ],
          ),

          // Comment field (shown when "No" selected)
          if (_selectedResponse == false) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'What\'s incorrect? (optional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
              minLines: 2,
            )
                .animate()
                .fadeIn(duration: AnimationDurations.quick)
                .slideY(begin: -0.1),
          ],

          // Submit button
          if (_selectedResponse != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Feedback'),
              ),
            )
                .animate()
                .fadeIn(duration: AnimationDurations.quick),
          ],
        ],
      ),
    );
  }

  Widget _buildResponseButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.1) : null,
        side: BorderSide(
          color: isSelected ? color : AppColors.textSecondary.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? color : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouCard() {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.success.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Thank you for your feedback!',
                style: AppTextStyles.body.copyWith(color: AppColors.success),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: AnimationDurations.standard)
        .scale(begin: const Offset(0.95, 0.95));
  }
}
