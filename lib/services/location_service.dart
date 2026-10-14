import 'dart:convert';
import 'package:flutter/services.dart';

class LocationService {
  static List<Map<String, dynamic>>? _allData;

  /// يحمّل البيانات مرة وحدة (cache)
  static Future<List<Map<String, dynamic>>> _load() async {
    if (_allData != null) return _allData!;
    final raw = await rootBundle.loadString('assets/data/algeria.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    _allData = list;
    return list;
  }

  /// يجيب كل الولايات (58) بلا تكرار
  static Future<List<Map<String, String>>> getWilayas() async {
    final data = await _load();
    final map = <String, String>{}; // code -> name
    for (final row in data) {
      final code = (row['wilaya_code'] ?? '').toString();
      final name = (row['wilaya_name'] ?? '').toString();
      if (code.isNotEmpty && name.isNotEmpty) {
        map[code] = name;
      }
    }
    final list = map.entries
        .map((e) => {'code': e.key, 'name': e.value})
        .toList();
    list.sort((a, b) => a['code']!.compareTo(b['code']!));
    return list;
  }

  /// يجيب دوائر ولاية معينة
  static Future<List<String>> getDairas(String wilayaCode) async {
    final data = await _load();
    final set = <String>{};
    for (final row in data) {
      final code = (row['wilaya_code'] ?? '').toString();
      final daira = (row['daira_name'] ?? '').toString();
      if (code == wilayaCode && daira.isNotEmpty) {
        set.add(daira);
      }
    }
    final list = set.toList();
    list.sort();
    return list;
  }

  /// يجيب بلديات دائرة معينة
  static Future<List<String>> getCommunes(
      String wilayaCode, String dairaName) async {
    final data = await _load();
    final list = <String>[];
    for (final row in data) {
      final code = (row['wilaya_code'] ?? '').toString();
      final daira = (row['daira_name'] ?? '').toString();
      final commune = (row['commune_name'] ?? '').toString();
      if (code == wilayaCode && daira == dairaName && commune.isNotEmpty) {
        list.add(commune);
      }
    }
    list.sort();
    return list;
  }
}
