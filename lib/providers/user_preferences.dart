import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _bookmarksKey = 'bookmarks';
  static const String _categoriesKey = 'selected_categories';
  
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  List<String> _bookmarkedArticles = [];
  List<String> _selectedCategories = ['general', 'business', 'technology', 'sports', 'entertainment'];
  bool _isDarkMode = false;
  final Set<String> _bookmarkedUrls = {};

  ThemeMode get themeMode => _themeMode;
  List<String> get bookmarkedArticles => _bookmarkedArticles;
  List<String> get selectedCategories => _selectedCategories;
  bool get isDarkMode => _isDarkMode;
  Set<String> get bookmarkedUrls => _bookmarkedUrls;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPreferences();
  }

  void _loadPreferences() {
    _loadTheme();
    _loadBookmarks();
    _loadCategories();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _bookmarkedUrls.addAll(_prefs.getStringList('bookmarkedUrls') ?? []);
    notifyListeners();
  }

  void _loadTheme() {
    final themeString = _prefs.getString(_themeKey);
    if (themeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeString,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  void _loadBookmarks() {
    _bookmarkedArticles = _prefs.getStringList(_bookmarksKey) ?? [];
    notifyListeners();
  }

  void _loadCategories() {
    _selectedCategories = _prefs.getStringList(_categoriesKey) ?? 
        ['general', 'business', 'technology', 'sports', 'entertainment'];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleBookmark(String url) async {
    if (_bookmarkedUrls.contains(url)) {
      _bookmarkedUrls.remove(url);
    } else {
      _bookmarkedUrls.add(url);
    }
    await _prefs.setStringList('bookmarkedUrls', _bookmarkedUrls.toList());
    notifyListeners();
  }

  Future<void> updateSelectedCategories(List<String> categories) async {
    _selectedCategories = categories;
    await _prefs.setStringList(_categoriesKey, categories);
    notifyListeners();
  }

  bool isBookmarked(String url) {
    return _bookmarkedUrls.contains(url);
  }
} 