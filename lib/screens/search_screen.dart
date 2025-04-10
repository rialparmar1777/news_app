import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/user_preferences.dart';
import '../widgets/news_card.dart';
import '../widgets/search_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final RefreshController _refreshController = RefreshController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedSortBy = 'relevancy';
  String _selectedLanguage = 'en';
  bool _isLoading = false;

  final List<String> _categories = [
    'all',
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology',
  ];

  final List<String> _sortOptions = [
    'relevancy',
    'popularity',
    'publishedAt',
  ];

  final List<String> _languages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<NewsProvider>(context, listen: false).searchNews(
        query: _searchController.text,
        category: _selectedCategory,
        sortBy: _selectedSortBy,
        language: _selectedLanguage,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onRefresh() async {
    await _loadInitialData();
    _refreshController.refreshCompleted();
  }

  void _onSearch() {
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final newsProvider = Provider.of<NewsProvider>(context);
    final userPreferences = Provider.of<UserPreferences>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search News'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SearchBar(
                  controller: _searchController,
                  onSearch: _onSearch,
                  hintText: 'Search news...',
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Category',
                        value: _selectedCategory,
                        items: _categories,
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                          _onSearch();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Sort By',
                        value: _selectedSortBy,
                        items: _sortOptions,
                        onChanged: (value) {
                          setState(() => _selectedSortBy = value);
                          _onSearch();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Language',
                        value: _selectedLanguage,
                        items: _languages,
                        onChanged: (value) {
                          setState(() => _selectedLanguage = value);
                          _onSearch();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : newsProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        newsProvider.error!,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _onRefresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: newsProvider.articles.isEmpty
                      ? Center(
                          child: Text(
                            'No articles found',
                            style: theme.textTheme.titleMedium,
                          ),
                        )
                      : ListView.builder(
                          itemCount: newsProvider.articles.length,
                          itemBuilder: (context, index) {
                            final article = newsProvider.articles[index];
                            return NewsCard(
                              article: article,
                              isFeature: index == 0,
                            );
                          },
                        ),
                ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return PopupMenuButton<String>(
      child: Chip(
        label: Text('$label: $value'),
        avatar: const Icon(Icons.filter_list),
      ),
      itemBuilder: (context) => items
          .map(
            (item) => PopupMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onSelected: onChanged,
    );
  }
} 