import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ArticleUtils {
  static int estimateReadingTime(String content) {
    // Average reading speed: 200 words per minute
    final wordsPerMinute = 200;
    final wordCount = content.split(RegExp(r'\s+')).length;
    final readingTime = (wordCount / wordsPerMinute).ceil();
    return readingTime < 1 ? 1 : readingTime;
  }

  static Future<void> shareArticle({
    required String title,
    required String url,
    required BuildContext context,
  }) async {
    final text = 'Check out this article: $title\n$url';
    await Share.share(text);
  }

  static Future<void> launchArticle(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  static String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 