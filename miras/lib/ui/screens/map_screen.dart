import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/sites.dart';
import '../../l10n/strings.dart';
import '../map/turkey_map.dart';
import 'detail_screen.dart';

const Map<Era, Color> kEraMarkerColors = {
  Era.ancientWorld: Color(0xFFC9A227),
  Era.antiquity: Color(0xFF2AA198),
  Era.byzantium: Color(0xFFB0532F),
  Era.ottoman: Color(0xFF14636B),
  Era.republic: Color(0xFFC0392B),
};

const Map<String, Offset> kMarkerNudges = {
  'hagia-sophia': Offset(14, 10),
  'basilica-cistern': Offset(0, 20),
  'topkapi': Offset(24, 0),
  'dolmabahce': Offset(10, -8),
  'ephesus': Offset(6, -6),
  'miletus': Offset(-8, 12),
};

class MapScreen extends StatefulWidget {
  final AppLang lang;

  const MapScreen({super.key, required this.lang});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TransformationController _controller = TransformationController();
  bool _fitted = false;
  String? _selectedId;
  static const double baseW = kMapBaseWidth;
  static const double baseH = kMapBaseHeight;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleMarkerTap(Site site) {
    if (_selectedId == site.id) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SiteDetailScreen(site: site, lang: widget.lang)),
      );
    } else {
      setState(() => _selectedId = site.id);
    }
  }

  void _openDetail(Site site) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SiteDetailScreen(site: site, lang: widget.lang)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: MirasColors.paper,
      appBar: AppBar(
        title: Text(
          t(lang, 'section.map'),
          key: const Key('map.title'),
          style: const TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            tooltip: t(lang, 'action.sources'),
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
            child: Row(
              children: [
                Icon(Icons.touch_app, size: 16, color: MirasColors.teal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t(lang, 'map.hint'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: Era.values
                  .map((e) => _LegendChip(era: e, lang: lang))
                  .toList(),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (!_fitted) {
                  final s = constraints.biggest;
                  final scale = s.width / baseW;
                  final tx = (s.width - baseW * scale) / 2;
                  final ty = (s.height - baseH * scale) / 2;
                  _controller.value = Matrix4.translationValues(tx, ty, 0)
                      .multiplied(Matrix4.diagonal3Values(scale, scale, 1));
                  _fitted = true;
                }
                return GestureDetector(
                  onTap: () => setState(() => _selectedId = null),
                  child: InteractiveViewer(
                    transformationController: _controller,
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: 0.35,
                    maxScale: 8,
                    child: SizedBox(
                      key: const Key('map.canvas'),
                      width: baseW,
                      height: baseH,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(painter: TurkeyMapPainter()),
                          ),
                          for (final site in kSites)
                            _MapMarker(
                              site: site,
                              lang: widget.lang,
                              selected: _selectedId == site.id,
                              onTap: () => _handleMarkerTap(site),
                            ),
                          if (_selectedId != null)
                            _SelectedLabel(
                              site: kSites.firstWhere((s) => s.id == _selectedId),
                              lang: widget.lang,
                              onTap: () => _openDetail(
                                kSites.firstWhere((s) => s.id == _selectedId),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Era era;
  final AppLang lang;

  const _LegendChip({required this.era, required this.lang});

  @override
  Widget build(BuildContext context) {
    final color = kEraMarkerColors[era]!;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x2214636B)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              eraLabel(era).by(lang),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                color: MirasColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedLabel extends StatelessWidget {
  final Site site;
  final AppLang lang;
  final VoidCallback onTap;

  const _SelectedLabel({required this.site, required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pos = TurkeyGeometry.project(site.lat, site.lon) +
        (kMarkerNudges[site.id] ?? Offset.zero);
    final color = kEraMarkerColors[site.era]!;
    return Positioned(
      left: pos.dx - 95,
      top: pos.dy - 46,
      width: 190,
      child: Center(
        child: GestureDetector(
          key: Key('map.label.${site.id}'),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color, width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x55000000), blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    site.name.by(lang),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: MirasColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 10, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final Site site;
  final AppLang lang;
  final bool selected;
  final VoidCallback onTap;

  const _MapMarker({
    required this.site,
    required this.lang,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pos = TurkeyGeometry.project(site.lat, site.lon) +
        (kMarkerNudges[site.id] ?? Offset.zero);
    final color = kEraMarkerColors[site.era]!;
    final size = selected ? 38.0 : 30.0;
    return Positioned(
      left: pos.dx - size / 2,
      top: pos.dy - size / 2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('map.marker.${site.id}'),
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: selected ? 3 : 2),
              boxShadow: const [
                BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Icon(
              site.featured ? Icons.star : Icons.place,
              size: selected ? 19 : 15,
              color: site.featured ? MirasColors.goldLight : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
