/// CampusNav - Sensor Calibration Dialog
///
/// PHASE 6: Help users calibrate compass for better accuracy.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SensorCalibrationDialog extends StatelessWidget {
  final VoidCallback onCalibrate;
  final VoidCallback onSkip;
  
  const SensorCalibrationDialog({
    super.key,
    required this.onCalibrate,
    required this.onSkip,
  });
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.explore, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          const Text('Compass Calibration'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'For better navigation accuracy, calibrate your compass by moving your phone in a figure-8 pattern.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          // Figure-8 animation
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: Figure8Painter(),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .custom(
                duration: 3000.ms,
                builder: (context, value, child) => CustomPaint(
                  painter: Figure8Painter(progress: value),
                  child: child,
                ),
              ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Move your phone smoothly in this pattern for 10 seconds',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onSkip,
          child: const Text('Skip'),
        ),
        ElevatedButton(
          onPressed: onCalibrate,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Start Calibration'),
        ),
      ],
    );
  }
  
  /// Show calibration dialog
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SensorCalibrationDialog(
        onCalibrate: () => Navigator.of(context).pop(true),
        onSkip: () => Navigator.of(context).pop(false),
      ),
    );
    
    return result ?? false;
  }
}

// =============================================================================
// FIGURE-8 PAINTER
// =============================================================================

class Figure8Painter extends CustomPainter {
  final double progress;
  
  Figure8Painter({this.progress = 0.0});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 4;
    
    // Draw figure-8 path
    for (double t = 0; t <= 2 * 3.14159; t += 0.1) {
      final x = centerX + radius * (2 * t.cos()) / (1 + t.sin() * t.sin());
      final y = centerY + radius * (2 * t.cos() * t.sin()) / (1 + t.sin() * t.sin());
      
      if (t == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Draw moving dot
    if (progress > 0) {
      final t = progress * 2 * 3.14159;
      final dotX = centerX + radius * (2 * t.cos()) / (1 + t.sin() * t.sin());
      final dotY = centerY + radius * (2 * t.cos() * t.sin()) / (1 + t.sin() * t.sin());
      
      final dotPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);
    }
  }
  
  @override
  bool shouldRepaint(Figure8Painter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
