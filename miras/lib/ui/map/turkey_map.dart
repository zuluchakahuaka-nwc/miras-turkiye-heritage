import 'package:flutter/material.dart';

const List<List<double>> kTurkeyOutline = [
  [26.35, 41.72], [26.05, 41.35], [26.20, 40.75], [26.68, 40.52],
  [26.22, 40.05], [26.10, 39.78], [26.60, 39.45], [26.85, 39.10],
  [26.75, 38.85], [26.30, 38.62], [26.68, 38.40], [27.15, 38.32],
  [27.05, 37.95], [27.30, 37.68], [27.05, 37.12], [27.45, 37.02],
  [27.95, 36.72], [28.25, 36.75], [29.10, 36.62], [29.60, 36.20],
  [30.55, 36.78], [31.35, 36.85], [32.05, 36.55], [32.80, 36.07],
  [33.75, 36.40], [34.62, 36.75], [35.35, 36.55], [36.10, 36.62],
  [36.55, 36.83], [37.20, 36.85], [38.00, 36.72], [39.05, 36.62],
  [39.90, 36.72], [40.95, 37.15], [42.35, 37.32], [43.45, 37.28],
  [44.05, 37.28], [44.40, 37.75], [44.55, 38.35], [44.80, 39.65],
  [44.35, 39.95], [43.55, 41.10], [42.80, 41.40], [41.42, 41.40],
  [40.15, 41.42], [39.45, 41.10], [38.40, 40.95], [37.55, 41.05],
  [36.85, 41.30], [36.10, 41.45], [35.35, 42.05], [34.70, 41.95],
  [34.00, 42.05], [33.55, 42.02], [32.85, 41.85], [32.15, 41.70],
  [31.45, 41.35], [30.75, 41.25], [30.05, 41.20], [29.35, 41.15],
  [29.05, 41.05], [28.95, 40.95], [28.70, 40.95], [28.20, 40.97],
  [27.60, 40.95], [27.05, 40.55],
];

const double _minLon = 25.60;
const double _maxLat = 42.40;
const double _cosMidLat = 0.777;
const double _lonSpan = 19.60;
const double _latSpan = 6.60;
const double _pxPerDeg = 61.2;
const double kMapBaseWidth = _pxPerDeg * _lonSpan * _cosMidLat;
const double kMapBaseHeight = _pxPerDeg * _latSpan;

class TurkeyGeometry {
  static Offset project(double lat, double lon) => Offset(
        (lon - _minLon) * _cosMidLat * _pxPerDeg,
        (_maxLat - lat) * _pxPerDeg,
      );

  static Path buildOutlinePath() {
    final path = Path();
    for (var i = 0; i < kTurkeyOutline.length; i++) {
      final p = project(kTurkeyOutline[i][1], kTurkeyOutline[i][0]);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }
}

class TurkeyCity {
  final String name;
  final double lat;
  final double lon;
  final String side;

  const TurkeyCity(this.name, this.lat, this.lon, [this.side = 'e']);
}

const List<TurkeyCity> kTurkeyCities = [
  TurkeyCity('İstanbul', 41.01, 28.97, 'w'),
  TurkeyCity('Ankara', 39.93, 32.86, 'n'),
  TurkeyCity('İzmir', 38.42, 27.14, 'w'),
  TurkeyCity('Bursa', 40.19, 29.06, 'n'),
  TurkeyCity('Konya', 37.87, 32.49, 'w'),
  TurkeyCity('Antalya', 36.90, 30.70, 'w'),
  TurkeyCity('Adana', 37.00, 35.32, 's'),
  TurkeyCity('Samsun', 41.29, 36.33, 'n'),
  TurkeyCity('Trabzon', 41.00, 39.72, 'n'),
  TurkeyCity('Erzurum', 39.90, 41.27, 'n'),
  TurkeyCity('Gaziantep', 37.07, 37.38, 's'),
  TurkeyCity('Diyarbakır', 37.91, 40.24, 'e'),
  TurkeyCity('Van', 38.49, 43.38, 'e'),
  TurkeyCity('Kars', 40.60, 43.09, 'n'),
];

class TurkeyRoad {
  final String name;
  final List<List<double>> points;
  final List<double> labelAt;

  const TurkeyRoad(this.name, this.points, this.labelAt);
}

const List<TurkeyRoad> kTurkeyRoads = [
  TurkeyRoad('E80', [
    [29.10, 41.00], [31.60, 40.70], [32.86, 39.95], [37.00, 39.75],
    [41.20, 39.92], [43.10, 39.72], [44.35, 39.45],
  ], [36.60, 39.80]),
  TurkeyRoad('E90', [
    [27.15, 38.42], [29.40, 38.68], [30.55, 39.78], [32.86, 39.93],
  ], [29.90, 38.72]),
  TurkeyRoad('O-3', [
    [28.90, 41.05], [27.90, 41.30], [26.55, 41.67],
  ], [27.70, 41.32]),
  TurkeyRoad('D400', [
    [29.10, 36.62], [30.70, 36.90], [32.00, 36.55], [34.60, 36.80],
    [36.10, 36.62], [36.45, 36.75],
  ], [31.30, 36.85]),
  TurkeyRoad('D750', [
    [36.33, 41.29], [35.50, 40.85], [33.60, 40.60], [32.86, 39.93],
  ], [35.10, 40.95]),
];

class TurkeyMapPainter extends CustomPainter {
  final Color land;
  final Color border;
  final Color sea;
  final Color road;
  final Color city;

  TurkeyMapPainter({
    this.land = const Color(0xFFF7F2E5),
    this.border = const Color(0xFF14636B),
    this.sea = const Color(0xFFE8F2EE),
    this.road = const Color(0xFF8D7B5A),
    this.city = const Color(0xFF0E2A2B),
  });

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dash = 8.0;
    const gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      var draw = true;
      while (dist < metric.length) {
        final len = draw ? dash : gap;
        var next = dist + len;
        if (next > metric.length) next = metric.length;
        if (draw) {
          canvas.drawPath(metric.extractPath(dist, next), paint);
        }
        dist = next;
        draw = !draw;
      }
    }
  }

  TextPainter _label(String text, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: size,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp;
  }

  void _pill(Canvas canvas, Offset at, Size size, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(at & size, const Radius.circular(4)),
      Paint()..color = color,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      Paint()..color = sea,
    );
    final landPaint = Paint()..color = land;
    final borderPaint = Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round;
    final path = TurkeyGeometry.buildOutlinePath();
    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, borderPaint);

    final roadPaint = Paint()
      ..color = road
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (final r in kTurkeyRoads) {
      final rp = Path();
      for (var i = 0; i < r.points.length; i++) {
        final p = TurkeyGeometry.project(r.points[i][1], r.points[i][0]);
        if (i == 0) {
          rp.moveTo(p.dx, p.dy);
        } else {
          rp.lineTo(p.dx, p.dy);
        }
      }
      _drawDashed(canvas, rp, roadPaint);
      final lp = TurkeyGeometry.project(r.labelAt[1], r.labelAt[0]);
      final tp = _label(r.name, 12, const Color(0xFF6B5D3F));
      _pill(canvas, lp + Offset(-2, -tp.height / 2 - 1), Size(tp.width + 6, tp.height + 2), const Color(0xCCFFFFFF));
      tp.paint(canvas, lp + Offset(1, -tp.height / 2));
    }

    final cityDot = Paint()..color = city;
    final ring = Paint()..color = Colors.white;
    for (final c in kTurkeyCities) {
      final p = TurkeyGeometry.project(c.lat, c.lon);
      canvas.drawCircle(p, 4.6, ring);
      canvas.drawCircle(p, 3.4, cityDot);
      final tp = _label(c.name, 12.5, city);
      Offset at;
      switch (c.side) {
        case 'w':
          at = Offset(p.dx - tp.width - 10, p.dy - tp.height / 2);
        case 'n':
          at = Offset(p.dx - tp.width / 2, p.dy - tp.height - 9);
        case 's':
          at = Offset(p.dx - tp.width / 2, p.dy + 9);
        default:
          at = Offset(p.dx + 10, p.dy - tp.height / 2);
      }
      _pill(canvas, at + const Offset(-3, -1), Size(tp.width + 6, tp.height + 2), const Color(0xB3FFFFFF));
      tp.paint(canvas, at);
    }
  }

  @override
  bool shouldRepaint(covariant TurkeyMapPainter oldDelegate) =>
      oldDelegate.land != land ||
      oldDelegate.border != border ||
      oldDelegate.sea != sea ||
      oldDelegate.road != road ||
      oldDelegate.city != city;
}
