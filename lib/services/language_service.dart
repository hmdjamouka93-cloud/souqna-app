import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static final ValueNotifier<Locale> currentLocale = ValueNotifier(const Locale('ar'));

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('languageCode') ?? 'ar';
    currentLocale.value = Locale(lang);
  }

  static Future<void> changeLanguage(String langCode) async {
    currentLocale.value = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', langCode);
  }

  // قاموس الترجمة - راح نزيدو فيه الكلمات شاشة بشاشة
  static final Map<String, Map<String, String>> _translations = {
    'app_name': {'ar': 'سوقنا', 'en': 'Souqna', 'fr': 'Souqna'},
    'home': {'ar': 'الرئيسية', 'en': 'Home', 'fr': 'Accueil'},
    'more': {'ar': 'المزيد', 'en': 'More', 'fr': 'Plus'},
    'my_ads': {'ar': 'إعلاناتي', 'en': 'My Ads', 'fr': 'Mes annonces'},
    'favorites': {'ar': 'المفضلة', 'en': 'Favorites', 'fr': 'Favoris'},
    'vehicles': {'ar': 'المركبات', 'en': 'Vehicles', 'fr': 'Véhicules'},
    'search_hint': {'ar': 'ابحث في السوق...', 'en': 'Search in the market...', 'fr': 'Chercher dans le marché...'},
    'error_loading_categories': {'ar': 'حدث خطأ أثناء تحميل الأقسام', 'en': 'Error loading categories', 'fr': 'Erreur lors du chargement'},
    'no_categories': {'ar': 'لا توجد أقسام', 'en': 'No categories', 'fr': 'Aucune catégorie'},
  };

  static String tr(String key) {
    final lang = currentLocale.value.languageCode;
    return _translations[key]?[lang] ?? key;
  }
}
