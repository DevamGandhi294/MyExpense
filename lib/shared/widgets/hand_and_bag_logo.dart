import 'package:flutter/material.dart';
import 'package:myexpense/app/theme/app_colors.dart';

class HandAndBagLogo extends StatelessWidget {
  final double size;

  const HandAndBagLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final scale = size / 48;
    return SizedBox(
      width: size,
      height: size * (40 / 48),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 2 * scale,
            bottom: 2 * scale,
            child: Image.asset(
              'assets/logo/hand.png',
              width: 32 * scale,
              height: 25 * scale,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 16 * scale,
            bottom: 16 * scale,
            child: CustomPaint(
              size: Size(20 * scale, 20 * scale),
              painter: _MoneyBagPainter(scale: scale),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyBagPainter extends CustomPainter {
  final double scale;

  _MoneyBagPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentPurple
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double sx = size.width / 80;
    final double sy = size.height / 80;

    canvas.save();
    canvas.scale(sx, sy);

    final bagPath = Path()
      ..moveTo(35, 26)
      ..cubicTo(18, 28, 12, 55, 20, 68)
      ..quadraticBezierTo(18, 72, 23, 72)
      ..quadraticBezierTo(40, 65, 57, 72)
      ..quadraticBezierTo(62, 72, 60, 68)
      ..cubicTo(68, 55, 62, 28, 45, 26)
      ..close();
    canvas.drawPath(bagPath, paint);

    final tiePath = Path()
      ..moveTo(33, 26)
      ..quadraticBezierTo(40, 30, 47, 26)
      ..quadraticBezierTo(40, 22, 33, 26)
      ..close();
    canvas.drawPath(tiePath, paint);

    final topFlaps = Path()
      ..moveTo(33, 23)
      ..cubicTo(25, 12, 35, 8, 40, 16)
      ..cubicTo(45, 8, 55, 12, 47, 23)
      ..close();
    canvas.drawPath(topFlaps, paint);

    canvas.drawCircle(const Offset(40, 49), 12, paint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '₹',
        style: TextStyle(
          color: AppColors.accentPurple,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    textPainter.paint(
      canvas,
      Offset(40 - textPainter.width / 2, 49 - textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
