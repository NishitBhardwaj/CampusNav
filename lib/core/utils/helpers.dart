/// CampusNav - Helper Utilities
///
/// This file contains utility functions for common operations
/// used throughout the application.

import 'dart:math';

// =============================================================================
// DISTANCE CALCULATIONS
// =============================================================================

/// Calculate Euclidean distance between two points
double calculateDistance(double x1, double y1, double x2, double y2) {
  return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
}

/// Convert meters to pixels based on scale
double metersToPixels(double meters, double pixelsPerMeter) {
  return meters * pixelsPerMeter;
}

/// Convert pixels to meters based on scale
double pixelsToMeters(double pixels, double pixelsPerMeter) {
  return pixels / pixelsPerMeter;
}

// =============================================================================
// STRING UTILITIES
// =============================================================================

/// Normalize string for search (lowercase, trim whitespace)
String normalizeSearchQuery(String query) {
  return query.toLowerCase().trim();
}

/// Calculate Levenshtein distance for fuzzy matching
int levenshteinDistance(String a, String b) {
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  List<List<int>> matrix = List.generate(
    a.length + 1,
    (i) => List.generate(b.length + 1, (j) => 0),
  );

  for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
  for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      int cost = a[i - 1] == b[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1,
        matrix[i][j - 1] + 1,
        matrix[i - 1][j - 1] + cost,
      ].reduce(min);
    }
  }

  return matrix[a.length][b.length];
}

/// Calculate similarity score between two strings (0.0 to 1.0)
double stringSimilarity(String a, String b) {
  if (a.isEmpty && b.isEmpty) return 1.0;
  if (a.isEmpty || b.isEmpty) return 0.0;
  
  int distance = levenshteinDistance(a.toLowerCase(), b.toLowerCase());
  int maxLength = max(a.length, b.length);
  return 1.0 - (distance / maxLength);
}

// =============================================================================
// ANGLE UTILITIES
// =============================================================================

/// Convert degrees to radians
double degreesToRadians(double degrees) {
  return degrees * (pi / 180.0);
}

/// Convert radians to degrees
double radiansToDegrees(double radians) {
  return radians * (180.0 / pi);
}

/// Normalize angle to 0-360 range
double normalizeAngle(double degrees) {
  degrees = degrees % 360;
  if (degrees < 0) degrees += 360;
  return degrees;
}
