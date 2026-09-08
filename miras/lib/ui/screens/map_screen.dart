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
  final String? focusSiteId;

  const MapScreen({super.key, required this.lang, this.focusSiteId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TransformationController _controller = TransformationController();
  final TextEditingController _search = TextEditingController();
  bool _fitted = false;
  bool _showAllNames = false;
  String? _selectedId;
  String _query = '';
  static const double baseW = kMapBaseWidth;
  static const double baseH = kMapBaseHeight;

  @override
  void dispose() {
    _controller.dispose();
    _search.dispose();
    super.dispose();
  }

  bool _matches(Site site) {
    if (_query.trim().isEmpty) return true;
    final q = _query.trim().toLowerCase();
    return '${site.name.ru} ${site.name.tr} ${site.name.en} ${site.id}'
        .toLowerCase()
        .contains(q);
  }

  List<Site> get _visibleSites => kSites.where(_matches).toList();

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      final visible = _visibleSites;
      if (visible.length == 1) {
        _selectedId = visible.first.id;
      } else if (visible.isEmpty) {
        _selectedId = null;
      }
    });
  }

  void _handleMarkerTap(Site site) {
    if (_selectedId == site.id) {
      _openDetail(site);
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

  Site? get _selectedSite {
    if (_selectedId == null) return null;
    return kSites.firstWhere((s) => s.id == _selectedId);
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
            key: const Key('map.names.toggle'),
            tooltip: t(lang, 'map.showNames'),
            onPressed: () => setState(() => _showAllNames = !_showAllNames),
            icon: Icon(
              _showAllNames ? Icons.label : Icons.label_outline,
              color: _showAllNames ? MirasColors.goldLight : null,
            ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
            child: TextField(
              key: const Key('map.search'),
              controller: _search,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: t(lang, 'map.searchHint'),
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _search.clear();
                          _onSearchChanged('');
                        },
                      ),
              ),
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
                  final focus = _selectedSite ??
                      (widget.focusSiteId == null
                          ? null
                          : kSites.firstWhere((x) => x.id == widget.focusSiteId));
                  if (focus != null) {
                    _selectedId = focus.id;
                    final pos = TurkeyGeometry.project(focus.lat, focus.lon) +
                        (kMarkerNudges[focus.id] ?? Offset.zero);
                    const scale = 3.2;
                    final tx = s.width / 2 - pos.dx * scale;
                    final ty = s.height / 2 - pos.dy * scale;
                    _controller.value = Matrix4.translationValues(tx, ty, 0)
                        .multiplied(Matrix4.diagonal3Values(scale, scale, 1));
                  } else {
                    final scale = s.width / baseW;
                    final tx = (s.width - baseW * scale) / 2;
                    final ty = (s.height - baseH * scale) / 2;
                    _controller.value = Matrix4.translationValues(tx, ty, 0)
                        .multiplied(Matrix4.diagonal3Values(scale, scale, 1));
                  }
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
                          if (_selectedSite != null &&
                              (kSiteRoutes[_selectedSite!.id]?.isNotEmpty ??
                                  false))
                            Positioned.fill(
                              child: CustomPaint(
                                key: Key('map.route.${_selectedSite!.id}'),
                                painter:
                                    SiteRoutesPainter(kSiteRoutes[_selectedSite!.id]!),
                              ),
                            ),
                          for (final site in kSites)
                            _MapMarker(
                              site: site,
                              lang: widget.lang,
                              selected: _selectedId == site.id,
                              dimmed: !_matches(site),
                              onTap: () => _handleMarkerTap(site),
                            ),
                          if (_showAllNames)
                            for (final site in _visibleSites)
                              _NameChip(site: site, lang: widget.lang),
                          if (_selectedSite != null)
                            _SelectedLabel(
                              site: _selectedSite!,
                              lang: widget.lang,
                              onTap: () => _openDetail(_selectedSite!),
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

class _NameChip extends StatelessWidget {
  final Site site;
  final AppLang lang;

  const _NameChip({required this.site, required this.lang});

  @override
  Widget build(BuildContext context) {
    final pos = TurkeyGeometry.project(site.lat, site.lon) +
        (kMarkerNudges[site.id] ?? Offset.zero);
    final color = kEraMarkerColors[site.era]!;
    return Positioned(
      left: pos.dx - 60,
      top: pos.dy + 21,
      width: 120,
      child: Center(
        child: IgnorePointer(
          child: Container(
            key: Key('map.name.${site.id}'),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xE6FFFFFF),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: color, width: 1.2),
            ),
            child: Text(
              site.name.by(lang),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: MirasColors.ink,
              ),
            ),
          ),
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
                    site.entryFee == null
                        ? site.name.by(lang)
                        : '${site.name.by(lang)} · ${site.entryFee}',
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
  final bool dimmed;
  final VoidCallback onTap;

  const _MapMarker({
    required this.site,
    required this.lang,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pos = TurkeyGeometry.project(site.lat, site.lon) +
        (kMarkerNudges[site.id] ?? Offset.zero);
    final color = kEraMarkerColors[site.era]!;
    final size = selected ? 42.0 : 34.0;
    return Positioned(
      left: pos.dx - size / 2,
      top: pos.dy - size / 2,
      child: Opacity(
        opacity: dimmed ? 0.15 : 1.0,
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
                size: selected ? 20 : 17,
                color: site.featured ? MirasColors.goldLight : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
