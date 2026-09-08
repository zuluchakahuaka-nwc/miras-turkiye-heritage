import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme.dart';

class IznikPatternPainter extends CustomPainter {
  final Color stroke;
  final double tile;

  IznikPatternPainter({this.stroke = const Color(0x2EE8C766), this.tile = 72});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = stroke;
    for (double x = 0; x < size.width + tile; x += tile) {
      for (double y = 0; y < size.height + tile; y += tile) {
        final center = Offset(x, y);
        canvas.drawCircle(center, tile * 0.5, paint);
        canvas.drawCircle(center, tile * 0.2, paint);
        final rect = Rect.fromCircle(center: center, radius: tile * 0.35);
        canvas.drawRect(rect, paint);
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(
          Rect.fromCircle(center: Offset.zero, radius: tile * 0.35),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant IznikPatternPainter oldDelegate) =>
      oldDelegate.stroke != stroke || oldDelegate.tile != tile;
}

class MeanderPainter extends CustomPainter {
  final Color color;

  MeanderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color
      ..strokeCap = StrokeCap.square;
    const unit = 22.0;
    final h = size.height;
    final path = Path();
    var i = 0;
    for (double x = 0; x < size.width; x += unit) {
      final x0 = i * unit.toDouble();
      path.moveTo(x0, h);
      path.lineTo(x0, 3);
      path.lineTo(x0 + unit - 6, 3);
      path.lineTo(x0 + unit - 6, h - 7);
      path.lineTo(x0 + 7, h - 7);
      path.lineTo(x0 + 7, 8);
      i++;
    }
    canvas.drawPath(path, paint);
    final base = Path()
      ..moveTo(0, h)
      ..lineTo(size.width, h);
    canvas.drawPath(base, paint);
  }

  @override
  bool shouldRepaint(covariant MeanderPainter oldDelegate) =>
      oldDelegate.color != color;
}

class IznikBackground extends StatelessWidget {
  final Widget child;
  final Color background;

  const IznikBackground({
    super.key,
    required this.child,
    this.background = MirasColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: background),
      child: CustomPaint(
        painter: IznikPatternPainter(),
        child: child,
      ),
    );
  }
}

class MeanderDivider extends StatelessWidget {
  final Color color;
  final double height;

  const MeanderDivider({
    super.key,
    this.color = MirasColors.gold,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: MeanderPainter(color: color)),
    );
  }
}

class OrnamentPlaceholder extends StatelessWidget {
  final String? caption;

  const OrnamentPlaceholder({super.key, this.caption});

  @override
  Widget build(BuildContext context) {
    return IznikBackground(
      background: MirasColors.teal,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance,
              size: 42,
              color: MirasColors.goldLight,
            ),
            if (caption != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  caption!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: MirasColors.ivory,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
