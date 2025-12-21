/// CampusNav - Navigation Screen
///
/// Screen showing active navigation with map view and directions.
/// Displays real-time path and navigation instructions.

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool _isNavigating = true;
  double _progress = 0.0;

  // Mock navigation data
  final String _destination = 'Room 101 - Computer Lab';
  final String _distance = '85 m';
  final String _time = '2 min';
  final String _currentInstruction = 'Continue straight for 20 meters';

  @override
  void initState() {
    super.initState();
    _simulateNavigation();
  }

  void _simulateNavigation() async {
    // Simulate progress for demo
    while (_progress < 1.0 && _isNavigating && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _progress += 0.1;
          if (_progress >= 1.0) {
            Navigator.of(context).pushReplacementNamed('/arrival');
          }
        });
      }
    }
  }

  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
    });
    Navigator.of(context).pop();
  }

  void _recenter() {
    // TODO: Recenter map on current location
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recentering...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map View (placeholder)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 120,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Floor Map View',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress indicator
                  Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Back button
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _stopNavigation,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Recenter button
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _recenter,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.pathColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.navigation,
                          color: AppColors.pathColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _destination,
                              style: AppTextStyles.heading3,
                            ),
                            Text(
                              '$_distance • $_time remaining',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  // Current instruction
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _currentInstruction,
                          style: AppTextStyles.body,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stop Navigation button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _stopNavigation,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Stop Navigation'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
