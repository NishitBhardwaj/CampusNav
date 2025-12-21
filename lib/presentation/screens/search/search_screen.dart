/// CampusNav - Enhanced Search Screen
///
/// AI-assisted search with fuzzy matching and intent detection.
/// Shows results with relevance ranking and feedback option.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/animation_config.dart';
import '../../../data/models/search_index.dart';
import '../../state/search_provider.dart';
import '../../widgets/search_result_sheet.dart';
import '../../widgets/ai_suggestion_chips.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchProvider.notifier).search(query);
    ref.read(searchProvider.notifier).getSuggestions(query);
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    ref.read(searchProvider.notifier).search(suggestion);
    _focusNode.unfocus();
  }

  void _onResultTap(SearchResult result) {
    ref.read(selectedResultProvider.notifier).state = result;
    _showResultSheet(result);
  }

  void _showResultSheet(SearchResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchResultSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Intent indicator
          if (searchState.detectedIntent != null && searchState.hasResults)
            _buildIntentBadge(searchState.detectedIntent!),

          // Suggestions
          if (searchState.suggestions.isNotEmpty && !searchState.hasResults)
            AiSuggestionChips(
              suggestions: searchState.suggestions,
              onSuggestionTap: _onSuggestionTap,
            ),

          // Results
          Expanded(
            child: _buildResultsList(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search rooms, people, departments...',
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).clear();
                  },
                )
              : const Icon(Icons.mic, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
      ),
    )
        .animate()
        .fadeIn(duration: AnimationDurations.standard)
        .slideY(begin: -0.1);
  }

  Widget _buildIntentBadge(QueryIntent intent) {
    String label;
    IconData icon;
    Color color;

    switch (intent) {
      case QueryIntent.findPerson:
        label = 'Looking for a person';
        icon = Icons.person;
        color = AppColors.accent;
        break;
      case QueryIntent.findRoom:
        label = 'Looking for a room';
        icon = Icons.meeting_room;
        color = AppColors.primary;
        break;
      case QueryIntent.findDepartment:
        label = 'Looking for a department';
        icon = Icons.account_tree;
        color = AppColors.warning;
        break;
      case QueryIntent.generalSearch:
        label = 'Searching all';
        icon = Icons.search;
        color = AppColors.textSecondary;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AnimationDurations.quick)
        .scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildResultsList(SearchState state) {
    if (state.isSearching) {
      return _buildLoadingState();
    }

    if (state.isEmpty) {
      return _buildEmptyState();
    }

    if (!state.hasResults) {
      return _buildNoResultsState(state.query);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final result = state.results[index];
        return _buildResultCard(result, index);
      },
    );
  }

  Widget _buildResultCard(SearchResult result, int index) {
    final entry = result.entry;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onResultTap(result),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Entity type icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getEntityColor(entry.entityType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getEntityIcon(entry.entityType),
                  color: _getEntityColor(entry.entityType),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayTitle,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.displaySubtitle,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Match indicator
              _buildMatchBadge(result),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: AnimationDurations.standard,
        )
        .slideX(begin: 0.1, curve: AnimationCurves.enter);
  }

  Widget _buildMatchBadge(SearchResult result) {
    Color color;
    String text;

    if (result.score >= 0.9) {
      color = AppColors.success;
      text = 'Best';
    } else if (result.score >= 0.7) {
      color = AppColors.primary;
      text = 'Good';
    } else {
      color = AppColors.textSecondary;
      text = 'Partial';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for anything',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try "Room 204", "Dr. Kumar", or "cafeteria"',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  IconData _getEntityIcon(SearchEntityType type) {
    switch (type) {
      case SearchEntityType.room:
        return Icons.meeting_room;
      case SearchEntityType.personnel:
        return Icons.person;
      case SearchEntityType.department:
        return Icons.account_tree;
      case SearchEntityType.building:
        return Icons.business;
    }
  }

  Color _getEntityColor(SearchEntityType type) {
    switch (type) {
      case SearchEntityType.room:
        return AppColors.primary;
      case SearchEntityType.personnel:
        return AppColors.accent;
      case SearchEntityType.department:
        return AppColors.warning;
      case SearchEntityType.building:
        return AppColors.success;
    }
  }
}
