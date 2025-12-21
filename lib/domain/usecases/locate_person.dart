/// CampusNav - Locate Person Use Case
///
/// Business logic for finding people and their office locations.

import '../entities/person.dart';
import '../entities/location.dart';
import '../../core/utils/helpers.dart';
import '../../core/constants/constants.dart';

// =============================================================================
// PERSON SEARCH RESULT
// =============================================================================

class PersonSearchResult {
  final Person person;
  final Location? officeLocation;
  final double score;

  const PersonSearchResult({
    required this.person,
    this.officeLocation,
    required this.score,
  });
}

// =============================================================================
// LOCATE PERSON USE CASE
// =============================================================================

class LocatePersonUseCase {
  /// Search for people with fuzzy matching
  Future<List<PersonSearchResult>> searchPeople({
    required String query,
    required List<Person> people,
    required Future<Location?> Function(String) getLocation,
    int maxResults = kMaxSearchResults,
  }) async {
    if (query.isEmpty) {
      return [];
    }

    final normalizedQuery = normalizeSearchQuery(query);
    final results = <PersonSearchResult>[];

    for (final person in people) {
      final score = _matchPerson(normalizedQuery, person);
      if (score >= kFuzzySearchThreshold) {
        Location? office;
        if (person.officeLocationId != null) {
          office = await getLocation(person.officeLocationId!);
        }

        results.add(PersonSearchResult(
          person: person,
          officeLocation: office,
          score: score,
        ));
      }
    }

    // Sort by score
    results.sort((a, b) => b.score.compareTo(a.score));

    return results.take(maxResults).toList();
  }

  double _matchPerson(String query, Person person) {
    double bestScore = 0;

    // Check name
    final nameLower = person.name.toLowerCase();
    if (nameLower == query) return 1.0;
    if (nameLower.contains(query)) return 0.9;

    // Check department
    if (person.department != null) {
      if (person.department!.toLowerCase().contains(query)) {
        bestScore = 0.7;
      }
    }

    // Check designation
    if (person.designation != null) {
      if (person.designation!.toLowerCase().contains(query)) {
        if (0.75 > bestScore) bestScore = 0.75;
      }
    }

    // Check tags
    if (person.tags != null) {
      for (final tag in person.tags!) {
        if (tag.toLowerCase() == query) {
          if (0.85 > bestScore) bestScore = 0.85;
          break;
        }
        if (tag.toLowerCase().contains(query)) {
          if (0.7 > bestScore) bestScore = 0.7;
        }
      }
    }

    // Fuzzy match on name
    if (bestScore < kFuzzySearchThreshold) {
      final similarity = stringSimilarity(query, nameLower);
      if (similarity > bestScore) bestScore = similarity;
    }

    return bestScore;
  }

  /// Get person by ID with their office location
  Future<PersonSearchResult?> getPersonWithLocation({
    required String personId,
    required List<Person> people,
    required Future<Location?> Function(String) getLocation,
  }) async {
    final person = people.where((p) => p.id == personId).firstOrNull;
    if (person == null) return null;

    Location? office;
    if (person.officeLocationId != null) {
      office = await getLocation(person.officeLocationId!);
    }

    return PersonSearchResult(
      person: person,
      officeLocation: office,
      score: 1.0,
    );
  }
}
