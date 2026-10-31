import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';

class CreateCarListingScreen extends StatefulWidget {
  final String categoryName; // 'سيارات'
  final String brandName; // 'تويوتا'
  final String subCategoryId; // ID تاع الماركة
  final String? showroomId; // ID تاع المعرض (اختياري)

  const CreateCarListingScreen({
    super.key,
    required this.categoryName,
    required this.brandName,
    required this.subCategoryId,
    this.showroomId,
  });

  @override
  State<CreateCarListingScreen> createState() => _CreateCarListingScreenState();
}

class _CreateCarListingScreenState extends State<CreateCarListingScreen> {
  int _currentStep = 0; // 0 = التفاصيل, 1 = الصور والنشر

  // المتغيرات (الخطوة 1)
  String? _selectedCategory; // الفئة
  String? _selectedPayload; // الحمولة للشاحنات
  String? _selectedSeats; // المقاعد للحافلات
  String? _selectedEngineCC; // المحرك للدراجات

  String? _selectedGear;
  String? _selectedColor;
  String? _selectedFuel;
  String? _selectedCondition;
  String? _selectedWarranty;

  final _yearCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();

  List<String> get _categories {
    if (widget.categoryName == 'شاحنات') return ['قلابة', 'صندوق', 'رافعة', 'مقطورة', 'شاحنة صغيرة', 'أخرى'];
    if (widget.categoryName == 'حافلات') return ['حافلة صغيرة', 'حافلة كبيرة', 'حافلة مدرسية', 'حافلة نقل حضري', 'أخرى'];
    if (widget.categoryName == 'دراجات') return ['رياضية', 'كلاسيكية', 'طرقية', 'سكوتر', 'ربع (Quad)', 'أخرى'];
    if (widget.categoryName == 'دراجات رباعية الدفع') return ['رباعية الدفع', 'صحراوية', 'أخرى'];
    if (widget.categoryName == 'دراجات هوائية وسكوتر') return ['هوائية', 'كهربائية', 'سكوتر', 'أخرى'];
    if (widget.categoryName == 'بحري') return ['طراد', 'يخت', 'جيت سكي', 'قارب صيد', 'أخرى'];
    return ['سيدان', 'SUV', 'هاتشباك', 'بيك أب', 'كوبيه', 'أخرى']; // للسيارات
  }
  List<String> get _gears {
    if (widget.categoryName == 'دراجات') return ['عادي', 'أوتوماتيك'];
    return ['عادي', 'أوتوماتيك', 'DCT', 'تبترونيك', 'CVT'];
  }
  final List<String> _colors = ['أبيض', 'أسود', 'فضي', 'رمادي', 'كحلي', 'أزرق', 'أحمر', 'بني', 'بيج', 'ذهبي', 'أخضر', 'برتقالي', 'أصفر', 'بنفسجي', 'لون آخر'];
  List<String> get _fuels {
    if (widget.categoryName == 'شاحنات' || widget.categoryName == 'حافلات') return ['مازوت', 'بنزين', 'غاز'];
    if (widget.categoryName == 'دراجات') return ['بنزين', 'كهرباء'];
    return ['بنزين', 'مازوت', 'كهرباء', 'غاز'];
  }
  final List<String> _conditions = ['جديد', 'مستعمل ممتاز', 'مستعمل جيد', 'لا يعمل'];
  final List<String> _warranties = ['نعم', 'لا'];

  // المتغيرات (الخطوة 2)
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final List<File> _images = [];
  final _picker = ImagePicker();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _yearCtrl.dispose();
    _mileageCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الحد الأقصى 5 صور')),
      );
      return;
    }
    final pickedList = await _picker.pickMultiImage(
        imageQuality: 70, maxWidth: 1280);
    if (pickedList.isEmpty) return;
    setState(() {
      for (var picked in pickedList) {
        if (_images.length < 5) {
          _images.add(File(picked.path));
        }
      }
    });
  }

  void _nextStep() {
    if (_selectedCategory == null ||
        _selectedGear == null ||
        _selectedColor == null ||
        _selectedFuel == null ||
        _selectedCondition == null ||
        _selectedWarranty == null ||
        _yearCtrl.text.isEmpty ||
        _mileageCtrl.text.isEmpty ||
        (widget.categoryName == 'شاحنات' && _selectedPayload == null) ||
        (widget.categoryName == 'حافلات' && _selectedSeats == null) ||
        (widget.categoryName == 'دراجات' && _selectedEngineCC == null)) {
      setState(() => _error = 'يرجى تعبئة جميع الخانات الإجبارية');
      return;
    }
    setState(() {
      _error = null;
      _currentStep = 1;
    });
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final price = int.tryParse(_priceCtrl.text.trim()) ?? 0;
    final loc = _locCtrl.text.trim();

    if (title.isEmpty || price <= 0 || loc.isEmpty || _images.isEmpty) {
      setState(() => _error = 'أدخل العنوان، السعر، الموقع، وصورة واحدة على الأقل');
      return;
    }

    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final newUrls = await CloudinaryService.uploadImages(_images);
      final userData = await AuthService.getUserData();
      final phone = (userData?['phone'] ?? '').toString();
      
      // نجمعو التفاصيل في Map باش نخزنوهم
      final details = {
        'brand': widget.brandName,
        'category': _selectedCategory,
        'gear': _selectedGear,
        'color': _selectedColor,
        'fuel': _selectedFuel,
        'condition': _selectedCondition,
        'warranty': _selectedWarranty,
        'year': _yearCtrl.text.trim(),
        'mileage': _mileageCtrl.text.trim(),
        if (_selectedPayload != null) 'payload': _selectedPayload,
        if (_selectedSeats != null) 'seats': _selectedSeats,
        if (_selectedEngineCC != null) 'engineCC': _selectedEngineCC,
      };

      await FirebaseFirestore.instance.collection('listings').add({
        'title': title,
        'description': desc,
        'price': price,
        'location': loc,
        'images': newUrls,
        'userId': user.uid,
        'phone': phone,
        'subCategoryId': widget.subCategoryId, // رقم الماركة
        'categoryName': widget.categoryName, // 'سيارات'
        if (widget.showroomId != null && widget.showroomId!.isNotEmpty) 'showroomId': widget.showroomId,
        'brandName': widget.brandName, // 'تويوتا'
        'details': details, // نخزنو التفاصيل هنا
        'createdAt': FieldValue.serverTimestamp(),
        'views': 0,
        'commentsCount': 0,
        'likes': 0,
        'storeName': '',
        'isPro': false,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نشر الإعلان بنجاح')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'حدث خطأ أثناء النشر، حاول مرة أخرى';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon:  Icon(Icons.close, color: AppColors.textPrimary, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.brandName,
            style:  TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            // شريط التقدم
            LinearProgressIndicator(
              value: _currentStep == 0 ? 0.5 : 1.0,
              backgroundColor: AppColors.card,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 6,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _currentStep == 0 ? 'الخطوة 1: تفاصيل السيارة' : 'الخطوة 2: الصور والنشر',
                style:  TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('الفئة *'),
        _dropdown('اختر الفئة', _categories, _selectedCategory, (v) => setState(() => _selectedCategory = v)),
        const SizedBox(height: 16),

        _label('نوع القير *'),
        _dropdown('اختر نوع القير', _gears, _selectedGear, (v) => setState(() => _selectedGear = v)),
        const SizedBox(height: 16),

        _label('اللون *'),
        _dropdown('اختر اللون', _colors, _selectedColor, (v) => setState(() => _selectedColor = v)),
        const SizedBox(height: 16),

        if (widget.categoryName == 'شاحنات') ...[
          _label('الحمولة'),
          _dropdown('اختر الحمولة', ['1-5 طن', '5-20 طن', 'فوق 20 طن'], _selectedPayload, (v) => setState(() => _selectedPayload = v)),
          const SizedBox(height: 16),
        ],

        if (widget.categoryName == 'حافلات') ...[
          _label('عدد المقاعد'),
          _dropdown('اختر عدد المقاعد', ['14', '18', '24', '30', '45', '50', 'فوق 50'], _selectedSeats, (v) => setState(() => _selectedSeats = v)),
          const SizedBox(height: 16),
        ],

        if (widget.categoryName == 'دراجات') ...[
          _label('سعة المحرك'),
          _dropdown('اختر سعة المحرك', ['50cc', '100cc', '125cc', '150cc', '250cc', '400cc', '600cc', '1000cc وفوق'], _selectedEngineCC, (v) => setState(() => _selectedEngineCC = v)),
          const SizedBox(height: 16),
        ],

        _label('نوع الوقود *'),
        _dropdown('اختر نوع الوقود', _fuels, _selectedFuel, (v) => setState(() => _selectedFuel = v)),
        const SizedBox(height: 16),

        _label('الحالة *'),
        _dropdown('اختر الحالة', _conditions, _selectedCondition, (v) => setState(() => _selectedCondition = v)),
        const SizedBox(height: 16),

        _label('تحت الضمان؟ *'),
        _dropdown('نعم / لا', _warranties, _selectedWarranty, (v) => setState(() => _selectedWarranty = v)),
        const SizedBox(height: 16),

        _label('سنة الصنع *'),
        _textField(_yearCtrl, 'مثال: 2018', keyboard: TextInputType.number),
        const SizedBox(height: 16),

        _label('العداد (كم) *'),
        _textField(_mileageCtrl, 'مثال: 50000', keyboard: TextInputType.number),
        const SizedBox(height: 24),

        if (_error != null) ...[
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 12),
        ],

        SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: _nextStep,
            child:  Text('التالي', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('الصور (${_images.length}/5) *'),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (_images.length < 5)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: AppColors.accent, size: 28),
                        SizedBox(height: 6),
                        Text('إضافة صورة', style: TextStyle(color: AppColors.accent, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ...List.generate(_images.length, (i) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(_images[i], width: 100, height: 100, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          child:  Icon(Icons.close, color: AppColors.textPrimary, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 18),

        _label('عنوان الإعلان *'),
        _textField(_titleCtrl, 'مثال: تويوتا كورولا 2018'),
        const SizedBox(height: 16),

        _label('السعر (د.ج) *'),
        _textField(_priceCtrl, '0', keyboard: TextInputType.number, ltr: true),
        const SizedBox(height: 16),

        _label('الموقع *'),
        _textField(_locCtrl, 'مثال: الجزائر العاصمة'),
        const SizedBox(height: 16),

        _label('الوصف'),
        _textField(_descCtrl, 'وصف تفصيلي...', maxLines: 4),
        const SizedBox(height: 24),

        if (_error != null) ...[
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 12),
        ],

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('رجوع', style: TextStyle(color: AppColors.accent)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _loading ? null : _submit,
                child: _loading
                    ?  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.textPrimary, strokeWidth: 2.5))
                    :  Text('نشر الإعلان', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: Text(t, style:  TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      );

  Widget _dropdown(String hint, List<String> items, String? val, Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: val,
          hint: Text(hint, style:  TextStyle(color: AppColors.textSecondary)),
          dropdownColor: AppColors.card,
          style:  TextStyle(color: AppColors.textPrimary),
          icon:  Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _textField(TextEditingController c, String hint, {int maxLines = 1, TextInputType? keyboard, bool ltr = false}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
        style:  TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:  TextStyle(color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        ),
      ),
    );
  }
}
