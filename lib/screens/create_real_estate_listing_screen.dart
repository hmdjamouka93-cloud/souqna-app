import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';
import '../services/location_service.dart';

class CreateRealEstateListingScreen extends StatefulWidget {
  final String categoryName; // سكن للايجار، سكن للبيع، اراضي...
  const CreateRealEstateListingScreen({super.key, required this.categoryName});

  @override
  State<CreateRealEstateListingScreen> createState() => _CreateRealEstateListingScreenState();
}

class _CreateRealEstateListingScreenState extends State<CreateRealEstateListingScreen> {
  int _currentStep = 0;

  // المتغيرات (الخطوة 1)
  String? _operation; // بيع أو إيجار
  String? _propertyType;
  String? _rooms;
  String? _floor;
  String? _furnished;
  final _areaCtrl = TextEditingController();
  
  String? _wilayaCode;
  String? _wilayaName;
  String? _dairaName;

  // المتغيرات (الخطوة 2)
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<File> _images = [];
  final _picker = ImagePicker();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // نعرفو العملية من اسم القسم
    if (widget.categoryName.contains('للايجار')) {
      _operation = 'إيجار';
    } else if (widget.categoryName.contains('للبيع')) {
      _operation = 'بيع';
    }
  }

  @override
  void dispose() {
    _areaCtrl.dispose();
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الحد الأقصى 5 صور')));
      return;
    }
    final pickedList = await _picker.pickMultiImage(imageQuality: 70, maxWidth: 1280);
    if (pickedList.isEmpty) return;
    setState(() {
      for (var picked in pickedList) {
        if (_images.length < 5) _images.add(File(picked.path));
      }
    });
  }

  void _nextStep() {
    if (_operation == null || _propertyType == null || _areaCtrl.text.isEmpty || _wilayaName == null || _dairaName == null) {
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

    if (title.isEmpty || price <= 0 || _images.isEmpty) {
      setState(() => _error = 'أدخل العنوان، السعر، وصورة واحدة على الأقل');
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

      final details = {
        'operation': _operation,
        'propertyType': _propertyType,
        'area': _areaCtrl.text.trim(),
        'rooms': _rooms ?? '',
        'floor': _floor ?? '',
        'furnished': _furnished ?? '',
        'wilaya': _wilayaName,
        'daira': _dairaName,
      };

      await FirebaseFirestore.instance.collection('listings').add({
        'title': title,
        'description': desc,
        'price': price,
        'location': '$_wilayaName - $_dairaName',
        'images': newUrls,
        'userId': user.uid,
        'phone': phone,
        'categoryName': widget.categoryName,
        'subCategoryId': '',
        'details': details,
        'createdAt': FieldValue.serverTimestamp(),
        'views': 0,
        'commentsCount': 0,
        'likes': 0,
        'storeName': '',
        'isPro': false,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر الإعلان بنجاح')));
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
            icon: const Icon(Icons.close, color: Colors.white, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.categoryName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: _currentStep == 0 ? 0.5 : 1.0,
              backgroundColor: AppColors.card,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 6,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _currentStep == 0 ? 'الخطوة 1: تفاصيل العقار' : 'الخطوة 2: الصور والنشر',
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
        _label('نوع العملية *'),
        _dropdown('بيع / إيجار', ['بيع', 'إيجار'], _operation, (v) => setState(() => _operation = v)),
        const SizedBox(height: 16),

        _label('نوع العقار *'),
        _dropdown('اختر النوع', ['شقة', 'فيلا', 'منزل تقليدي', 'أرض', 'محل تجاري', 'مكتب', 'أخرى'], _propertyType, (v) => setState(() => _propertyType = v)),
        const SizedBox(height: 16),

        _label('المساحة (م²) *'),
        _textField(_areaCtrl, 'مثال: 120', keyboard: TextInputType.number),
        const SizedBox(height: 16),

        if (_propertyType == 'شقة' || _propertyType == 'فيلا') ...[
          _label('عدد الغرف'),
          _dropdown('اختر', ['1', '2', '3', '4', '5+'], _rooms, (v) => setState(() => _rooms = v)),
          const SizedBox(height: 16),
          _label('الطابق'),
          _dropdown('اختر', ['طابق أرضي', '1', '2', '3', '4', '5+'], _floor, (v) => setState(() => _floor = v)),
          const SizedBox(height: 16),
        ],

        if (_operation == 'إيجار') ...[
          _label('مفروش؟'),
          _dropdown('نعم / لا', ['نعم', 'لا'], _furnished, (v) => setState(() => _furnished = v)),
          const SizedBox(height: 16),
        ],

        _label('الولاية *'),
        Container(
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: LocationService.getWilayas(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator(color: AppColors.accent);
              final wilayas = snapshot.data!;
              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _wilayaCode,
                  hint:  Text('اختر الولاية', style: TextStyle(color: AppColors.textSecondary)),
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: Colors.white),
                  icon:  Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  items: wilayas.map((w) => DropdownMenuItem<String>(
                    value: w['code'].toString(),
                    child: Text('${w['name']} - ${w['code']}'),
                  )).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    final w = wilayas.firstWhere((e) => e['code'].toString() == v);
                    setState(() {
                      _wilayaCode = v;
                      _wilayaName = w['name'];
                      _dairaName = null;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        _label('الدائرة *'),
        Container(
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FutureBuilder<List<String>>(
            future: _wilayaCode == null ? Future.value([]) : LocationService.getDairas(_wilayaCode!),
            builder: (context, snapshot) {
              final dairas = snapshot.data ?? [];
              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _dairaName,
                  hint:  Text('اختر الدائرة', style: TextStyle(color: AppColors.textSecondary)),
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: Colors.white),
                  icon:  Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  items: dairas.map((d) => DropdownMenuItem<String>(value: d, child: Text(d))).toList(),
                  onChanged: _wilayaCode == null ? null : (v) => setState(() => _dairaName = v),
                ),
              );
            },
          ),
        ),
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
            child: const Text('التالي', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
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
        _textField(_titleCtrl, 'مثال: شقة للبيع 120م²'),
        const SizedBox(height: 16),

        _label('السعر (د.ج) *'),
        _textField(_priceCtrl, '0', keyboard: TextInputType.number, ltr: true),
        const SizedBox(height: 16),

        _label('الوصف'),
        _textField(_descCtrl, 'وصف تفصيلي للعقار...', maxLines: 4),
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
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('نشر الإعلان', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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
          style: const TextStyle(color: Colors.white),
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
        style: const TextStyle(color: Colors.white),
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
