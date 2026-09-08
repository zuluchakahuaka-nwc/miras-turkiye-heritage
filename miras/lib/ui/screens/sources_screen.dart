import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/manifest.dart';
import '../../l10n/strings.dart';

class SourcesScreen extends StatelessWidget {
  final AppLang lang;

  const SourcesScreen({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t(lang, 'sources.title'))),
      body: FutureBuilder<void>(
        future: ImageRegistry.load(),
        builder: (context, _) {
          final entries = ImageRegistry.entries;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MirasColors.ivory,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x33C9A227)),
                ),
                child: Text(t(lang, 'sources.note'), style: theme.textTheme.bodyMedium),
              ),
              const SizedBox(height: 12),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    t(lang, 'sources.empty'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              else
                ...entries.map(
                  (e) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.site,
                            key: Key('sources.entry.${e.site}'),
                            style: theme.textTheme.titleMedium,
                          ),
                          if (e.author != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${e.author}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          if (e.license != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${e.license}${e.file == null ? ' · —' : ''}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          if (e.source != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                e.source!,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11.5,
                                  color: MirasColors.teal,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
