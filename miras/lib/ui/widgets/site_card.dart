import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/manifest.dart';
import '../../data/sites.dart';
import '../../l10n/strings.dart';
import 'ornaments.dart';

class _RibbonChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  const _RibbonChip({
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              letterSpacing: 0.6,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class SiteCard extends StatelessWidget {
  final Site site;
  final AppLang lang;
  final ValueChanged<Site> onTap;

  const SiteCard({
    super.key,
    required this.site,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(site),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    ImageRegistry.assetFor(site.id),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        OrnamentPlaceholder(caption: t(lang, 'photo.unavailable')),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _RibbonChip(
                    label: eraLabel(site.era).by(lang),
                    color: MirasColors.ink,
                    textColor: MirasColors.goldLight,
                  ),
                ),
                if (site.unesco != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _RibbonChip(
                      label: '${t(lang, 'badge.unesco')} ${site.unesco}',
                      color: MirasColors.gold,
                      textColor: MirasColors.ink,
                      icon: Icons.star,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      site.name.by(lang),
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (site.featured)
                    const Icon(Icons.auto_awesome, size: 18, color: MirasColors.gold),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '${site.region.by(lang).toUpperCase()} · ${site.date.by(lang)}',
                style: theme.textTheme.labelSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Text(
                site.desc.by(lang),
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
