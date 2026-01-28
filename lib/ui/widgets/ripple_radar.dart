import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

class RippleRadar extends StatefulWidget {
  const RippleRadar({
    super.key,
    required this.child,
    this.size = 150,
    this.ringColor = const Color(0xFF5BC0FF),
  });

  final Widget child;
  final double size;
  final Color ringColor;

  @override
  State<RippleRadar> createState() => _RippleRadarState();
}

class _RippleRadarState extends State<RippleRadar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return CustomPaint(
            painter: _RipplePainter(
              t: _c.value,
              color: widget.ringColor,
            ),
            child: Center(child: widget.child),
          );
        },
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({required this.t, required this.color});
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2;

    for (int i = 0; i < 3; i++) {
      final phase = (t + i * 0.22) % 1.0;
      final r = lerpDouble(maxR * 0.25, maxR, phase)!;
      final opacity = (1.0 - phase).clamp(0.0, 1.0) * 0.35;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color.withOpacity(opacity);
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}

