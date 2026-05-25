import 'package:flutter/material.dart';

class StatCard extends StatefulWidget {
  final double? width;
  final String title;
  final String value;
  final String? subtitle;
  final Color accentColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final double cardRadius;
  final Color primaryText;
  final Color secondaryText;

  const StatCard({
    super.key,
    this.width,
    required this.title,
    required this.value,
    this.subtitle,
    this.accentColor = Colors.transparent,
    this.icon,
    this.onTap,
    this.cardRadius = 12.0,
    this.primaryText = const Color(0xFF172B4D),
    this.secondaryText = const Color(0xFF6B778C),
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.onTap != null;
    final hasIcon = widget.icon != null;

    return MouseRegion(
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: isClickable ? (_) => setState(() => _isHovered = true) : null,
      onExit: isClickable ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: isClickable && _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width ?? double.infinity,
            padding: hasIcon 
                ? const EdgeInsets.all(16) 
                : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isClickable && _isHovered ? 0.12 : 0.04),
                  blurRadius: isClickable && _isHovered ? 28 : 20,
                  offset: Offset(0, isClickable && _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: hasIcon ? _buildWithIcon() : _buildSimple(),
          ),
        ),
      ),
    );
  }

  Widget _buildSimple() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: widget.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.accentColor != Colors.transparent)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          widget.value,
          style: TextStyle(
            color: widget.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.subtitle != null)
          Text(
            widget.subtitle!,
            style: TextStyle(
              color: widget.secondaryText.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
      ],
    );
  }

  Widget _buildWithIcon() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, color: widget.accentColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: widget.primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
