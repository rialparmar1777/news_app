import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/news_card_skeleton.dart';
import '../widgets/news_header.dart';
import 'news_detail.dart';
import '../widgets/news_error_state.dart';
import '../widgets/news_empty_state.dart';

class NewsList extends StatefulWidget {
  final String category;
  final Function(String) onCategorySelected;
  
  const NewsList({
    Key? key, 
    this.category = 'general',
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('Initializing NewsList for category: ${widget.category}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNews();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NewsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshNews();
      });
    }
  }

  Future<void> _refreshNews() async {
    print('Refreshing news for category: ${widget.category}');
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    await newsProvider.fetchArticles(widget.category);
  }

  Widget _buildPoweredByRial(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: theme.colorScheme.primary.withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  'Powered by Rial',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        if (newsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (newsProvider.error != null) {
          return NewsErrorState(
            message: newsProvider.error!,
            onRetry: () => newsProvider.fetchTopHeadlines(widget.category),
          );
        }

        final articles = newsProvider.articles;
        if (articles.isEmpty) {
          return NewsEmptyState(
            message: 'No articles found for ${widget.category}',
            onRefresh: () => newsProvider.fetchTopHeadlines(widget.category),
          );
        }

        return Column(
          children: [
            NewsHeader(
              category: widget.category,
              onSearchTap: () {
                showSearch(
                  context: context,
                  delegate: NewsSearchDelegate(newsProvider),
                );
              },
              onCategorySelected: widget.onCategorySelected,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: NewsCard(article: article),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class NewsSearchDelegate extends SearchDelegate {
  final NewsProvider newsProvider;

  NewsSearchDelegate(this.newsProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final theme = Theme.of(context);
    
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Enter a search term',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return FutureBuilder(
      future: newsProvider.searchArticles(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 2,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }

        final articles = newsProvider.articles;
        if (articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return NewsCard(
              article: article,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetail(article: article),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'Start typing to search',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
} 