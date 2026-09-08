import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../core/logger.dart';

class ManifestEntry {
  final String site;
  final String? file;
  final String? source;
  final String? author;
  final String? license;
  final String? licenseUrl;

  const ManifestEntry({
    required this.site,
    this.file,
    this.source,
    this.author,
    this.license,
    this.licenseUrl,
  });

  factory ManifestEntry.fromJson(Map<String, dynamic> json) => ManifestEntry(
        site: json['site'] as String,
        file: json['file'] as String?,
        source: json['source'] as String?,
        author: json['author'] as String?,
        license: json['license'] as String?,
        licenseUrl: json['licenseUrl'] as String?,
      );
}

class ImageRegistry {
  static const String manifestAsset = 'assets/images/manifest.json';
  static List<ManifestEntry> entries = const [];
  static final Map<String, String> _files = {};

  static Future<void> load() async {
    try {
      final raw = await rootBundle.loadString(manifestAsset);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final list = (data['images'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ManifestEntry.fromJson)
          .toList();
      entries = list;
      _files.clear();
      for (final e in list) {
        if (e.file != null && e.file!.isNotEmpty) {
          _files[e.site] = 'assets/images/${e.file!}';
        }
      }
      Logger.info('manifest loaded: ${list.length} entries, ${_files.length} images');
    } catch (e) {
      Logger.warning('manifest load failed: $e');
    }
  }

  static String? fileFor(String siteId) => _files[siteId];

  static String assetFor(String siteId) => _files[siteId] ?? 'assets/images/$siteId.jpg';

  static void resetForTests() {
    entries = const [];
    _files.clear();
  }
}
