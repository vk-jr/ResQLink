import 'package:flutter/material.dart';

class CampMarker extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const CampMarker({
    Key? key,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.8) : Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: CustomPaint(
            painter: CampIconPainter(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class CampIconPainter extends CustomPainter {
  final Color color;

  CampIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Draw a triangle for the tent
    path.moveTo(size.width * 0.2, size.height * 0.8); // Bottom left
    path.lineTo(size.width * 0.8, size.height * 0.8); // Bottom right
    path.lineTo(size.width * 0.5, size.height * 0.2); // Top center
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CampIconPainter oldDelegate) => color != oldDelegate.color;
}
