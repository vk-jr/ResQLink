import 'package:flutter/material.dart';

class ActionIconButton extends StatefulWidget {
  final Color backgroundColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double? iconSize; // New optional parameter
  final double? avatarRadius; // New optional parameter

  const ActionIconButton({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconSize,
    this.avatarRadius,
  });

  @override
  State<ActionIconButton> createState() => _ActionIconButtonState();
}

class _ActionIconButtonState extends State<ActionIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.backgroundColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: widget.onTap,
              child: CircleAvatar(
                radius: widget.avatarRadius ?? 28,
                backgroundColor: widget.backgroundColor,
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.iconSize ?? 28,
                  semanticLabel: '${widget.label} icon',
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
