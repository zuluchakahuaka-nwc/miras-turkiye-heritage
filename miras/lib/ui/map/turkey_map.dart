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

class TurkeyRoute {
  final String from;
  final List<List<double>> points;

  const TurkeyRoute(this.from, this.points);
}

const Map<String, List<TurkeyRoute>> kSiteRoutes = {
  'gobekli-tepe': [TurkeyRoute('Şanlıurfa', [[38.79, 37.17], [38.92, 37.22]])],
  'catalhoyuk': [TurkeyRoute('Konya', [[32.86, 37.93], [32.60, 37.57], [32.83, 37.67]])],
  'gordion': [TurkeyRoute('Ankara', [[32.86, 39.93], [32.39, 39.71]])],
  'hattusa': [TurkeyRoute('Ankara', [[32.86, 39.93], [34.40, 40.16], [34.61, 40.02]])],
  'sardis': [TurkeyRoute('İzmir', [[27.14, 38.42], [28.04, 38.49]])],
  'troy': [TurkeyRoute('Çanakkale', [[26.41, 40.15], [26.24, 39.96]])],
  'ephesus': [TurkeyRoute('İzmir', [[27.14, 38.42], [27.40, 38.30], [27.34, 37.94]])],
  'side': [TurkeyRoute('Antalya', [[30.71, 36.90], [31.39, 37.06], [31.38, 36.77]])],
  'aspendos': [TurkeyRoute('Antalya', [[30.71, 36.90], [31.17, 36.95]])],
  'pergamon': [TurkeyRoute('İzmir', [[27.14, 38.42], [27.18, 39.13]])],
  'miletus': [TurkeyRoute('Aydın', [[27.85, 37.85], [27.23, 37.53]])],
  'aphrodisias': [TurkeyRoute('Denizli', [[29.09, 37.78], [28.72, 37.71]])],
  'nemrut': [TurkeyRoute('Adıyaman', [[38.28, 37.76], [38.74, 37.98]])],
  'pamukkale': [TurkeyRoute('Denizli', [[29.09, 37.78], [29.12, 37.92]])],
  'myra': [TurkeyRoute('Antalya', [[30.71, 36.90], [29.99, 36.25]])],
  'halicarnassus': [TurkeyRoute('Milas', [[27.78, 37.30], [27.42, 37.04]])],
  'cappadocia': [
    TurkeyRoute('Kayseri', [[35.48, 38.73], [34.87, 38.62]]),
    TurkeyRoute('Ankara', [[32.86, 39.93], [34.03, 38.37], [34.87, 38.62]]),
  ],
  'hagia-sophia': [TurkeyRoute('IST airport', [[28.74, 41.26], [28.98, 41.01]])],
  'basilica-cistern': [TurkeyRoute('IST airport', [[28.74, 41.26], [28.98, 41.01]])],
  'topkapi': [TurkeyRoute('IST airport', [[28.74, 41.26], [29.01, 41.01]])],
  'dolmabahce': [TurkeyRoute('IST airport', [[28.74, 41.26], [29.00, 41.04]])],
  'ani': [TurkeyRoute('Kars', [[43.09, 40.60], [43.57, 40.51]])],
  'sumela': [TurkeyRoute('Trabzon', [[39.72, 41.01], [39.69, 40.76]])],
  'selimiye': [TurkeyRoute('İstanbul', [[28.98, 41.01], [26.56, 41.68]])],
  'ishak-pasha': [TurkeyRoute('Ağrı', [[43.05, 39.92], [44.13, 39.52]])],
  'anitkabir': [TurkeyRoute('ESB airport', [[32.99, 40.12], [32.84, 39.93]])],
};

void drawDashedPath(Canvas canvas, Path path, Paint paint) {
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

class SiteRoutesPainter extends CustomPainter {
  final List<TurkeyRoute> routes;
  final Color color;

  SiteRoutesPainter(this.routes, {this.color = const Color(0xFF8A6D1C)});

  TextPainter _label(String text) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
          color: Color(0xFF5C4A12),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final startRing = Paint()..color = Colors.white;
    final startDot = Paint()..color = color;

    for (final r in routes) {
      final pts = r.points
          .map((p) => TurkeyGeometry.project(p[1], p[0]))
          .toList();
      final path = Path();
      for (var i = 0; i < pts.length; i++) {
        if (i == 0) {
          path.moveTo(pts.first.dx, pts.first.dy);
        } else {
          path.lineTo(pts[i].dx, pts[i].dy);
        }
      }
      drawDashedPath(canvas, path, paint);

      canvas.drawCircle(pts.first, 6.5, startRing);
      canvas.drawCircle(pts.first, 4.5, startDot);

      final last = pts.last;
      final prev = pts[pts.length - 2];
      final dir = (last - prev);
      final len = dir.distance;
      if (len > 0) {
        final unit = dir / len;
        final perp = Offset(-unit.dy, unit.dx);
        final tip = last - unit * 14;
        final arrow = Path()
          ..moveTo(last.dx, last.dy)
          ..lineTo(tip.dx + perp.dx * 6, tip.dy + perp.dy * 6)
          ..lineTo(tip.dx - perp.dx * 6, tip.dy - perp.dy * 6)
          ..close();
        canvas.drawPath(arrow, startDot);
      }

      final tp = _label(r.from);
      final at = pts.first + Offset(-tp.width / 2, -tp.height - 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(at & Size(tp.width + 6, tp.height + 2), const Radius.circular(4)),
        Paint()..color = const Color(0xD9FFFFFF),
      );
      tp.paint(canvas, at + const Offset(3, 1));
    }
  }

  @override
  bool shouldRepaint(covariant SiteRoutesPainter oldDelegate) =>
      oldDelegate.routes != routes;
}

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
      drawDashedPath(canvas, rp, roadPaint);
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
