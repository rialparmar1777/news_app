import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/user_preferences.dart';
import '../utils/article_utils.dart';
import '../screens/news_detail.dart';
import '../screens/article_analysis_screen.dart';

class NewsCard extends StatelessWidget {
  final Article article;
  final bool isFeature;
  final VoidCallback? onTap;

  const NewsCard({
    Key? key,
    required this.article,
    this.isFeature = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userPreferences = Provider.of<UserPreferences>(context);
    final isBookmarked = userPreferences.isBookmarked(article.url);

    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetail(article: article),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(isFeature ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  child: article.urlToImage != null
                      ? CachedNetworkImage(
                          imageUrl: article.urlToImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  color: theme.colorScheme.error,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: theme.colorScheme.surfaceVariant,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: theme.colorScheme.error,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No image available',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          userPreferences.toggleBookmark(article.url);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.psychology,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleAnalysisScreen(
                                article: article,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          ArticleUtils.shareArticle(
                            title: article.title,
                            url: article.url,
                            context: context,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(isFeature ? 16.0 : 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.source,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ArticleUtils.formatDate(article.publishedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Hero(
                    tag: 'article_title_${article.url}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        article.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          fontSize: isFeature ? 18 : null,
                        ),
                        maxLines: isFeature ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (isFeature) ...[
                    const SizedBox(height: 8),
                    Text(
                      article.description ?? 'No description available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          article.source,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${ArticleUtils.estimateReadingTime(article.content ?? '')} min read',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 