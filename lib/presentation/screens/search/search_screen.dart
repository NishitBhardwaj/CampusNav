/// CampusNav - Search Screen
///
/// Main search screen for finding locations and people.
/// Features fuzzy search with real-time results.

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  bool _isSearching = false;
  List<Map<String, dynamic>> _locationResults = [];
  List<Map<String, dynamic>> _peopleResults = [];

  // Mock data for demo
  final List<Map<String, dynamic>> _mockLocations = [
    {'name': 'Room 101 - Computer Lab', 'category': 'Lab', 'floor': 'Ground'},
    {'name': 'Room 102 - Lecture Hall A', 'category': 'Classroom', 'floor': 'Ground'},
    {'name': 'Cafeteria', 'category': 'Food', 'floor': 'Ground'},
    {'name': 'Library', 'category': 'Library', 'floor': '2nd'},
    {'name': 'HOD Office - CS', 'category': 'Office', 'floor': '1st'},
  ];

  final List<Map<String, dynamic>> _mockPeople = [
    {'name': 'Dr. Rajesh Kumar', 'dept': 'Computer Science', 'role': 'HOD'},
    {'name': 'Prof. Priya Sharma', 'dept': 'Computer Science', 'role': 'Associate Professor'},
    {'name': 'Mr. Vikram Singh', 'dept': 'Library', 'role': 'Chief Librarian'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _isSearching = query.isNotEmpty;

      if (query.isEmpty) {
        _locationResults = [];
        _peopleResults = [];
        return;
      }

      // Filter locations
      _locationResults = _mockLocations
          .where((loc) => loc['name'].toLowerCase().contains(query))
          .toList();

      // Filter people
      _peopleResults = _mockPeople
          .where((p) =>
              p['name'].toLowerCase().contains(query) ||
              p['dept'].toLowerCase().contains(query))
          .toList();
    });
  }

  void _navigateToLocation(Map<String, dynamic> location) {
    Navigator.of(context).pushNamed('/navigation', arguments: location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CampusNav'),
        backgroundColor: AppColors.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search locations or people...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Locations'),
                  Tab(text: 'People'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Locations Tab
          _buildLocationsList(),
          // People Tab
          _buildPeopleList(),
        ],
      ),
    );
  }

  Widget _buildLocationsList() {
    final items = _isSearching ? _locationResults : _mockLocations;

    if (items.isEmpty && _isSearching) {
      return _buildEmptyState('No locations found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final location = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on, color: AppColors.primary),
            ),
            title: Text(location['name']),
            subtitle: Text('${location['category']} • ${location['floor']} Floor'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateToLocation(location),
          ),
        );
      },
    );
  }

  Widget _buildPeopleList() {
    final items = _isSearching ? _peopleResults : _mockPeople;

    if (items.isEmpty && _isSearching) {
      return _buildEmptyState('No people found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final person = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Text(
                person['name'].substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(person['name']),
            subtitle: Text('${person['role']} • ${person['dept']}'),
            trailing: IconButton(
              icon: const Icon(Icons.navigation, color: AppColors.primary),
              onPressed: () {
                // Navigate to person's office
                _navigateToLocation({'name': '${person['name']}\'s Office'});
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
