/// CampusNav - AI Suggestion Chips
///
/// Displays autocomplete suggestions as tappable chips.
/// Provides quick access to common search terms.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/animation_config.dart';

class AiSuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  const AiSuggestionChips({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: AppColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                'Suggestions',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.asMap().entries.map((entry) {
              return _buildChip(entry.value, entry.key);
            }).toList(),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AnimationDurations.quick);
  }

  Widget _buildChip(String suggestion, int index) {
    return ActionChip(
      label: Text(suggestion),
      labelStyle: TextStyle(
        fontSize: 13,
        color: AppColors.primary,
      ),
      backgroundColor: AppColors.primaryLight.withOpacity(0.3),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: () => onSuggestionTap(suggestion),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: AnimationDurations.quick,
        )
        .scale(begin: const Offset(0.9, 0.9));
  }
}

// =============================================================================
// QUICK ACTION CHIPS
// =============================================================================

/// Predefined quick search actions
class QuickSearchChips extends StatelessWidget {
  final Function(String) onTap;

  const QuickSearchChips({super.key, required this.onTap});

  static const List<_QuickAction> _actions = [
    _QuickAction(Icons.wc, 'Restroom'),
    _QuickAction(Icons.local_cafe, 'Cafeteria'),
    _QuickAction(Icons.local_library, 'Library'),
    _QuickAction(Icons.exit_to_app, 'Exit'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Search',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _actions.map((action) {
              return _buildQuickAction(action);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(_QuickAction action) {
    return InkWell(
      onTap: () => onTap(action.label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action.icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;

  const _QuickAction(this.icon, this.label);
}
