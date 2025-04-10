import 'package:flutter/material.dart';

class NewsLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;

  const NewsLoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
  }) : super(key: key);

  @override
  State<NewsLoadingIndicator> createState() => _NewsLoadingIndicatorState();
}

class _NewsLoadingIndicatorState extends State<NewsLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 2 * 3.14159,
                child: Icon(
                  Icons.newspaper,
                  size: widget.size,
                  color: color.withOpacity(0.3),
                ),
              );
            },
          ),
          Center(
            child: Icon(
              Icons.newspaper,
              size: widget.size * 0.6,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 