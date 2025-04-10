import 'package:flutter/material.dart';
import '../api/news_api.dart';
import '../models/article.dart';

class NewsProvider extends ChangeNotifier {
  final NewsAPI _api = NewsAPI();
  List<Article> _articles = [];
  List<Article> _recommendations = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'general';
  String? _searchQuery;
  int _currentPage = 1;
  bool _hasMorePages = true;

  List<Article> get articles => _articles;
  List<Article> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  bool get hasMorePages => _hasMorePages;

  Future<void> searchNews({
    required String query,
    String category = 'all',
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _searchQuery = query;
    _currentPage = 1;
    notifyListeners();

    try {
      _articles = await _api.searchNews(query);
      _hasMorePages = _articles.length >= 20; // Assuming pageSize is 20
      _error = null;
    } catch (e) {
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreArticles() async {
    if (_isLoading || !_hasMorePages) return;

    _currentPage++;
    _isLoading = true;
    notifyListeners();

    try {
      final articles = _searchQuery != null
          ? await _api.searchNews(_searchQuery!)
          : await _api.getTopHeadlines(_selectedCategory);

      _articles.addAll(articles);
      _hasMorePages = articles.length >= 20; // Assuming pageSize is 20
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentPage--;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecommendations() async {
    try {
      _recommendations = await _api.getTopHeadlines(_selectedCategory);
      _recommendations = _recommendations.take(5).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _articles = [];
    _recommendations = [];
    _error = null;
    _isLoading = false;
    _currentPage = 1;
    _hasMorePages = true;
    _searchQuery = null;
    notifyListeners();
  }

  Future<List<Article>> getRecommendations(String category) async {
    try {
      return await _api.getTopHeadlines(category);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();
  }

  Future<void> fetchTopHeadlines([String? category]) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (category != null) {
        _selectedCategory = category;
      }
      _articles = await _api.getTopHeadlines(_selectedCategory);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchArticles(String query) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _articles = await _api.searchNews(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchArticles(String category) async {
    await fetchTopHeadlines(category);
  }
} 