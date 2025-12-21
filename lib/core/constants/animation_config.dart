/// CampusNav - Animation Configuration
///
/// Centralized animation constants for consistent UI transitions.
/// All animations are designed to be lightweight and smooth.

import 'package:flutter/material.dart';

// =============================================================================
// ANIMATION DURATIONS
// =============================================================================

/// Standard animation durations used throughout the app
class AnimationDurations {
  /// Quick micro-interactions (button press, icon change)
  static const Duration quick = Duration(milliseconds: 150);

  /// Standard transitions (page elements, cards)
  static const Duration standard = Duration(milliseconds: 300);

  /// Medium transitions (modal, bottom sheet)
  static const Duration medium = Duration(milliseconds: 450);

  /// Slow transitions (splash, major screen changes)
  static const Duration slow = Duration(milliseconds: 600);

  /// Long animations (onboarding, celebrations)
  static const Duration long = Duration(milliseconds: 1000);

  /// Splash screen duration
  static const Duration splash = Duration(milliseconds: 2500);
}

// =============================================================================
// ANIMATION CURVES
// =============================================================================

/// Standard animation curves for consistent motion
class AnimationCurves {
  /// Default ease for most animations
  static const Curve standard = Curves.easeInOut;

  /// Enter/appear animations
  static const Curve enter = Curves.easeOut;

  /// Exit/disappear animations
  static const Curve exit = Curves.easeIn;

  /// Bouncy, playful motion
  static const Curve bounce = Curves.elasticOut;

  /// Smooth deceleration
  static const Curve decelerate = Curves.decelerate;

  /// Spring-like motion
  static const Curve spring = Curves.easeOutBack;
}

// =============================================================================
// STAGGER DELAYS
// =============================================================================

/// Delays for staggered list animations
class StaggerDelays {
  /// Delay between list items
  static const Duration listItem = Duration(milliseconds: 50);

  /// Delay between card animations
  static const Duration card = Duration(milliseconds: 100);

  /// Delay between sections
  static const Duration section = Duration(milliseconds: 150);
}

// =============================================================================
// LOTTIE ASSETS
// =============================================================================

/// Paths to Lottie animation files
class LottieAssets {
  static const String basePath = 'assets/animations/';

  /// Splash screen loading animation
  static const String splash = '${basePath}splash_loading.json';

  /// Navigation arrow/compass
  static const String navigation = '${basePath}navigation.json';

  /// Success checkmark
  static const String success = '${basePath}success.json';

  /// Loading spinner
  static const String loading = '${basePath}loading.json';

  /// Location pin drop
  static const String locationPin = '${basePath}location_pin.json';

  /// Empty state / not found
  static const String notFound = '${basePath}not_found.json';
}
