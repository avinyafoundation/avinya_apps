import 'package:flutter/material.dart';
import '../data/task_item.dart';

class AnimatedTaskCard extends StatefulWidget {
  final TaskItem item;
  final Color accentColor;
  final String groupId;

  const AnimatedTaskCard({
    super.key,
    required this.item,
    required this.accentColor,
    required this.groupId,
  });

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Setup Pulse Animation
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    if (widget.groupId != 'completed') {
      _controller.repeat(reverse: true);
    }

    // 2. Determine Color Logic
    Color baseColor = Colors.transparent;
    Color targetColor = Colors.transparent;

    if (widget.groupId != 'completed') {
      if (widget.item.isOverdue) {
        // Red Pulse for Overdue
        targetColor = Colors.red.withOpacity(0.6);
      } else if (widget.item.overdueDays >= -2) {
        // Blue Pulse for Ahead of Schedule
        targetColor = Colors.amber.withOpacity(0.6);
      }
    }

    _colorAnimation = ColorTween(begin: baseColor, end: targetColor)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool areAnimationsEnabled = widget.groupId != 'completed';

    return MouseRegion(
      cursor: areAnimationsEnabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) {
        if (areAnimationsEnabled) setState(() => _isHovering = true);
      },
      onExit: (_) {
        if (areAnimationsEnabled) setState(() => _isHovering = false);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 360,
            // Scale Effect
            transform: _isHovering
                ? Matrix4.identity().scaled(1.02)
                : Matrix4.identity(),
            // Margin: Only bottom margin needed here
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color:
                      widget.accentColor.withOpacity(_isHovering ? 0.15 : 0.02),
                  blurRadius: _isHovering ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
                // The Pulsing Glow Shadow
                BoxShadow(
                  color: _colorAnimation.value ?? Colors.transparent,
                  blurRadius: 5,
                  spreadRadius: 0.5,
                  offset:
                      const Offset(0, 5), // Pushes glow to bottom margin area
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  // 1. CARD CONTENT
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Shrink to fit content
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF172B4D)),
                        ),
                        if (widget.item.description != null &&
                            widget.item.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(widget.item.description!,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.item.isOverdue
                                    ? Colors.red.shade50
                                    : (widget.item.overdueDays < -2
                                        ? Colors.blue.shade50
                                        : Colors.amber.shade50),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                widget.item.statusText.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: widget.item.isOverdue
                                      ? Colors.red
                                      : (widget.item.overdueDays < -2
                                          ? Colors.blue.shade800
                                          : Colors.amber.shade800),
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.calendar_today,
                                size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                                widget.item.endDate
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0],
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                  ),
                  // 2. ANIMATED BAR (Simply static here for stability)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                        width: 4,
                        decoration: BoxDecoration(color: widget.accentColor)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
