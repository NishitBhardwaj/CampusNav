/// CampusNav - Lost Screen
///
/// "I'm Lost" fallback screen for when navigation fails.
/// Provides recovery options: rescan QR, call for help, or manual location.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/animation_config.dart';

class LostScreen extends StatelessWidget {
  const LostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Need Help?'),
        backgroundColor: AppColors.warning,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Lost illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.explore_off,
                  size: 64,
                  color: AppColors.warning,
                ),
              )
                  .animate()
                  .fadeIn(duration: AnimationDurations.medium)
                  .scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 32),

              Text(
                "Don't worry!",
                style: AppTextStyles.heading2,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: AnimationDurations.standard),

              const SizedBox(height: 12),

              Text(
                "We'll help you get back on track",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: AnimationDurations.standard),

              const Spacer(),

              // Recovery options
              _buildRecoveryOption(
                context,
                icon: Icons.qr_code_scanner,
                title: 'Scan Nearby QR',
                subtitle: 'Look for a QR code on the wall',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/location_init'),
              ),

              const SizedBox(height: 12),

              _buildRecoveryOption(
                context,
                icon: Icons.location_searching,
                title: 'Select Landmark',
                subtitle: 'Choose a nearby landmark manually',
                color: AppColors.accent,
                onTap: () => _showLandmarkDialog(context),
              ),

              const SizedBox(height: 12),

              _buildRecoveryOption(
                context,
                icon: Icons.support_agent,
                title: 'Ask for Help',
                subtitle: 'Contact campus support',
                color: AppColors.success,
                onTap: () => _showHelpDialog(context),
              ),

              const SizedBox(height: 24),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                ),
                child: const Text('Return to Home'),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: AnimationDurations.standard)
        .slideX(begin: 0.1);
  }

  void _showLandmarkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Landmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.door_front_door),
              title: const Text('Main Entrance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.stairs),
              title: const Text('Near Staircase'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.elevator),
              title: const Text('Near Elevator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campus Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Security Office'),
            Text(
              'Phone: +91-XXXX-XXXXXX',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Information Desk'),
            Text(
              'Ground Floor, Main Building',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
