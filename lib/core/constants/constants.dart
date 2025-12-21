/// CampusNav - Core Constants
/// 
/// This file contains app-wide constants including colors, strings, 
/// dimensions, and other static values used throughout the application.

// =============================================================================
// APP INFO
// =============================================================================
const String kAppName = 'CampusNav';
const String kAppVersion = '1.0.0';
const String kAppDescription = 'Offline Indoor Navigation & Personnel Locator';

// =============================================================================
// NAVIGATION CONSTANTS
// =============================================================================
const double kDefaultNodeRadius = 5.0;
const double kPathWidth = 3.0;
const double kArrivalThreshold = 2.0; // meters

// =============================================================================
// SENSOR CONSTANTS
// =============================================================================
const double kStepLengthMeters = 0.7; // Average step length
const int kSensorUpdateIntervalMs = 100;

// =============================================================================
// UI CONSTANTS
// =============================================================================
const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kLargePadding = 24.0;
const double kBorderRadius = 12.0;

// =============================================================================
// SEARCH CONSTANTS
// =============================================================================
const int kMaxSearchResults = 10;
const double kFuzzySearchThreshold = 0.6;
