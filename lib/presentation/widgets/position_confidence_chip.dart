/// CampusNav - Position Confidence Chip Widget
///
/// PHASE 3: Visual indicator for positioning confidence.
///
/// Shows user how reliable their current position is:
/// - HIGH (Green): Trust fully, normal movement
/// - MEDIUM (Orange): Apply corrections, slower updates  
/// - LOW (Red): Freeze or request confirmation

import 'package:flutter/material.dart';
import '../../domain/services/movement_fusion_engine.dart';

class PositionConfidenceChip extends StatelessWidget {
  final PositioningConfidence confidence;
  final bool showPercentage;
  
  const PositionConfidenceChip({
    super.key,
    required this.confidence,
    this.showPercentage = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final (color, icon, label, percent) = _getConfidenceData();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            showPercentage ? '$label ($percent%)' : label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  (Color, IconData, String, int) _getConfidenceData() {
    switch (confidence) {
      case PositioningConfidence.HIGH:
        return (
          Colors.green,
          Icons.gps_fixed,
          'HIGH',
          90,
        );
      case PositioningConfidence.MEDIUM:
        return (
          Colors.orange,
          Icons.gps_not_fixed,
          'MEDIUM',
          65,
        );
      case PositioningConfidence.LOW:
        return (
          Colors.red,
          Icons.gps_off,
          'LOW',
          30,
        );
    }
  }
}
