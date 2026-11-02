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
                'no_saved_ads': {'ar': 'لا توجد إعلانات محفوظة', 'en': 'No saved ads', 'fr': 'Aucune annonce enregistrée'},
    'no_ads_yet': {'ar': 'لا توجد إعلانات بعد', 'en': 'No ads yet', 'fr': 'Aucune annonce pour le moment'},
    'no_notifications': {'ar': 'لا توجد إشعارات', 'en': 'No notifications', 'fr': 'Aucune notification'},
        'sections': {'ar': 'الأقسام', 'en': 'Sections', 'fr': 'Sections'},
    'search_in_sections': {'ar': 'بحث في الأقسام', 'en': 'Search in sections', 'fr': 'Rechercher dans les sections'},
    'my_account': {'ar': 'حسابي', 'en': 'My Account', 'fr': 'Mon Compte'},
    'login': {'ar': 'تسجيل الدخول', 'en': 'Login', 'fr': 'Connexion'},
    'no_matching_sections': {'ar': 'لا توجد أقسام مطابقة', 'en': 'No matching sections', 'fr': 'Aucune section correspondante'},
        'err_loading_data': {'ar': 'خطأ في تحميل البيانات', 'en': 'Error loading data', 'fr': 'Erreur de chargement des données'},
    'store_name': {'ar': 'اسم المعرض / المتجر', 'en': 'Showroom / Store name', 'fr': 'Nom du showroom / magasin'},
    'store_name_hint': {'ar': 'مثال: معرض النخبة سيارات', 'en': 'Ex: Elite Cars Showroom', 'fr': 'Ex: Showroom Elite Cars'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel', 'fr': 'Annuler'},
    'save': {'ar': 'حفظ', 'en': 'Save', 'fr': 'Enregistrer'},
    'store_name_updated': {'ar': 'تم تحديث اسم المتجر', 'en': 'Store name updated', 'fr': 'Nom du magasin mis à jour'},
    'edit_phone': {'ar': 'تعديل رقم الهاتف', 'en': 'Edit phone number', 'fr': 'Modifier le numéro de téléphone'},
    'phone_short': {'ar': 'رقم الهاتف قصير', 'en': 'Phone number is too short', 'fr': 'Le numéro est trop court'},
    'phone_updated': {'ar': 'تم تحديث الرقم', 'en': 'Number updated', 'fr': 'Numéro mis à jour'},
    'logout': {'ar': 'تسجيل الخروج', 'en': 'Logout', 'fr': 'Déconnexion'},
    'logout_confirm': {'ar': 'هل أنت متأكد من تسجيل الخروج؟', 'en': 'Are you sure you want to logout?', 'fr': 'Êtes-vous sûr de vouloir vous déconnecter ?'},
    'user_default': {'ar': 'مستخدم', 'en': 'User', 'fr': 'Utilisateur'},
    'phone': {'ar': 'الهاتف', 'en': 'Phone', 'fr': 'Téléphone'},
    'phone_number': {'ar': 'رقم الهاتف', 'en': 'Phone number', 'fr': 'Numéro de téléphone'},
    'not_set_yet': {'ar': 'لم يحدد بعد', 'en': 'Not set yet', 'fr': 'Pas encore défini'},
    'views_count': {'ar': 'عدد المشاهدات', 'en': 'Views count', 'fr': 'Nombre de vues'},
    'publish_my_ad': {'ar': 'نشر عرضي', 'en': 'Publish my ad', 'fr': 'Publier mon annonce'},
    'manage_my_ad': {'ar': 'إدارة عرضي', 'en': 'Manage my ad', 'fr': 'Gérer mon annonce'},
    'my_orders': {'ar': 'طلباتي', 'en': 'My orders', 'fr': 'Mes commandes'},
    'admin_panel': {'ar': 'لوحة التحكم (Admin)', 'en': 'Admin Panel', 'fr': 'Panneau d\'administration'},
    'add_ad': {'ar': 'إضافة إعلان', 'en': 'Add Ad', 'fr': 'Ajouter une annonce'},
    'blocked_users': {'ar': 'المحظورين', 'en': 'Blocked Users', 'fr': 'Utilisateurs bloqués'},
    'language': {'ar': 'اللغة', 'en': 'Language', 'fr': 'Langue'},
    'theme_mode': {'ar': 'الوضع', 'en': 'Theme', 'fr': 'Thème'},
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
    'ايجار السيارات': {'ar': 'ايجار السيارات', 'en': 'Car Rental', 'fr': 'Location de voitures'},
    'دراجات رباعية الدفع': {'ar': 'دراجات رباعية الدفع', 'en': 'ATVs (Quads)', 'fr': 'Quads'},
    'معدات ثقيلة': {'ar': 'معدات ثقيلة', 'en': 'Heavy Equipment', 'fr': 'Engins lourds'},
    'بحري': {'ar': 'بحري', 'en': 'Marine', 'fr': 'Marine'},
    'قطع غيار': {'ar': 'قطع غيار', 'en': 'Spare Parts', 'fr': 'Pièces de rechange'},
    'سكن للايجار': {'ar': 'سكن للايجار', 'en': 'Housing for Rent', 'fr': 'Logement à louer'},
    'سكن للبيع': {'ar': 'سكن للبيع', 'en': 'Housing for Sale', 'fr': 'Logement à vendre'},
    'محلات للايجار': {'ar': 'محلات للايجار', 'en': 'Shops for Rent', 'fr': 'Locaux à louer'},
    'محلات للبيع': {'ar': 'محلات للبيع', 'en': 'Shops for Sale', 'fr': 'Locaux à vendre'},
    'اراضي': {'ar': 'اراضي', 'en': 'Lands', 'fr': 'Terrains'},
    'اثاث': {'ar': 'اثاث', 'en': 'Furniture', 'fr': 'Meubles'},
    'هواتف': {'ar': 'هواتف', 'en': 'Phones', 'fr': 'Téléphones'},
    'حواسيب': {'ar': 'حواسيب', 'en': 'Computers', 'fr': 'Ordinateurs'},
    'اجهزة منزلية': {'ar': 'اجهزة منزلية', 'en': 'Home Appliances', 'fr': 'Électroménager'},
    'العاب فيديو': {'ar': 'العاب فيديو', 'en': 'Video Games', 'fr': 'Jeux vidéo'},
    'كاميرات': {'ar': 'كاميرات', 'en': 'Cameras', 'fr': 'Appareils photo'},
    'اجهزة ذكية': {'ar': 'اجهزة ذكية', 'en': 'Smart Devices', 'fr': 'Appareils intelligents'},
    'ملابس نسائية': {'ar': 'ملابس نسائية', 'en': 'Women\'s Clothing', 'fr': 'Vêtements Femme'},
    'ملابس رجالية': {'ar': 'ملابس رجالية', 'en': 'Men\'s Clothing', 'fr': 'Vêtements Homme'},
    'ملابس اطفال': {'ar': 'ملابس اطفال', 'en': 'Kids\' Clothing', 'fr': 'Vêtements Enfant'},
    'اكسسوارات': {'ar': 'اكسسوارات', 'en': 'Accessories', 'fr': 'Accessoires'},
    'ملابس اخرى': {'ar': 'ملابس اخرى', 'en': 'Other Clothing', 'fr': 'Autres vêtements'},
    'الخياطة والازياء': {'ar': 'الخياطة والازياء', 'en': 'Tailoring & Fashion', 'fr': 'Couture & Mode'},
    'خدمات الصيانة': {'ar': 'خدمات الصيانة', 'en': 'Maintenance Services', 'fr': 'Services de maintenance'},
    'خدمات البناء': {'ar': 'خدمات البناء', 'en': 'Construction Services', 'fr': 'Services de construction'},
    'الخدمات الرقمية': {'ar': 'الخدمات الرقمية', 'en': 'Digital Services', 'fr': 'Services numériques'},
    'النقل والتوصيل': {'ar': 'النقل والتوصيل', 'en': 'Transport & Delivery', 'fr': 'Transport & Livraison'},
    'المناسبات والاعراس': {'ar': 'المناسبات والاعراس', 'en': 'Events & Weddings', 'fr': 'Événements & Mariages'},
    'المأكولات والمشروبات': {'ar': 'المأكولات والمشروبات', 'en': 'Food & Beverages', 'fr': 'Nourriture & Boissons'},
    'التعليم والدروس الخصوصية': {'ar': 'التعليم والدروس الخصوصية', 'en': 'Education & Tutoring', 'fr': 'Éducation & Soutien'},
    'الرياضة واللياقة البدنية': {'ar': 'الرياضة واللياقة البدنية', 'en': 'Sports & Fitness', 'fr': 'Sports & Fitness'},
    'الصحة والجمال': {'ar': 'الصحة والجمال', 'en': 'Health & Beauty', 'fr': 'Santé & Beauté'},
    'السفر والسياحة': {'ar': 'السفر والسياحة', 'en': 'Travel & Tourism', 'fr': 'Voyage & Tourisme'},
    'خدمات السيارات': {'ar': 'خدمات السيارات', 'en': 'Car Services', 'fr': 'Services automobiles'},
    'النظافة ومكافحة الحشرات': {'ar': 'النظافة ومكافحة الحشرات', 'en': 'Cleaning & Pest Control', 'fr': 'Nettoyage & Dératisation'},
    'الخدمات القانونية والايدارية': {'ar': 'الخدمات القانونية والايدارية', 'en': 'Legal & Admin Services', 'fr': 'Services Juridiques & Admin'},
    'الفلاحة والثروة الحيوانية': {'ar': 'الفلاحة والثروة الحيوانية', 'en': 'Agriculture & Livestock', 'fr': 'Agriculture & Élevage'},
    'الدعاية والاعلان والطباعة': {'ar': 'الدعاية والاعلان والطباعة', 'en': 'Marketing & Printing', 'fr': 'Marketing & Impression'},
    'الامن والحراسة': {'ar': 'الامن والحراسة', 'en': 'Security', 'fr': 'Sécurité'},
    'رعاية الاطفال والمسنين': {'ar': 'رعاية الاطفال والمسنين', 'en': 'Child & Elderly Care', 'fr': 'Soins aux enfants & personnes âgées'},
    'الطاقة الشمسية': {'ar': 'الطاقة الشمسية', 'en': 'Solar Energy', 'fr': 'Énergie solaire'},
    'حيوانات اليفة': {'ar': 'حيوانات اليفة', 'en': 'Pets', 'fr': 'Animaux de compagnie'},
    'كلاب وقطط': {'ar': 'كلاب وقطط', 'en': 'Dogs & Cats', 'fr': 'Chiens & Chats'},
    'طيور': {'ar': 'طيور', 'en': 'Birds', 'fr': 'Oiseaux'},
    'مواشي ودواب': {'ar': 'مواشي ودواب', 'en': 'Livestock', 'fr': 'Bétail'},
    'حيوانات اخرى': {'ar': 'حيوانات اخرى', 'en': 'Other Animals', 'fr': 'Autres animaux'},
    'وظائف متاحة': {'ar': 'وظائف متاحة', 'en': 'Available Jobs', 'fr': 'Emplois disponibles'},
    'الباحثين عن عمل': {'ar': 'الباحثين عن عمل', 'en': 'Job Seekers', 'fr': 'Demandeurs d\'emploi'},
    'تبرعات': {'ar': 'تبرعات', 'en': 'Donations', 'fr': 'Dons'},
    'عمل خيري': {'ar': 'عمل خيري', 'en': 'Charity', 'fr': 'Charité'},
    'المفقودات': {'ar': 'المفقودات', 'en': 'Lost & Found', 'fr': 'Objets perdus'},
  };

  static String trCategory(String name) {
    final lang = currentLocale.value.languageCode;
    if (lang == 'ar') return name;
    return _categoryTranslations[name]?[lang] ?? name;
  }
}
