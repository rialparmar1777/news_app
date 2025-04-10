import 'package:flutter/material.dart';

class PageTurnAnimation extends StatefulWidget {
  final Widget child;
  final bool forward;
  final Duration duration;
  final VoidCallback? onComplete;

  const PageTurnAnimation({
    Key? key,
    required this.child,
    this.forward = true,
    this.duration = const Duration(milliseconds: 300),
    this.onComplete,
  }) : super(key: key);

  @override
  State<PageTurnAnimation> createState() => _PageTurnAnimationState();
}

class _PageTurnAnimationState extends State<PageTurnAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(widget.forward ? _animation.value * 0.5 : -_animation.value * 0.5),
          alignment: widget.forward ? Alignment.centerLeft : Alignment.centerRight,
          child: child,
        );
      },
      child: widget.child,
    );
  }
} 