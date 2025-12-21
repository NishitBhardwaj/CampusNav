/// CampusNav - Mock People Data
///
/// Mock personnel data for testing and demo purposes.
/// Contains sample faculty and staff information.

import '../models/person_model.dart';

// =============================================================================
// MOCK PEOPLE
// =============================================================================

final mockPeople = [
  PersonModel(
    id: 'person_1',
    name: 'Dr. Rajesh Kumar',
    department: 'Computer Science',
    designation: 'Head of Department',
    email: 'rajesh.kumar@campus.edu',
    phone: '+91-9876543210',
    officeLocationId: 'loc_hod_office',
    tags: ['HOD', 'professor', 'CS', 'AI', 'machine learning'],
  ),
  PersonModel(
    id: 'person_2',
    name: 'Prof. Priya Sharma',
    department: 'Computer Science',
    designation: 'Associate Professor',
    email: 'priya.sharma@campus.edu',
    phone: '+91-9876543211',
    officeLocationId: 'loc_room101',
    tags: ['professor', 'CS', 'database', 'software engineering'],
  ),
  PersonModel(
    id: 'person_3',
    name: 'Dr. Amit Patel',
    department: 'Electronics',
    designation: 'Professor',
    email: 'amit.patel@campus.edu',
    officeLocationId: 'loc_room102',
    tags: ['professor', 'electronics', 'embedded systems'],
  ),
  PersonModel(
    id: 'person_4',
    name: 'Ms. Sneha Gupta',
    department: 'Administration',
    designation: 'Administrative Officer',
    email: 'sneha.gupta@campus.edu',
    phone: '+91-9876543213',
    officeLocationId: 'loc_entrance',
    tags: ['admin', 'reception', 'help desk'],
  ),
  PersonModel(
    id: 'person_5',
    name: 'Mr. Vikram Singh',
    department: 'Library',
    designation: 'Chief Librarian',
    email: 'vikram.singh@campus.edu',
    officeLocationId: 'loc_library_entrance',
    tags: ['library', 'librarian', 'books'],
  ),
  PersonModel(
    id: 'person_6',
    name: 'Dr. Meera Reddy',
    department: 'Computer Science',
    designation: 'Assistant Professor',
    email: 'meera.reddy@campus.edu',
    tags: ['professor', 'CS', 'web development', 'mobile apps'],
  ),
];
