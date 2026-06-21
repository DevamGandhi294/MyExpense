import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated financial graph loader that matches the SVG asset.
/// Uses a CustomPainter + AnimationController — works on all platforms.
class AppLoader extends StatefulWidget {
  final double size;
  const AppLoader({super.key, this.size = 80});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _GraphLinePainter(_ctrl.value),
          ),
        ),
      ),
    );
  }
}

class _GraphLinePainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  _GraphLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6B00DB)
      ..strokeWidth = size.width * 0.055
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Build the wavy graph path — 5 control points like the SVG
    // Each point oscillates slightly so the line "breathes"
    final wave = math.sin(progress * 2 * math.pi);
    final wave2 = math.sin(progress * 2 * math.pi + 1.2);

    final path = Path();

    // Start point — bottom left
    path.moveTo(0, h * (0.78 + wave * 0.04));

    // Segment 1: rise up to mid-left dip
    path.cubicTo(
      w * 0.15, h * (0.78 + wave * 0.04),
      w * 0.20, h * (0.30 + wave2 * 0.05),
      w * 0.28, h * (0.28 + wave2 * 0.04),
    );

    // Segment 2: bounce back up
    path.cubicTo(
      w * 0.35, h * (0.26 + wave * 0.03),
      w * 0.38, h * (0.55 + wave2 * 0.04),
      w * 0.44, h * (0.54 + wave * 0.04),
    );

    // Segment 3: sharp dip then recovery
    path.cubicTo(
      w * 0.55, h * (0.52 + wave2 * 0.03),
      w * 0.52, h * (0.10 + wave * 0.05),
      w * 0.60, h * (0.05 + wave2 * 0.04),
    );

    // Segment 4: up then small drop
    path.cubicTo(
      w * 0.68, h * (0.00 + wave * 0.04),
      w * 0.75, h * (0.22 + wave2 * 0.04),
      w * 0.80, h * (0.18 + wave * 0.03),
    );

    // Segment 5: to top-right endpoint
    path.cubicTo(
      w * 0.85, h * (0.14 + wave2 * 0.03),
      w * 0.90, h * (0.10 + wave * 0.04),
      w * 1.00, h * (0.08 + wave2 * 0.03),
    );

    // Animate a travelling dash effect identical to stroke-dashoffset in SVG
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final metric = pathMetrics.first;
    final totalLen = metric.length;

    // Dash window = 30% of total length, travels forward over time
    const dashFraction = 0.38;
    final dashLen = totalLen * dashFraction;
    final offset = (progress * totalLen * 1.6) % (totalLen + dashLen) - dashLen;

    final start = offset.clamp(0.0, totalLen);
    final end = (offset + dashLen).clamp(0.0, totalLen);

    if (end > start) {
      final dashPath = metric.extractPath(start, end);
      canvas.drawPath(dashPath, paint);
    }
  }

  @override
  bool shouldRepaint(_GraphLinePainter old) => old.progress != progress;
}
