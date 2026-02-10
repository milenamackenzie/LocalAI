import 'package:flutter/material.dart';
import 'dart:math' as math;

class MapBackground extends StatelessWidget {
  final Widget child;

  const MapBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The "Sea" - Blue background
        Container(
          color: const Color(0xFFE3F2FD), // Light Blue
        ),
        // Abstract "Countries" - Green shapes
        const Positioned.fill(
          child: CustomPaint(
            painter: _MapPainter(),
          ),
        ),
        // Optional overlay to make text more readable
        Container(
          color: Colors.white.withOpacity(0.1),
        ),
        child,
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF81C784).withOpacity(0.4) // Green
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Seed for consistency

    for (var i = 0; i < 8; i++) {
      final path = Path();
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      
      path.moveTo(startX, startY);
      
      // Create a blob-like shape
      var currentX = startX;
      var currentY = startY;
      final points = 5 + random.nextInt(5);
      
      for (var j = 0; j < points; j++) {
        currentX += (random.nextDouble() - 0.5) * size.width * 0.4;
        currentY += (random.nextDouble() - 0.5) * size.height * 0.4;
        
        final controlX = currentX + (random.nextDouble() - 0.5) * 50;
        final controlY = currentY + (random.nextDouble() - 0.5) * 50;
        
        path.quadraticBezierTo(controlX, controlY, currentX, currentY);
      }
      
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
