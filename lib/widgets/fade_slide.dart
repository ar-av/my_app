import 'package:flutter/material.dart';

class FadeSlide extends StatefulWidget {
  final Widget child;
  final int index; // 0 = first item, 1 = second (adds delay)

  const FadeSlide({super.key, required this.child, required this.index});

  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Duration of animation
    );

    // SLIDE UP EFFECT
    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, 0.2), // Start slightly down
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // FADE IN EFFECT
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // DELAY (The "Stagger" Effect)
    // Item 0 starts at 0ms, Item 1 at 100ms, Item 2 at 200ms...
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _offsetAnim,
        child: widget.child,
      ),
    );
  }
}