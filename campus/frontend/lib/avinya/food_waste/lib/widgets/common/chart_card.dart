import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  final Widget child;
  final double? cardRadius;
  final EdgeInsetsGeometry? padding;

  const ChartCard({
    super.key,
    required this.child,
    this.cardRadius = 12.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
