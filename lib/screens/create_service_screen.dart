import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/service_listing_service.dart';

class CreateServiceScreen extends StatefulWidget {
  final String providerId;
  const CreateServiceScreen({super.key, required this.providerId});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  File? _image;
  bool _loading = false;
  String? _error;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (x == null) return;
    setState(() => _image = File(x.path));
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final priceStr = _priceCtrl.text.trim();
    final price = int.tryParse(priceStr);

    if (title.isEmpty) {
      setState(() => _error = 'اكتب عنوان الخدمة');
      return;
    }
    if (priceStr.isEmpty || price == null || price <= 0) {
      setState(() => _error = 'اكتب سعر صحيح');
      return;
    }
    if (_image == null) {
      setState(() => _error = 'أضف صورة للخدمة');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final id = await ServiceListingService.createService(
        providerId: widget.providerId,
        title: title,
        description: desc,
        price: price,
        image: _image!,
      );
      if (id == null) throw Exception('فشل الإنشاء');
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'حدث خطأ، حاول مرة أخرى';
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
          title:  Text(
            'إضافة خدمة',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    image: _image != null
                        ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _image == null
                      ?  Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, color: AppColors.textSecondary, size: 40),
                              SizedBox(height: 8),
                              Text('أضف صورة الخدمة', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              
              _label('عنوان الخدمة'),
              _field(_titleCtrl, 'مثال: تركيب سخان'),
              const SizedBox(height: 16),

              _label('الوصف (اختياري)'),
              _field(_descCtrl, 'اكتب تفاصيل الخدمة هنا...', maxLines: 3),
              const SizedBox(height: 16),

              _label('السعر (د.ج)'),
              _field(_priceCtrl, 'مثال: 2000', keyboard: TextInputType.number),
              
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ),
              ],
              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ?  SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.textPrimary, strokeWidth: 2.5))
                      :  Text('إضافة الخدمة', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(text, style:  TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _field(TextEditingController c, String hint, {int maxLines = 1, TextInputType? keyboard}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
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
