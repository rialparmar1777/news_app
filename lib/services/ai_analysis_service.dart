import 'dart:convert';
import 'dart:math' as math;
import 'dart:math' show min;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class AIAnalysisService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _cachePrefix = 'article_analysis_';
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  static const int _maxRequestsPerWindow = 10;
  static const int _maxRetries = 3;
  static const Duration _cacheDuration = Duration(days: 7);
  static const Duration _requestTimeout = Duration(seconds: 60);
  
  final Map<String, DateTime> _lastRequestTimes = {};
  int _requestsInCurrentWindow = 0;
  DateTime _windowStartTime = DateTime.now();
  int _retryCount = 0;
  
  Future<Map<String, dynamic>> analyzeArticle(Article article) async {
    try {
      // Always check cache first
      final cachedAnalysis = await _getCachedAnalysis(article.url);
      if (cachedAnalysis != null) {
        return {
          ...cachedAnalysis,
          'cached': true,
          'message': 'Showing cached analysis while respecting rate limits.',
        };
      }

      // Check rate limiting
      await _checkRateLimit();

      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key not found or empty. Please check your configuration.');
      }

      if (article.description == null || article.description!.isEmpty) {
        throw Exception('Article content is empty. Cannot perform analysis.');
      }

      final prompt = '''
Analyze this news article and provide:
1. A concise summary (max 100 words)
2. Different perspectives on the story
3. Potential biases in the reporting
4. Key facts and claims that need verification

Article Title: ${article.title}
Article Content: ${article.description}
Source: ${article.source}
''';

      print('Sending request to OpenAI API...');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a news analysis expert. Provide objective, balanced analysis of news articles.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      ).timeout(
        _requestTimeout,
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );

      print('Received response with status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] == null || data['choices'].isEmpty) {
          print('Invalid response format: ${response.body}');
          throw Exception('Invalid response format from OpenAI API');
        }
        
        final analysis = data['choices'][0]['message']['content'];
        print('Received analysis: ${analysis.substring(0, min<int>(100, analysis.length))}...');
        
        final parsedAnalysis = _parseAIResponse(analysis);
        
        // Cache successful results
        await _cacheAnalysis(article.url, parsedAnalysis);
        _retryCount = 0; // Reset retry count on success
        
        return parsedAnalysis;
      } else if (response.statusCode == 429) {
        // Handle rate limiting with exponential backoff
        if (_retryCount < _maxRetries) {
          _retryCount++;
          final waitTime = math.pow(2, _retryCount).toInt();
          print('Rate limit hit, waiting $waitTime seconds before retry...');
          await Future.delayed(Duration(seconds: waitTime));
          return analyzeArticle(article); // Retry with exponential backoff
        }
        
        // If we've exhausted retries, generate a fallback analysis
        print('Rate limit exceeded, generating fallback analysis');
        return _generateFallbackAnalysis(article);
      } else if (response.statusCode == 401) {
        print('Authentication error: ${response.body}');
        throw Exception('Invalid API key. Please check your OpenAI API key configuration.');
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to analyze article (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('Error in analyzeArticle: $e');
      // Try to return cached version for any error
      final cachedAnalysis = await _getCachedAnalysis(article.url);
      if (cachedAnalysis != null) {
        return {
          ...cachedAnalysis,
          'cached': true,
          'error': e.toString(),
          'message': 'Showing cached analysis due to error: ${e.toString()}',
        };
      }
      
      // If no cached version, generate a fallback analysis
      return _generateFallbackAnalysis(article);
    }
  }

  // Generate a fallback analysis when API is unavailable
  Map<String, dynamic> _generateFallbackAnalysis(Article article) {
    print('Generating fallback analysis for article: ${article.title}');
    
    // Create a simple fallback analysis based on the article title and description
    final title = article.title;
    final description = article.description ?? '';
    
    // Extract key phrases from the title and description
    final words = (title + ' ' + description).split(' ');
    final keyPhrases = words.where((word) => word.length > 5).take(5).join(', ');
    
    return {
      'summary': 'This is a summary of the article about $title. The article discusses $keyPhrases.',
      'perspectives': 'Different perspectives on this story include the main narrative presented in the article, as well as potential alternative viewpoints that might not be fully represented.',
      'biases': 'Potential biases in this reporting could include source selection, framing of the narrative, and emphasis on certain aspects over others.',
      'verification': 'Key facts to verify include the main claims made in the article, the sources cited, and the context provided for the events described.',
      'cached': false,
      'timestamp': DateTime.now().toIso8601String(),
      'fallback': true,
      'message': 'This is a fallback analysis generated due to API rate limits. Please try again later for a more detailed analysis.',
    };
  }

  Future<void> _checkRateLimit() async {
    final now = DateTime.now();
    
    // Reset window if needed
    if (now.difference(_windowStartTime) >= _rateLimitWindow) {
      _requestsInCurrentWindow = 0;
      _windowStartTime = now;
      return;
    }

    // Check if we've exceeded the rate limit
    if (_requestsInCurrentWindow >= _maxRequestsPerWindow) {
      final timeToWait = _rateLimitWindow - now.difference(_windowStartTime);
      final minutes = (timeToWait.inSeconds / 60).ceil();
      throw Exception('Rate limit active. Please try again in $minutes minute${minutes > 1 ? 's' : ''}. You can still view cached analyses if available.');
    }

    _requestsInCurrentWindow++;
  }

  Future<Map<String, dynamic>?> _getCachedAnalysis(String articleUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cachePrefix + articleUrl);
      if (cached != null) {
        final data = jsonDecode(cached);
        final timestamp = DateTime.parse(data['timestamp']);
        if (DateTime.now().difference(timestamp) < _cacheDuration) {
          return Map<String, dynamic>.from(data);
        }
      }
    } catch (e) {
      print('Error reading from cache: $e');
    }
    return null;
  }

  Future<void> _cacheAnalysis(String articleUrl, Map<String, dynamic> analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataToCache = {
        ...analysis,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_cachePrefix + articleUrl, jsonEncode(dataToCache));
    } catch (e) {
      print('Error writing to cache: $e');
    }
  }

  Map<String, dynamic> _parseAIResponse(String response) {
    try {
      if (response.isEmpty) {
        throw Exception('Empty response from AI');
      }

      // Split the response into sections and clean them
      final sections = response.split('\n\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      
      if (sections.isEmpty) {
        throw Exception('No valid sections found in AI response');
      }

      return {
        'summary': sections.isNotEmpty ? _cleanSection(sections[0], 'Summary:') : '',
        'perspectives': sections.length > 1 ? _cleanSection(sections[1], 'Perspectives:') : '',
        'biases': sections.length > 2 ? _cleanSection(sections[2], 'Biases:') : '',
        'verification': sections.length > 3 ? _cleanSection(sections[3], 'Verification:') : '',
        'cached': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error parsing AI response: $e');
      throw Exception('Failed to parse AI response: ${e.toString()}');
    }
  }

  String _cleanSection(String text, String prefix) {
    return text
        .replaceAll(prefix, '')
        .replaceAll(RegExp(r'^\d+\.\s*'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
} 