import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NewsCardSkeleton extends StatelessWidget {
  const NewsCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: theme.colorScheme.surfaceVariant,
            highlightColor: theme.colorScheme.surface,
            child: Container(
              height: 200,
              width: double.infinity,
              color: theme.colorScheme.surfaceVariant,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: theme.colorScheme.surfaceVariant,
                  highlightColor: theme.colorScheme.surface,
                  child: Container(
                    height: 24,
                    width: double.infinity,
                    color: theme.colorScheme.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: theme.colorScheme.surfaceVariant,
                  highlightColor: theme.colorScheme.surface,
                  child: Container(
                    height: 16,
                    width: double.infinity,
                    color: theme.colorScheme.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: theme.colorScheme.surfaceVariant,
                  highlightColor: theme.colorScheme.surface,
                  child: Container(
                    height: 16,
                    width: 200,
                    color: theme.colorScheme.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: theme.colorScheme.surfaceVariant,
                      highlightColor: theme.colorScheme.surface,
                      child: Container(
                        height: 16,
                        width: 100,
                        color: theme.colorScheme.surfaceVariant,
                      ),
                    ),
                    Shimmer.fromColors(
                      baseColor: theme.colorScheme.surfaceVariant,
                      highlightColor: theme.colorScheme.surface,
                      child: Container(
                        height: 16,
                        width: 80,
                        color: theme.colorScheme.surfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 