import 'package:flutter/material.dart';

class AnimatedStatusIcon extends StatefulWidget {
  final String status; // "Pending", "progress", "Completed"
  final Color color;

  const AnimatedStatusIcon({super.key, required this.status, required this.color});

  @override
  State<AnimatedStatusIcon> createState() => _AnimatedStatusIconState();
}

class _AnimatedStatusIconState extends State<AnimatedStatusIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    if (widget.status == "progress") {
      _controller.repeat(); // Spin forever
    } else if (widget.status == "pending") {
      _controller.repeat(reverse: true); // Pulse (Fade in/out)
    }
    // Completed is static, no animation needed
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == "progress") {
      return RotationTransition(
        turns: _controller,
        child: Icon(Icons.sync, color: widget.color, size: 20),
      );
    } else if (widget.status == "pending") {
      return ScaleTransition(
        scale: Tween(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
        child: Icon(Icons.radio_button_unchecked, color: widget.color, size: 20),
      );
    } else {
      return Icon(Icons.check_box, color: widget.color, size: 20);
    }
  }
}