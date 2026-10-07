import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';

class AddListingScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String? subCategoryId;
  final String? subCategoryName;
  const AddListingScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
  });

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locCtrl = TextEditingController();

  final _picker = ImagePicker();
  final List<File> _images = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
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
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (picked == null) return;
    setState(() => _images.add(File(picked.path)));
  }

  void _removeImage(int i) {
    setState(() => _images.removeAt(i));
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final price = int.tryParse(_priceCtrl.text.trim()) ?? 0;
    final loc = _locCtrl.text.trim();

    if (title.isEmpty) {
      setState(() => _error = 'أدخل عنوان الإعلان');
      return;
    }
    if (price <= 0) {
      setState(() => _error = 'أدخل سعراً صحيحاً');
      return;
    }
    if (loc.isEmpty) {
      setState(() => _error = 'أدخل الموقع');
      return;
    }
    if (_images.isEmpty) {
      setState(() => _error = 'أضف صورة واحدة على الأقل');
      return;
    }

    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. رفع الصور على Cloudinary
      final urls = await CloudinaryService.uploadImages(_images);
      if (urls.isEmpty) {
        setState(() {
          _error = 'فشل رفع الصور، حاول مرة أخرى';
          _loading = false;
        });
        return;
      }

      // 2. جيب رقم الهاتف من Firestore
      final userData = await AuthService.getUserData();
      final phone = (userData?['phone'] ?? '').toString();

      // 3. حفظ الإعلان في Firestore
      await FirebaseFirestore.instance.collection('listings').add({
        'title': title,
        'description': desc,
        'price': price,
        'location': loc,
        'images': urls,
        'userId': user.uid,
        'phone': phone,
        'subCategoryId': widget.subCategoryId ?? '',
        'categoryName': widget.categoryName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نشر الإعلان بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'خطأ في النشر، حاول مرة أخرى';
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
            icon: const Icon(Icons.close, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.categoryName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _label('الصور (${_images.length}/5)'),
              const SizedBox(height: 8),
              _imagesGrid(),
              const SizedBox(height: 18),

              _label('عنوان الإعلان'),
              _textField(_titleCtrl, 'مثال: تويوتا كورولا 2018'),
              const SizedBox(height: 16),

              _label('الوصف'),
              _textField(_descCtrl, 'وصف تفصيلي...', maxLines: 4),
              const SizedBox(height: 16),

              _label('السعر (د.ج)'),
              _textField(_priceCtrl, '0',
                  keyboard: TextInputType.number, ltr: true),
              const SizedBox(height: 16),

              _label('الموقع'),
              _textField(_locCtrl, 'مثال: الجزائر العاصمة'),
              const SizedBox(height: 20),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'نشر الإعلان',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagesGrid() {
    return SizedBox(
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
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        color: AppColors.accent, size: 28),
                    SizedBox(height: 6),
                    Text('إضافة صورة',
                        style: TextStyle(
                            color: AppColors.accent, fontSize: 11)),
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(
                    _images[i],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _removeImage(i),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: Text(
          t,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _textField(
    TextEditingController c,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboard,
    bool ltr = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 14),
        ),
      ),
    );
  }
}
