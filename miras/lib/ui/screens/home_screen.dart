import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/locale_store.dart';
import '../../core/theme.dart';
import '../../data/manifest.dart';
import '../../data/sites.dart';
import '../../l10n/strings.dart';
import '../widgets/ornaments.dart';
import 'detail_screen.dart';
import 'gallery_screen.dart';
import 'map_screen.dart';
import 'sources_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueListenable<AppLang>? langListenable;

  const HomeScreen({super.key, this.langListenable});

  @override
  Widget build(BuildContext context) {
    final listenable = langListenable ?? LocaleStore.instance.current;
    return ValueListenableBuilder<AppLang>(
      valueListenable: listenable,
      builder: (context, lang, _) => _HomeView(
        lang: lang,
        onLangChanged: (l) => LocaleStore.instance.set(l),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  final AppLang lang;
  final ValueChanged<AppLang> onLangChanged;

  const _HomeView({required this.lang, required this.onLangChanged});

  void _openDetail(BuildContext context, Site site) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SiteDetailScreen(site: site, lang: lang)),
    );
  }

  void _openGallery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GalleryScreen(lang: lang)),
    );
  }

  void _openSources(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SourcesScreen(lang: lang)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featured = kSites.where((s) => s.featured).toList();
    final heroImage = ImageRegistry.fileFor('gobekli-tepe');

    return Scaffold(
      backgroundColor: MirasColors.paper,
      appBar: AppBar(
        key: const Key('home.appbar'),
        title: const Text(
          'MİRAS',
          style: TextStyle(
            fontFamily: 'Cormorant',
            fontWeight: FontWeight.w700,
            fontSize: 26,
            letterSpacing: 6,
            color: MirasColors.goldLight,
          ),
        ),
        actions: [
          IconButton(
            tooltip: t(lang, 'action.map'),
            key: const Key('home.map.button'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MapScreen(lang: lang)),
            ),
            icon: const Icon(Icons.map_outlined),
          ),
          IconButton(
            tooltip: t(lang, 'action.sources'),
            onPressed: () => _openSources(context),
            icon: const Icon(Icons.photo_library_outlined),
          ),
          PopupMenuButton<AppLang>(
            key: const Key('home.lang.menu'),
            tooltip: t(lang, 'action.language'),
            icon: const Icon(Icons.translate),
            onSelected: onLangChanged,
            itemBuilder: (_) => AppLang.values
                .map(
                  (l) => PopupMenuItem(
                    value: l,
                    child: Row(
                      children: [
                        if (l == lang)
                          const Icon(Icons.check, size: 18, color: MirasColors.gold)
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Text(l.nativeName),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _HeroSection(
            lang: lang,
            heroImage: heroImage,
            onGallery: () => _openGallery(context),
            onSources: () => _openSources(context),
          ),
          const SizedBox(height: 28),
          _StatsSection(lang: lang),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(lang, 'section.pride').toUpperCase(),
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(t(lang, 'section.pride'), style: theme.textTheme.displayMedium),
                const SizedBox(height: 2),
                Text(t(lang, 'section.prideSub'), style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...featured.map(
            (site) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _PrideBanner(
                site: site,
                lang: lang,
                onTap: () => _openDetail(context, site),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(lang, 'section.timeline').toUpperCase(),
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(t(lang, 'section.timeline'), style: theme.textTheme.displayMedium),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            key: const Key('home.timeline'),
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: kTimeline
                  .map((e) => _TimelineCard(entry: e, lang: lang))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          _QuoteSection(lang: lang),
          const SizedBox(height: 12),
          _FooterSection(lang: lang, onSources: () => _openSources(context)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final AppLang lang;
  final String? heroImage;
  final VoidCallback onGallery;
  final VoidCallback onSources;

  const _HeroSection({
    required this.lang,
    required this.heroImage,
    required this.onGallery,
    required this.onSources,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: heroImage == null
              ? const IznikBackground(background: MirasColors.ink, child: SizedBox.expand())
              : Image.asset(
                  heroImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const IznikBackground(background: MirasColors.ink, child: SizedBox.expand()),
                ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  MirasColors.ink.withValues(alpha: 230),
                  MirasColors.ink.withValues(alpha: 170),
                  MirasColors.ink.withValues(alpha: 245),
                ],
              ),
            ),
          ),
        ),
        IznikBackground(
          background: const Color(0x00000000),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: Column(
              children: [
                Text(
                  t(lang, 'app.tagline').toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 2.4,
                    color: MirasColors.goldLight,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  t(lang, 'app.cradle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Cormorant',
                    fontWeight: FontWeight.w700,
                    fontSize: 44,
                    height: 1.1,
                    color: MirasColors.ivory,
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    t(lang, 'hero.sub'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xD9F7F2E5),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: MeanderDivider(color: MirasColors.gold, height: 14),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  key: const Key('home.gallery.cta'),
                  onPressed: onGallery,
                  style: FilledButton.styleFrom(
                    backgroundColor: MirasColors.gold,
                    foregroundColor: MirasColors.ink,
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.4,
                    ),
                  ),
                  child: Text(t(lang, 'action.gallery')),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onSources,
                  style: TextButton.styleFrom(
                    foregroundColor: MirasColors.goldLight,
                    textStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  child: Text(t(lang, 'action.sources')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  final AppLang lang;

  const _StatsSection({required this.lang});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('12 000', t(lang, 'stats.temple')),
      ('21', t(lang, 'stats.unesco')),
      ('2', t(lang, 'stats.wonders')),
      ('1923', t(lang, 'stats.republic')),
    ];
    return Padding(
      key: const Key('home.stats'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: stats
            .map(
              (s) => Container(
                width: 168,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MirasColors.ink,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.$1,
                      style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        color: MirasColors.goldLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.$2,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        height: 1.4,
                        color: MirasColors.ivory,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PrideBanner extends StatelessWidget {
  final Site site;
  final AppLang lang;
  final VoidCallback onTap;

  const _PrideBanner({required this.site, required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('home.pride.${site.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 170,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: MirasColors.teal,
            border: Border.all(color: const Color(0x66C9A227), width: 1),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                ImageRegistry.assetFor(site.id),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const OrnamentPlaceholder(),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      MirasColors.ink.withValues(alpha: 40),
                      MirasColors.ink.withValues(alpha: 225),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site.name.by(lang),
                      style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: MirasColors.goldLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      site.pride.by(lang),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        height: 1.45,
                        color: MirasColors.ivory,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final TimelineEntry entry;
  final AppLang lang;

  const _TimelineCard({required this.entry, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 216,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x2214636B)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: MirasColors.gold),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatYear(entry.year, lang),
                      style: const TextStyle(
                        fontFamily: 'Cormorant',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: MirasColors.teal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        entry.title.by(lang),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12.5,
                          height: 1.4,
                          color: MirasColors.bodyText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteSection extends StatelessWidget {
  final AppLang lang;

  const _QuoteSection({required this.lang});

  @override
  Widget build(BuildContext context) {
    return IznikBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          children: [
            const Text(
              '❝',
              style: TextStyle(fontSize: 44, color: MirasColors.gold, height: 1),
            ),
            const SizedBox(height: 8),
            Text(
              t(lang, 'quote.text'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cormorant',
                fontWeight: FontWeight.w600,
                fontSize: 23,
                height: 1.45,
                color: MirasColors.ivory,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t(lang, 'quote.author').toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                letterSpacing: 1.8,
                color: MirasColors.goldLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  final AppLang lang;
  final VoidCallback onSources;

  const _FooterSection({required this.lang, required this.onSources});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const MeanderDivider(color: Color(0x66C9A227), height: 12),
          const SizedBox(height: 16),
          const Text(
            'MİRAS',
            style: TextStyle(
              fontFamily: 'Cormorant',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              letterSpacing: 6,
              color: MirasColors.teal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t(lang, 'footer.photos'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11.5,
              color: Color(0xFF7A7A6C),
            ),
          ),
          TextButton(
            onPressed: onSources,
            child: Text(t(lang, 'action.sources')),
          ),
        ],
      ),
    );
  }
}
