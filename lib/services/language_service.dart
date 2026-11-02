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
    'real_estate': {'ar': 'العقارات', 'en': 'Real Estate', 'fr': 'Immobilier'},
    'electronics': {'ar': 'الإلكترونيات', 'en': 'Electronics', 'fr': 'Électronique'},
    'clothing': {'ar': 'الملابس', 'en': 'Clothing', 'fr': 'Vêtements'},
    'services': {'ar': 'الخدمات', 'en': 'Services', 'fr': 'Services'},
    'animals': {'ar': 'الحيوانات', 'en': 'Animals', 'fr': 'Animaux'},
    'jobs': {'ar': 'الوظائف', 'en': 'Jobs', 'fr': 'Emplois'},
    'charity': {'ar': 'التبرعات والعمل الخيري', 'en': 'Donations & Charity', 'fr': 'Dons et Charité'},
    'login_to_view_ads': {'ar': 'يجب تسجيل الدخول لعرض إعلاناتك', 'en': 'You must log in to view your ads', 'fr': 'Vous devez vous connecter pour voir vos annonces'},
        'login_to_continue': {'ar': 'يجب تسجيل الدخول للمتابعة', 'en': 'You must log in to continue', 'fr': 'Vous devez vous connecter pour continuer'},
    'login_to_add_ad': {'ar': 'يجب تسجيل الدخول لإضافة إعلان', 'en': 'You must log in to add an ad', 'fr': 'Vous devez vous connecter pour ajouter une annonce'},
    'login_to_view_fav': {'ar': 'يجب تسجيل الدخول لعرض المفضلة', 'en': 'You must log in to view favorites', 'fr': 'Vous devez vous connecter pour voir les favoris'},
    'search_hint': {'ar': 'ابحث في السوق...', 'en': 'Search in the market...', 'fr': 'Chercher dans le marché...'},
    'error_loading_categories': {'ar': 'حدث خطأ أثناء تحميل الأقسام', 'en': 'Error loading categories', 'fr': 'Erreur lors du chargement'},
    'no_categories': {'ar': 'لا توجد أقسام', 'en': 'No categories', 'fr': 'Aucune catégorie'},
  };

  static String tr(String key) {
    final lang = currentLocale.value.languageCode;
    return _translations[key]?[lang] ?? key;
  }

  static final Map<String, Map<String, String>> _categoryTranslations = {
    'سيارات': {'ar': 'سيارات', 'en': 'Cars', 'fr': 'Voitures'},
    'شاحنات': {'ar': 'شاحنات', 'en': 'Trucks', 'fr': 'Camions'},
    'حافلات': {'ar': 'حافلات', 'en': 'Buses', 'fr': 'Bus'},
    'دراجات': {'ar': 'دراجات', 'en': 'Motorcycles', 'fr': 'Motos'},
    'معارض السيارات': {'ar': 'معارض السيارات', 'en': 'Car Showrooms', 'fr': 'Showrooms'},
    'دراجات هوائية وسكوتر': {'ar': 'دراجات هوائية وسكوتر', 'en': 'Bicycles & Scooters', 'fr': 'Vélos et Trottinettes'},
    'إيجار سيارات': {'ar': 'إيجار سيارات', 'en': 'Car Rental', 'fr': 'Location de voitures'},
    'شاحنات ومعدات ثقيلة': {'ar': 'شاحنات ومعدات ثقيلة', 'en': 'Trucks & Heavy Eq.', 'fr': 'Camions et Engins'},
  };

  static String trCategory(String name) {
    final lang = currentLocale.value.languageCode;
    if (lang == 'ar') return name;
    return _categoryTranslations[name]?[lang] ?? name;
  }
}
