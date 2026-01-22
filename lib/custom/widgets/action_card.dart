import 'package:flutter/material.dart';

class ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              widget.icon,
              color: widget.iconColor ?? Colors.grey,
              size: 28,
            ),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: widget.titleColor ?? Colors.grey,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
