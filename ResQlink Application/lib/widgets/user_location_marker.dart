import 'package:flutter/material.dart';

class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 45,
      child: CustomPaint(
        painter: UserLocationPainter(),
      ),
    );
  }
}

class UserLocationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw the outer blue circle
    final outerCirclePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.4,
      outerCirclePaint,
    );

    // Draw the inner white circle
    final innerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.35,
      innerCirclePaint,
    );

    // Draw the user icon in blue
    final userPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Head (circle)
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.35),
      size.width * 0.12,
      userPaint,
    );

    // Body (rounded rectangle)
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.35, size.height * 0.45);
    bodyPath.lineTo(size.width * 0.65, size.height * 0.45);
    bodyPath.quadraticBezierTo(
      size.width * 0.65, size.height * 0.55,
      size.width * 0.5, size.height * 0.55
    );
    bodyPath.quadraticBezierTo(
      size.width * 0.35, size.height * 0.55,
      size.width * 0.35, size.height * 0.45
    );
    
    canvas.drawPath(bodyPath, userPaint);

    // Draw the bottom pointer
    final pointerPath = Path();
    pointerPath.moveTo(size.width * 0.3, size.height * 0.7);
    pointerPath.lineTo(size.width * 0.5, size.height * 0.9);
    pointerPath.lineTo(size.width * 0.7, size.height * 0.7);
    pointerPath.close();

    canvas.drawPath(pointerPath, outerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
