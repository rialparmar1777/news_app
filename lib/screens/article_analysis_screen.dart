import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/article_analysis.dart';
import '../services/ai_analysis_service.dart';
import '../widgets/ai_loading_animation.dart';

class ArticleAnalysisScreen extends StatefulWidget {
  final Article article;

  const ArticleAnalysisScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<ArticleAnalysisScreen> createState() => _ArticleAnalysisScreenState();
}

class _ArticleAnalysisScreenState extends State<ArticleAnalysisScreen> with SingleTickerProviderStateMixin {
  final _aiService = AIAnalysisService();
  ArticleAnalysis? _analysis;
  bool _isLoading = false;
  String? _error;
  bool _isCached = false;
  bool _isFallback = false;
  String? _message;
  final Map<String, bool> _expandedSections = {};
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
    _analyzeArticle();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyzeArticle() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _message = null;
    });

    try {
      final result = await _aiService.analyzeArticle(widget.article);
      if (!mounted) return;
      
      setState(() {
        _analysis = ArticleAnalysis(
          summary: result['summary'],
          perspectives: result['perspectives'],
          biases: result['biases'],
          verification: result['verification'],
          timestamp: DateTime.now(),
        );
        _isCached = result['cached'] ?? false;
        _isFallback = result['fallback'] ?? false;
        _message = result['message'];
        _error = result['error'];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _analyzeArticle,
            ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isLoading
                ? const AILoadingAnimation()
                : _error != null && _analysis == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error!,
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _analyzeArticle,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    if (_isCached || _isFallback || _error != null)
                                      Container(
                                        margin: const EdgeInsets.all(16),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _isFallback
                                              ? theme.colorScheme.secondaryContainer
                                              : _isCached
                                                  ? theme.colorScheme.tertiaryContainer
                                                  : theme.colorScheme.errorContainer,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.shadowColor.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _isFallback
                                                  ? Icons.info
                                                  : _isCached
                                                      ? Icons.history
                                                      : Icons.warning,
                                              color: _isFallback
                                                  ? theme.colorScheme.onSecondaryContainer
                                                  : _isCached
                                                      ? theme.colorScheme.onTertiaryContainer
                                                      : theme.colorScheme.onErrorContainer,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _message ?? _error ?? 'Showing cached analysis',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: _isFallback
                                                      ? theme.colorScheme.onSecondaryContainer
                                                      : _isCached
                                                          ? theme.colorScheme.onTertiaryContainer
                                                          : theme.colorScheme.onErrorContainer,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  _buildAnimatedSection(
                                    title: 'Summary',
                                    content: _analysis?.summary ?? '',
                                    icon: Icons.summarize,
                                    color: theme.colorScheme.primary,
                                    index: 0,
                                  ),
                                  _buildAnimatedSection(
                                    title: 'Different Perspectives',
                                    content: _analysis?.perspectives ?? '',
                                    icon: Icons.psychology,
                                    color: theme.colorScheme.secondary,
                                    index: 1,
                                  ),
                                  _buildAnimatedSection(
                                    title: 'Potential Biases',
                                    content: _analysis?.biases ?? '',
                                    icon: Icons.balance,
                                    color: theme.colorScheme.tertiary,
                                    index: 2,
                                  ),
                                  _buildAnimatedSection(
                                    title: 'Facts to Verify',
                                    content: _analysis?.verification ?? '',
                                    icon: Icons.fact_check,
                                    color: theme.colorScheme.error,
                                    index: 3,
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Powered by Rial',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isExpanded = _expandedSections[title] ?? false;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _expandedSections[title] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.5).animate(
                          CurvedAnimation(
                            parent: AlwaysStoppedAnimation(isExpanded ? 1.0 : 0.0),
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(height: 0),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 36,
                      ),
                      child: Text(
                        content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 