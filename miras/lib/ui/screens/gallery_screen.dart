import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../core/theme.dart';
import '../../data/sites.dart';
import '../../l10n/strings.dart';
import '../../logic/site_filter.dart';
import '../widgets/site_card.dart';
import 'detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  final AppLang lang;

  const GalleryScreen({super.key, required this.lang});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  Era? _era;

  void _openDetail(Site site) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SiteDetailScreen(site: site, lang: widget.lang),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final filtered = filterSites(kSites, era: _era, query: _query, lang: lang);
    final columns = MediaQuery.sizeOf(context).width > 1000
        ? 4
        : MediaQuery.sizeOf(context).width > 700
            ? 3
            : 2;
    return Scaffold(
      backgroundColor: MirasColors.paper,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(lang, 'section.gallery'),
              style: const TextStyle(
                fontFamily: 'Cormorant',
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            Text(
              t(lang, 'section.gallerySub'),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                color: MirasColors.goldLight,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              key: const Key('gallery.search'),
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: t(lang, 'search.hint'),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                _eraChip(null, lang),
                ...Era.values.map((e) => _eraChip(e, lang)),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      t(lang, 'empty.search'),
                      key: const Key('gallery.empty'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : MasonryGridView.count(
                    key: const Key('gallery.grid'),
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final site = filtered[i];
                      return SiteCard(
                        site: site,
                        lang: lang,
                        onTap: _openDetail,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _eraChip(Era? era, AppLang lang) {
    final selected = _era == era;
    final label = era == null ? t(lang, 'era.all') : eraLabel(era).by(lang);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        key: Key('gallery.chip.${era?.name ?? 'all'}'),
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _era = era),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? MirasColors.teal : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? MirasColors.teal : const Color(0x3314636B),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: selected ? Colors.white : MirasColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
