import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';
import '../../app/theme/app_colors.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: _SplashBody(),
    );
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody();

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _handProgress;
  late final Animation<double> _bagSlideProgress;
  late final Animation<double> _bagBounceProgress;
  late final Animation<double> _textFadeProgress;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _handProgress = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );

    _bagSlideProgress = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
    );

    _bagBounceProgress = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.65, 1.0, curve: Curves.linear),
    );

    _textFadeProgress = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.6, 0.95, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _anim.forward());
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final double handX = (1.0 - _handProgress.value) * -screenWidth;

          double bagX = 0;
          double bagY = 0;

          if (_anim.value < 0.65) {
            bagX = (1.0 - _bagSlideProgress.value) * screenWidth;
            bagY = (1.0 - _bagSlideProgress.value) * -100;
          } else {
            final double t = _bagBounceProgress.value;
            bagX = 0;
            if (t > 0 && t < 1.0) {
              if (t < 0.5) {
                final double x = (t - 0.25) / 0.25;
                bagY = -28 * (1.0 - x * x);
              } else {
                final double x = (t - 0.75) / 0.25;
                bagY = -10 * (1.0 - x * x);
              }
            }
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 10,
                      bottom: 20,
                      child: Transform.translate(
                        offset: Offset(handX, 0),
                        child: Image.asset(
                          'assets/logo/hand.png',
                          width: 140,
                          height: 110,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 70,
                      bottom: 80,
                      child: Transform.translate(
                        offset: Offset(bagX, bagY),
                        child: CustomPaint(
                          size: const Size(90, 90),
                          painter: _MoneyBagPainter(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Opacity(
                opacity: _textFadeProgress.value,
                child: Column(
                  children: [
                    Text(
                      'app_name'.tr,
                      style: TextStyle(
                        color: AppColors.accentPurple,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'tagline'.tr,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class _MoneyBagPainter extends CustomPainter {
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
