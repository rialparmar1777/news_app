import 'package:flutter/material.dart';
import 'dart:math' as math;

class AILoadingAnimation extends StatefulWidget {
  const AILoadingAnimation({super.key});

  @override
  State<AILoadingAnimation> createState() => _AILoadingAnimationState();
}

class _AILoadingAnimationState extends State<AILoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  final List<String> _loadingTexts = [
    'Analyzing article content...',
    'Processing perspectives...',
    'Identifying potential biases...',
    'Extracting key facts...',
    'Generating insights...',
    'Almost there...',
  ];
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Change loading text periodically
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
        });
      }
      return mounted;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                width: 4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Inner circle with icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.psychology,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _loadingTexts[_currentTextIndex],
              key: ValueKey<int>(_currentTextIndex),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 