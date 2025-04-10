import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import 'news_list.dart';
import '../widgets/glass_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _categories = [
    'general',
    'business',
    'technology',
    'sports',
    'entertainment',
  ];

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWebNotice();
      });
    }
  }

  void _showWebNotice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Web Version Notice'),
        content: const Text(
          'You are using the web version of the app. Due to API limitations, '
          'some features might be using sample data. For the full experience, '
          'please consider using the mobile app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NewsList(
          category: _categories[_currentIndex],
          onCategorySelected: (category) {
            final index = _categories.indexOf(category);
            if (index != -1) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
        ),
      ),
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            label: 'Tech',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: 'Sports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Entertainment',
          ),
        ],
      ),
    );
  }
} 