/// CampusNav - Location Initialization Screen
///
/// Screen for initializing user's current location via QR code scanning.
/// This establishes the starting point for navigation.

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LocationInitScreen extends StatefulWidget {
  const LocationInitScreen({super.key});

  @override
  State<LocationInitScreen> createState() => _LocationInitScreenState();
}

class _LocationInitScreenState extends State<LocationInitScreen> {
  bool _isScanning = false;
  String? _scannedLocation;
  String? _errorMessage;

  Future<void> _startQrScan() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    // TODO: Implement actual QR scanning
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isScanning = false;
      _scannedLocation = 'Main Entrance - Ground Floor';
    });

    // Proceed to search screen after successful scan
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pushReplacementNamed('/search');
    }
  }

  void _skipAndUseDemo() {
    // Use demo location for testing
    Navigator.of(context).pushReplacementNamed('/search');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Set Your Location'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Icon
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _scannedLocation != null
                      ? Icons.check_circle_outline
                      : Icons.qr_code_scanner,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                _scannedLocation != null
                    ? 'Location Set!'
                    : 'Scan QR Code',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                _scannedLocation ??
                    'Find a CampusNav QR code on the wall and scan it to set your current location.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              const Spacer(),
              // Scan Button
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _startQrScan,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.qr_code_scanner),
                label: Text(_isScanning ? 'Scanning...' : 'Scan QR Code'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              // Skip Button (for demo)
              TextButton(
                onPressed: _skipAndUseDemo,
                child: const Text('Use Demo Location'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
