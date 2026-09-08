import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/sites.dart';
import '../../l10n/strings.dart';
import '../widgets/ornaments.dart';
import 'sources_screen.dart';

class SiteDetailScreen extends StatelessWidget {
  final Site site;
  final AppLang lang;

  const SiteDetailScreen({super.key, required this.site, required this.lang});

  Widget _fact(IconData icon, String label, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 330),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: MirasColors.ivory,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x2214636B)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: MirasColors.teal),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '$label: $value',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: MirasColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MirasColors.ivory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33C9A227)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: MirasColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    letterSpacing: 1.4,
                    color: MirasColors.terracotta,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    height: 1.55,
                    color: MirasColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryName =
        lang == AppLang.tr ? site.name.en : site.name.tr;
    return Scaffold(
      backgroundColor: MirasColors.paper,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: MirasColors.ink,
            foregroundColor: MirasColors.goldLight,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/${site.id}.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const OrnamentPlaceholder(),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xB30E2A2B)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(site.name.by(lang), style: theme.textTheme.displayMedium),
                const SizedBox(height: 4),
                Text(
                  secondaryName.toUpperCase(),
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _fact(Icons.history_edu, t(lang, 'detail.era'), eraLabel(site.era).by(lang)),
                    _fact(Icons.place, t(lang, 'detail.region'), site.region.by(lang)),
                    _fact(Icons.calendar_month, t(lang, 'detail.date'), site.date.by(lang)),
                    if (site.unesco != null)
                      _fact(Icons.star, 'UNESCO', '${site.unesco}'),
                  ],
                ),
                const SizedBox(height: 16),
                const MeanderDivider(height: 14),
                const SizedBox(height: 16),
                Text(site.desc.by(lang), style: theme.textTheme.bodyLarge),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFD8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MirasColors.gold, width: 1.4),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, color: MirasColors.gold, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t(lang, 'pride.label'),
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                                letterSpacing: 1.4,
                                color: MirasColors.terracotta,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              site.pride.by(lang),
                              style: const TextStyle(
                                fontFamily: 'Cormorant',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                height: 1.35,
                                color: MirasColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _infoSection(
                  icon: Icons.auto_stories,
                  title: t(lang, 'detail.legend'),
                  body: site.legend.by(lang),
                ),
                const SizedBox(height: 14),
                _infoSection(
                  icon: Icons.directions_bus,
                  title: t(lang, 'detail.gettingThere'),
                  body: site.gettingThere.by(lang),
                ),
                const SizedBox(height: 14),
                _fact(
                  Icons.my_location,
                  t(lang, 'detail.coords'),
                  formatCoords(site.lat, site.lon),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SourcesScreen(lang: lang)),
                  ),
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: Text(t(lang, 'action.sources')),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
