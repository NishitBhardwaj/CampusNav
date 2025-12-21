/// CampusNav - Direction Indicator Widget
///
/// Widget for displaying directional navigation cues.
/// Shows arrows and instructions for turn-by-turn navigation.

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum DirectionType {
  straight,
  left,
  right,
  slightLeft,
  slightRight,
  uTurn,
  stairs,
  elevator,
  arrived,
}

class DirectionIndicator extends StatelessWidget {
  final DirectionType direction;
  final String instruction;
  final double? distance;
  final bool isHighlighted;

  const DirectionIndicator({
    super.key,
    required this.direction,
    required this.instruction,
    this.distance,
    this.isHighlighted = false,
  });

  IconData get _icon {
    switch (direction) {
      case DirectionType.straight:
        return Icons.arrow_upward;
      case DirectionType.left:
        return Icons.turn_left;
      case DirectionType.right:
        return Icons.turn_right;
      case DirectionType.slightLeft:
        return Icons.turn_slight_left;
      case DirectionType.slightRight:
        return Icons.turn_slight_right;
      case DirectionType.uTurn:
        return Icons.u_turn_left;
      case DirectionType.stairs:
        return Icons.stairs;
      case DirectionType.elevator:
        return Icons.elevator;
      case DirectionType.arrived:
        return Icons.flag;
    }
  }

  Color get _backgroundColor {
    if (isHighlighted) return AppColors.primary;
    if (direction == DirectionType.arrived) return AppColors.success;
    if (direction == DirectionType.stairs ||
        direction == DirectionType.elevator) {
      return AppColors.warning;
    }
    return AppColors.primaryLight;
  }

  Color get _iconColor {
    if (isHighlighted ||
        direction == DirectionType.arrived ||
        direction == DirectionType.stairs ||
        direction == DirectionType.elevator) {
      return Colors.white;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Direction icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _icon,
              size: 32,
              color: _iconColor,
            ),
          ),
          const SizedBox(width: 16),
          // Instruction text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: isHighlighted ? FontWeight.w600 : null,
                  ),
                ),
                if (distance != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${distance!.toStringAsFixed(0)} m',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
