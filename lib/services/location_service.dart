import 'dart:convert';
import 'package:flutter/services.dart';
import 'language_service.dart';

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
    final lang = LanguageService.currentLocale.value.languageCode;
    for (final row in data) {
      final code = (row['wilaya_code'] ?? '').toString();
      String name = (row['wilaya_name'] ?? '').toString();
      if (lang == 'en') name = (row['wilaya_name_en'] ?? name).toString();
      else if (lang == 'fr') name = (row['wilaya_name_fr'] ?? name).toString();

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
    final lang = LanguageService.currentLocale.value.languageCode;
    for (final row in data) {
      final code = (row['wilaya_code'] ?? '').toString();
      String daira = (row['daira_name'] ?? '').toString();
      if (lang == 'en') daira = (row['daira_name_en'] ?? daira).toString();
      else if (lang == 'fr') daira = (row['daira_name_fr'] ?? daira).toString();

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
    final lang = LanguageService.currentLocale.value.languageCode;
    for (final row in data) {
      final code = (row['wilaya_code'] ?? '').toString();
      String daira = (row['daira_name'] ?? '').toString();
      if (lang == 'en') daira = (row['daira_name_en'] ?? daira).toString();
      else if (lang == 'fr') daira = (row['daira_name_fr'] ?? daira).toString();

      final commune = (row['commune_name'] ?? '').toString();
      if (code == wilayaCode && daira == dairaName && commune.isNotEmpty) {
        list.add(commune);
      }
    }
    list.sort();
    return list;
  }



  /// تحميل مسبق (يستدعى مرة وحدة في main)
  static Future<void> preload() async {
    await _load();
  }

  /// ترجم اسم ولاية أو دائرة أو بلدية (sync — لازم preload أول)
  static String translateLocation(String input) {
    final text = input.trim();
    if (text.isEmpty) return input;
    final lang = LanguageService.currentLocale.value.languageCode;
    if (lang == 'ar') return text;
    if (_allData == null) return text;

    final t = text.toLowerCase();
    for (final row in _allData!) {
      final arW = (row['wilaya_name'] ?? '').toString();
      final frW = (row['wilaya_name_fr'] ?? '').toString();
      final enW = (row['wilaya_name_en'] ?? '').toString();
      final asciiW = (row['wilaya_name_ascii'] ?? '').toString();
      if (t == arW.toLowerCase() ||
          t == frW.toLowerCase() ||
          t == enW.toLowerCase() ||
          t == asciiW.toLowerCase()) {
        final result = lang == 'en' ? enW : frW;
        return result.isNotEmpty ? result : text;
      }

      final arD = (row['daira_name'] ?? '').toString();
      final frD = (row['daira_name_fr'] ?? '').toString();
      final enD = (row['daira_name_en'] ?? '').toString();
      final asciiD = (row['daira_name_ascii'] ?? '').toString();
      if (t == arD.toLowerCase() ||
          t == frD.toLowerCase() ||
          t == enD.toLowerCase() ||
          t == asciiD.toLowerCase()) {
        final result = lang == 'en' ? enD : frD;
        return result.isNotEmpty ? result : text;
      }
    }
    return text;
  }

}
