import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../api/news_api.dart';
import '../models/article.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final NewsAPI _newsAPI = NewsAPI();
  List<Article> _articles = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      print('Fetching articles directly from API');
      final articles = await _newsAPI.getTopHeadlines(category: 'general');
      print('Received ${articles.length} articles');
      
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching articles: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchArticles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchArticles,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _articles.isEmpty
                  ? const Center(child: Text('No articles found'))
                  : ListView.builder(
                      itemCount: _articles.length,
                      itemBuilder: (context, index) {
                        final article = _articles[index];
                        return ListTile(
                          title: Text(article.title),
                          subtitle: Text(article.description),
                        );
                      },
                    ),
    );
  }
} 