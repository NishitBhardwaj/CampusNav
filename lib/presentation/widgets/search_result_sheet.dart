/// CampusNav - Search Result Sheet
///
/// Bottom sheet showing detailed search result with:
/// - Location info and navigation option
/// - "Is this correct?" feedback prompt
/// - Last updated timestamp for transparency

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/animation_config.dart';
import '../../data/models/search_index.dart';
import '../../data/models/user_feedback.dart';
import '../state/feedback_provider.dart';
import 'feedback_widget.dart';

class SearchResultSheet extends ConsumerStatefulWidget {
  final SearchResult result;

  const SearchResultSheet({
    super.key,
    required this.result,
  });

  @override
  ConsumerState<SearchResultSheet> createState() => _SearchResultSheetState();
}

class _SearchResultSheetState extends ConsumerState<SearchResultSheet> {
  bool _showFeedback = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.result.entry;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildTypeIcon(entry.entityType),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.displayTitle,
                              style: AppTextStyles.heading2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.entityTypeLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: _getEntityColor(entry.entityType),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Location details
                _buildInfoSection(entry),

                // Last updated (transparency)
                _buildLastUpdated(entry),

                const Divider(height: 1),

                // Navigation button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startNavigation,
                      icon: const Icon(Icons.navigation),
                      label: const Text('Navigate Here'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: AnimationDurations.standard),

                // Feedback section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: FeedbackWidget(
                    entityType: entry.entityTypeLabel,
                    entityName: entry.displayTitle,
                    entityId: entry.entityId,
                    onFeedbackSubmitted: _onFeedbackSubmitted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeIcon(SearchEntityType type) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _getEntityColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        _getEntityIcon(type),
        color: _getEntityColor(type),
        size: 28,
      ),
    )
        .animate()
        .fadeIn(duration: AnimationDurations.standard)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildInfoSection(SearchIndexEntry entry) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (entry.buildingName != null)
            _buildInfoRow(Icons.business, 'Building', entry.buildingName!),
          if (entry.floorName != null)
            _buildInfoRow(Icons.layers, 'Floor', entry.floorName!),
          if (entry.roomNumber != null)
            _buildInfoRow(Icons.door_front_door, 'Room', entry.roomNumber!),
          if (entry.secondaryText != null)
            _buildInfoRow(Icons.info_outline, 'Info', entry.secondaryText!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall,
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(SearchIndexEntry entry) {
    final updated = entry.lastUpdated;
    final formattedDate =
        '${updated.day}/${updated.month}/${updated.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.update,
            size: 14,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(width: 6),
          Text(
            'Last verified: $formattedDate',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const Spacer(),
          Text(
            'v${entry.dataVersion}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _startNavigation() {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(
      '/navigation',
      arguments: widget.result.entry,
    );
  }

  void _onFeedbackSubmitted(bool isCorrect, String? comment) async {
    final entry = widget.result.entry;

    await ref.read(feedbackProvider.notifier).submitFeedback(
      type: FeedbackType.dataAccuracy,
      entityType: entry.entityTypeLabel.toLowerCase(),
      entityId: entry.entityId,
      isCorrect: isCorrect,
      comment: comment,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  IconData _getEntityIcon(SearchEntityType type) {
    switch (type) {
      case SearchEntityType.room:
        return Icons.meeting_room;
      case SearchEntityType.personnel:
        return Icons.person;
      case SearchEntityType.department:
        return Icons.account_tree;
      case SearchEntityType.building:
        return Icons.business;
    }
  }

  Color _getEntityColor(SearchEntityType type) {
    switch (type) {
      case SearchEntityType.room:
        return AppColors.primary;
      case SearchEntityType.personnel:
        return AppColors.accent;
      case SearchEntityType.department:
        return AppColors.warning;
      case SearchEntityType.building:
        return AppColors.success;
    }
  }
}
