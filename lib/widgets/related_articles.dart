import 'package:flutter/material.dart';
import '../models/article.dart';
import 'news_card.dart';

class RelatedArticles extends StatelessWidget {
  final List<Article> articles;
  final Function(Article) onArticleTap;

  const RelatedArticles({
    Key? key,
    required this.articles,
    required this.onArticleTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Related Articles',
            style: theme.textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return SizedBox(
                width: 280,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: NewsCard(
                    article: article,
                    isFeature: false,
                    onTap: () => onArticleTap(article),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 