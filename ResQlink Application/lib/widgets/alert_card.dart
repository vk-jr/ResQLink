import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;

  const AlertCard({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: backgroundColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
