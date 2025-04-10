import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/user_preferences.dart';
import '../widgets/news_card.dart';
import '../widgets/news_empty_state.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userPreferences = Provider.of<UserPreferences>(context);
    final newsProvider = Provider.of<NewsProvider>(context);

    // Filter articles to show only bookmarked ones
    final bookmarkedArticles = newsProvider.articles
        .where((article) => userPreferences.isBookmarked(article.url))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: bookmarkedArticles.isEmpty
          ? NewsEmptyState(
              message: 'No bookmarked articles yet',
              onRefresh: () => newsProvider.fetchTopHeadlines(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookmarkedArticles.length,
              itemBuilder: (context, index) {
                final article = bookmarkedArticles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: NewsCard(
                    article: article,
                    isFeature: index == 0,
                  ),
                );
              },
            ),
    );
  }
} 