/// CampusNav - Floor Change Confirmation Dialog
///
/// PHASE 3: User confirmation for floor transitions.
///
/// WHY CONFIRMATION NEEDED:
/// - Automatic floor detection is unreliable (barometer drift)
/// - User knows when they took stairs/elevator
/// - Prevents navigation errors from false floor changes

import 'package:flutter/material.dart';

class FloorChangeDialog extends StatelessWidget {
  final String fromFloor;
  final String toFloor;
  final String transitionType; // 'stairs' or 'elevator'
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  
  const FloorChangeDialog({
    super.key,
    required this.fromFloor,
    required this.toFloor,
    required this.transitionType,
    required this.onConfirm,
    required this.onCancel,
  });
  
  @override
  Widget build(BuildContext context) {
    final icon = transitionType == 'stairs' 
        ? Icons.stairs 
        : Icons.elevator;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          const Text('Floor Change Detected'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Did you just take the $transitionType?',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFloorBadge(fromFloor, Colors.grey),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                _buildFloorBadge(toFloor, Theme.of(context).primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Confirm to update your floor location.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('No, Cancel'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Yes, Confirm'),
        ),
      ],
    );
  }
  
  Widget _buildFloorBadge(String floor, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        floor.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
  
  /// Show floor change confirmation dialog
  static Future<bool> show(
    BuildContext context, {
    required String fromFloor,
    required String toFloor,
    required String transitionType,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FloorChangeDialog(
        fromFloor: fromFloor,
        toFloor: toFloor,
        transitionType: transitionType,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    
    return result ?? false;
  }
}
