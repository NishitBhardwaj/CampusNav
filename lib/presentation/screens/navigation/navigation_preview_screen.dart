/// CampusNav - Navigation Preview Screen
///
/// Shows route preview before starting active navigation.
/// Displays path summary, estimated time, and floor changes.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/animation_config.dart';
import '../../../data/models/search_index.dart';

class NavigationPreviewScreen extends ConsumerWidget {
  final SearchIndexEntry? destination;

  const NavigationPreviewScreen({super.key, this.destination});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get destination from arguments if not passed directly
    final dest = destination ??
        ModalRoute.of(context)?.settings.arguments as SearchIndexEntry?;

    if (dest == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigation')),
        body: const Center(child: Text('No destination selected')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Route Preview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Route summary card
          _buildRouteSummary(context, dest),

          // Map preview
          Expanded(
            child: _buildMapPreview(dest),
          ),

          // Action buttons
          _buildActionButtons(context, dest),
        ],
      ),
    );
  }

  Widget _buildRouteSummary(BuildContext context, SearchIndexEntry dest) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.destination.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag,
                  color: AppColors.destination,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dest.displayTitle,
                      style: AppTextStyles.heading3,
                    ),
                    Text(
                      dest.displaySubtitle,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // Route stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(Icons.straighten, '~50m', 'Distance'),
              _buildStat(Icons.timer, '~2 min', 'Time'),
              _buildStat(Icons.layers, '1', 'Floors'),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AnimationDurations.medium)
        .slideY(begin: -0.1);
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildMapPreview(SearchIndexEntry dest) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Map placeholder
            Container(
              color: AppColors.primaryLight.withOpacity(0.2),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 64,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Route Preview',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Map will display here',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),

            // Floor indicator
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  dest.floorName ?? 'Ground Floor',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: AnimationDurations.medium);
  }

  Widget _buildActionButtons(BuildContext context, SearchIndexEntry dest) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          // Start navigation
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/navigation',
                  arguments: dest,
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: AnimationDurations.medium)
        .slideY(begin: 0.2);
  }
}
