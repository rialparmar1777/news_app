import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/article.dart';

class NewsAPI {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _vercelApiUrl = '/api/news'; // Vercel serverless function
  static const int _pageSize = 20;

  String _getUrl(String endpoint) {
    if (kIsWeb) {
      // Use Vercel serverless function for web deployment
      final uri = Uri.parse(endpoint);
      final queryParams = uri.queryParameters;
      
      if (endpoint.contains('/everything')) {
        return '$_vercelApiUrl?query=${queryParams['q']}&pageSize=$_pageSize';
      } else {
        final category = queryParams['category'] ?? 'general';
        return '$_vercelApiUrl?category=$category&pageSize=$_pageSize';
      }
    }
    return endpoint;
  }

  Future<List<Article>> getTopHeadlines(String category) async {
    try {
      final apiKey = dotenv.env['NEWS_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please check your .env file.');
      }

      final url = _getUrl('$_baseUrl/top-headlines?country=us&category=$category&apiKey=$apiKey');
      print('Fetching news from URL: ${url.replaceAll(apiKey, 'API_KEY_HIDDEN')}');
      
      final response = await http.get(Uri.parse(url));
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data status: ${data['status']}');
        print('Number of articles: ${(data['articles'] as List?)?.length ?? 0}');
        
        if (data['status'] == 'ok' && data['articles'] != null) {
          final articles = (data['articles'] as List)
              .map((article) => Article.fromJson(article))
              .toList();
          return articles;
        } else {
          throw Exception(data['message'] ?? 'Failed to load news');
        }
      } else if (response.statusCode == 403 && kIsWeb) {
        // Return fallback data for web deployment when API access is restricted
        return _getFallbackArticles();
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTopHeadlines: $e');
      if (kIsWeb) {
        // Return fallback data for web deployment
        return _getFallbackArticles();
      }
      rethrow;
    }
  }

  Future<List<Article>> searchNews(String query) async {
    try {
      final apiKey = dotenv.env['NEWS_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please check your .env file.');
      }

      final url = _getUrl('$_baseUrl/everything?q=$query&apiKey=$apiKey&pageSize=$_pageSize');
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          final articles = (data['articles'] as List)
              .map((article) => Article.fromJson(article))
              .toList();
          return articles;
        } else {
          throw Exception(data['message'] ?? 'Failed to load news');
        }
      } else if (response.statusCode == 403 && kIsWeb) {
        // Return fallback data for web deployment when API access is restricted
        return _getFallbackArticles();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      if (kIsWeb) {
        // Return fallback data for web deployment
        return _getFallbackArticles();
      }
      rethrow;
    }
  }

  List<Article> _getFallbackArticles() {
    // Return a list of sample articles for web deployment
    return [
      Article(
        title: 'Technology Advances in AI and Machine Learning',
        description: 'Recent developments in artificial intelligence and machine learning are transforming various industries...',
        url: 'https://example.com/tech-news',
        urlToImage: 'https://picsum.photos/800/400?random=1',
        publishedAt: DateTime.now().toIso8601String(),
        source: 'Tech News',
        author: 'John Smith',
      ),
      Article(
        title: 'Climate Change: New Research Findings',
        description: 'Scientists discover new evidence about the impact of climate change on global ecosystems...',
        url: 'https://example.com/climate-news',
        urlToImage: 'https://picsum.photos/800/400?random=2',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        source: 'Environmental News',
        author: 'Sarah Johnson',
      ),
      Article(
        title: 'Global Economic Trends 2024',
        description: 'Analysis of current economic trends and their implications for global markets...',
        url: 'https://example.com/economy-news',
        urlToImage: 'https://picsum.photos/800/400?random=3',
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        source: 'Financial Times',
        author: 'Michael Brown',
      ),
    ];
  }
} 