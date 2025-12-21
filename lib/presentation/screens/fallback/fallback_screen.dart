/// CampusNav - Fallback Screen
///
/// Screen shown when navigation fails or location cannot be determined.
/// Provides options to rescan QR or contact help.

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FallbackScreen extends StatelessWidget {
  final String? errorMessage;

  const FallbackScreen({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Navigation Issue'),
        backgroundColor: AppColors.warning,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              const Text(
                'Unable to Navigate',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Error message
              Text(
                errorMessage ??
                    'We couldn\'t determine your location or find a path to your destination.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Rescan QR button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/location_init');
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Rescan Location'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              // Return to search
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/search');
                },
                icon: const Icon(Icons.search),
                label: const Text('Back to Search'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              // Help text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Need help? Ask at the reception desk.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
