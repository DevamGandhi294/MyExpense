import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SplashBody(),
    );
  }
}

// Separate StatefulWidget so we can drive the fade-in animation cleanly
// without needing an AnimationController inside GetxController.
class _SplashBody extends StatefulWidget {
  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));

    // Start animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _anim.forward());
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.45, 1.0],
          colors: [
            Color(0xFF3D35C4), // deep indigo
            Color(0xFF5A3DC8), // mid purple-blue
            Color(0xFF8B2FC9), // vivid purple
          ],
        ),
      ),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo card ─────────────────────────────────────────────
              _LogoCard(),
              const SizedBox(height: 32),

              // ── App name ───────────────────────────────────────────────
              const Text(
                'MyExpense',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),

              // ── Tagline ────────────────────────────────────────────────
              const Text(
                'Track Smart. Save More.',
                style: TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A1FA0).withOpacity(0.45),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          'assets/logo/logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _CheckIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Custom painted checkmark so it matches the original logo exactly —
    // thick rounded stroke, not a filled icon glyph.
    return CustomPaint(
      size: const Size(52, 52),
      painter: _CheckPainter(),
    );
  }
}

class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      // Start of short left arm of check
      ..moveTo(size.width * 0.14, size.height * 0.52)
      // Down to the bottom point
      ..lineTo(size.width * 0.40, size.height * 0.76)
      // Up to top-right
      ..lineTo(size.width * 0.86, size.height * 0.26);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}