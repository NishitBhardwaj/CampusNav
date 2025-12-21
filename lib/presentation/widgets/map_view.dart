/// CampusNav - Map View Widget
///
/// Reusable widget for displaying floor plan maps with markers and paths.

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/node.dart';
import '../../domain/entities/path.dart' as domain;

class MapView extends StatefulWidget {
  final String? floorId;
  final List<Node>? nodes;
  final domain.Path? activePath;
  final double? currentX;
  final double? currentY;
  final double? destinationX;
  final double? destinationY;
  final void Function(double x, double y)? onTap;

  const MapView({
    super.key,
    this.floorId,
    this.nodes,
    this.activePath,
    this.currentX,
    this.currentY,
    this.destinationX,
    this.destinationY,
    this.onTap,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _centerOnPosition(double x, double y) {
    // TODO: Animate to center on position
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformController,
      minScale: 0.5,
      maxScale: 4.0,
      child: GestureDetector(
        onTapUp: (details) {
          if (widget.onTap != null) {
            final localPosition = details.localPosition;
            widget.onTap!(localPosition.dx, localPosition.dy);
          }
        },
        child: CustomPaint(
          painter: _MapPainter(
            nodes: widget.nodes ?? [],
            activePath: widget.activePath,
            currentX: widget.currentX,
            currentY: widget.currentY,
            destinationX: widget.destinationX,
            destinationY: widget.destinationY,
          ),
          size: const Size(800, 600),
        ),
      ),
    );
  }
}

/// Custom painter for map rendering
class _MapPainter extends CustomPainter {
  final List<Node> nodes;
  final domain.Path? activePath;
  final double? currentX;
  final double? currentY;
  final double? destinationX;
  final double? destinationY;

  _MapPainter({
    required this.nodes,
    this.activePath,
    this.currentX,
    this.currentY,
    this.destinationX,
    this.destinationY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw background grid
    paint.color = Colors.grey.withOpacity(0.2);
    paint.strokeWidth = 1;
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw path if active
    if (activePath != null && activePath!.nodes.length > 1) {
      paint.color = AppColors.pathColor;
      paint.strokeWidth = 4;
      paint.style = PaintingStyle.stroke;

      final pathNodes = activePath!.nodes;
      for (int i = 0; i < pathNodes.length - 1; i++) {
        canvas.drawLine(
          Offset(pathNodes[i].x, pathNodes[i].y),
          Offset(pathNodes[i + 1].x, pathNodes[i + 1].y),
          paint,
        );
      }
    }

    // Draw nodes
    paint.style = PaintingStyle.fill;
    for (final node in nodes) {
      paint.color = node.isFloorConnector
          ? AppColors.warning
          : AppColors.textSecondary.withOpacity(0.3);
      canvas.drawCircle(Offset(node.x, node.y), 4, paint);
    }

    // Draw current location marker
    if (currentX != null && currentY != null) {
      paint.color = AppColors.currentLocation;
      canvas.drawCircle(Offset(currentX!, currentY!), 12, paint);

      // Inner white dot
      paint.color = Colors.white;
      canvas.drawCircle(Offset(currentX!, currentY!), 6, paint);
    }

    // Draw destination marker
    if (destinationX != null && destinationY != null) {
      paint.color = AppColors.destination;
      canvas.drawCircle(Offset(destinationX!, destinationY!), 10, paint);

      // Pin shape
      final path = Path();
      path.moveTo(destinationX!, destinationY! - 25);
      path.lineTo(destinationX! - 8, destinationY! - 10);
      path.quadraticBezierTo(
        destinationX!,
        destinationY!,
        destinationX! + 8,
        destinationY! - 10,
      );
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.currentX != currentX ||
        oldDelegate.currentY != currentY ||
        oldDelegate.activePath != activePath;
  }
}
