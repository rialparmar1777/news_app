import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../providers/user_preferences.dart';
import '../utils/article_utils.dart';
import '../widgets/page_turn_animation.dart';
import '../widgets/related_articles.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late PageController _pageController;
  late Article _currentArticle;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentArticle = widget.article;
    _pageController = PageController();
    _loadRelatedArticles();
  }

  Future<void> _loadRelatedArticles() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<NewsProvider>(context, listen: false).loadRecommendations();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onPageChanged(int index) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    if (index < newsProvider.articles.length) {
      setState(() => _currentArticle = newsProvider.articles[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final newsProvider = Provider.of<NewsProvider>(context);
    final userPreferences = Provider.of<UserPreferences>(context);

    return Scaffold(
      body: PageTurnAnimation(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _currentArticle.urlToImage ?? '',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            theme.scaffoldBackgroundColor,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    userPreferences.isBookmarked(_currentArticle.url)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                  onPressed: () {
                    userPreferences.toggleBookmark(_currentArticle.url);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    ArticleUtils.shareArticle(
                      title: _currentArticle.title,
                      url: _currentArticle.url,
                      context: context,
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentArticle.title,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _currentArticle.source.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ArticleUtils.formatDate(_currentArticle.publishedAt),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${ArticleUtils.estimateReadingTime(_currentArticle.content ?? '')} min read',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentArticle.content ?? '',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    if (!_isLoading)
                      RelatedArticles(
                        articles: newsProvider.recommendations,
                        onArticleTap: (article) {
                          setState(() => _currentArticle = article);
                          _pageController.animateToPage(
                            newsProvider.articles.indexOf(article),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
} 