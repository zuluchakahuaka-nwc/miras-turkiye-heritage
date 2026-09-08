import '../data/sites.dart';
import '../l10n/strings.dart';

List<Site> filterSites(
  List<Site> sites, {
  Era? era,
  required String query,
  required AppLang lang,
}) {
  final q = query.trim().toLowerCase();
  return sites.where((s) {
    if (era != null && s.era != era) return false;
    if (q.isEmpty) return true;
    final parts = [
      s.name.by(lang),
      s.region.by(lang),
      s.desc.by(lang),
      s.name.ru,
      s.name.tr,
      s.name.en,
      s.id,
    ];
    final haystack = parts.map((e) => e.toLowerCase()).join(' | ');
    return haystack.contains(q);
  }).toList();
}
