import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/era_music.dart';
import '../../core/theme.dart';
import '../../data/sites.dart';
import '../../l10n/strings.dart';
import '../widgets/ornaments.dart';
import 'sources_screen.dart';

Future<String?> defaultPickMp3() async {
  final res = await FilePicker.platform.pickFiles(type: FileType.audio);
  return res?.files.single.path;
}

class SiteDetailScreen extends StatefulWidget {
  final Site site;
  final AppLang lang;
  final EraMusicStore? musicStore;
  final Mp3Picker? mp3Picker;

  const SiteDetailScreen({
    super.key,
    required this.site,
    required this.lang,
    this.musicStore,
    this.mp3Picker,
  });

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  late final EraMusicStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.musicStore ?? EraMusicStore.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_store.has(widget.site.era)) {
        EraMusicController.play(_store.fileFor(widget.site.era).path);
      }
    });
  }

  @override
  void dispose() {
    EraMusicController.stop();
    super.dispose();
  }

  Site get site => widget.site;
  AppLang get lang => widget.lang;

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
                const SizedBox(height: 14),
                _MusicSection(
                  site: site,
                  lang: lang,
                  store: _store,
                  picker: widget.mp3Picker ?? defaultPickMp3,
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

class _MusicSection extends StatefulWidget {
  final Site site;
  final AppLang lang;
  final EraMusicStore store;
  final Mp3Picker picker;

  const _MusicSection({
    required this.site,
    required this.lang,
    required this.store,
    required this.picker,
  });

  @override
  State<_MusicSection> createState() => _MusicSectionState();
}

class _MusicSectionState extends State<_MusicSection> {
  bool _playing = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _playing = EraMusicController.current.value ==
        widget.store.fileFor(widget.site.era).path;
  }

  Future<void> _load() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await widget.picker();
      if (picked == null) return;
      final ok = await widget.store.import(widget.site.era, picked);
      if (!mounted) return;
      if (ok) {
        await EraMusicController.play(widget.store.fileFor(widget.site.era).path);
        setState(() => _playing = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t(widget.lang, 'music.loaded'))),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t(widget.lang, 'music.loadFailed'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggle() async {
    if (_playing) {
      await EraMusicController.stop();
      setState(() => _playing = false);
    } else {
      await EraMusicController.play(widget.store.fileFor(widget.site.era).path);
      setState(() => _playing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final has = widget.store.has(widget.site.era);
    return Container(
      key: const Key('detail.music'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBDA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MirasColors.gold, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.music_note, size: 26, color: MirasColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(widget.lang, 'music.title'),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    letterSpacing: 1.4,
                    color: MirasColors.terracotta,
                  ),
                ),
                const SizedBox(height: 6),
                if (has)
                  Row(
                    children: [
                      IconButton(
                        key: const Key('detail.music.toggle'),
                        onPressed: _toggle,
                        icon: Icon(
                          _playing ? Icons.pause_circle : Icons.play_circle,
                          size: 30,
                          color: MirasColors.teal,
                        ),
                      ),
                      Text(
                        _playing
                            ? t(widget.lang, 'music.playing')
                            : t(widget.lang, 'music.paused'),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: MirasColors.ink,
                        ),
                      ),
                    ],
                  )
                else ...[
                  Text(
                    t(widget.lang, 'music.hint'),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12.5,
                      height: 1.5,
                      color: MirasColors.bodyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('detail.music.load'),
                    onPressed: _busy ? null : _load,
                    icon: _busy
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file, size: 18),
                    label: Text(t(widget.lang, 'music.load')),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
