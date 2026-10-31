import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/product_service.dart';

class CreateProductScreen extends StatefulWidget {
  final String storeId;
  final Map<String, dynamic>? existing;
  const CreateProductScreen({
    super.key,
    required this.storeId,
    this.existing,
  });

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _colorCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _picker = ImagePicker();

  final List<File> _newImages = [];
  final List<String> _existingImages = [];
  final List<String> _colors = [];
  final List<String> _sizes = [];

  bool _loading = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  static const _suggestedColors = [
    'أسود', 'أبيض', 'أحمر', 'أزرق', 'أخضر', 'أصفر',
    'وردي', 'بنفسجي', 'بني', 'رمادي', 'بيج', 'كحلي', 'ذهبي', 'فضي',
  ];

  static const _suggestedSizes = [
    'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL',
    '36', '37', '38', '39', '40', '41', '42', '43', '44', '45',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final x = widget.existing!;
      _nameCtrl.text = (x['name'] ?? '').toString();
      _descCtrl.text = (x['description'] ?? '').toString();
      _priceCtrl.text = (x['price'] ?? 0).toString();
      _qtyCtrl.text = (x['quantity'] ?? 1).toString();
      _existingImages.addAll((x['images'] as List?)?.cast<String>() ?? []);
      _colors.addAll((x['colors'] as List?)?.cast<String>() ?? []);
      _sizes.addAll((x['sizes'] as List?)?.cast<String>() ?? []);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _colorCtrl.dispose();
    _sizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final total = _newImages.length + _existingImages.length;
    if (total >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الحد الأقصى 5 صور')),
      );
      return;
    }
    final picked = await _picker.pickMultiImage(imageQuality: 75, maxWidth: 1024);
    if (picked.isEmpty) return;
    setState(() {
      for (final p in picked) {
        if (_newImages.length + _existingImages.length >= 5) break;
        _newImages.add(File(p.path));
      }
    });
  }

  void _addColor(String c) {
    final v = c.trim();
    if (v.isEmpty || _colors.contains(v)) return;
    setState(() => _colors.add(v));
    _colorCtrl.clear();
  }

  void _addSize(String s) {
    final v = s.trim();
    if (v.isEmpty || _sizes.contains(v)) return;
    setState(() => _sizes.add(v));
    _sizeCtrl.clear();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final price = int.tryParse(_priceCtrl.text.trim()) ?? 0;
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final totalImgs = _newImages.length + _existingImages.length;

    if (name.isEmpty) {
      setState(() => _error = 'اكتب اسم المنتج');
      return;
    }
    if (price <= 0) {
      setState(() => _error = 'أدخل سعراً صحيحاً');
      return;
    }
    if (totalImgs == 0) {
      setState(() => _error = 'أضف صورة واحدة على الأقل');
      return;
    }
    if (_colors.isEmpty) {
      setState(() => _error = 'أضف لون واحد على الأقل');
      return;
    }
    if (_sizes.isEmpty) {
      setState(() => _error = 'أضف مقاس واحد على الأقل');
      return;
    }
    if (qty <= 0) {
      setState(() => _error = 'الكمية يجب أن تكون 1 على الأقل');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isEdit) {
        final id = (widget.existing!['id'] ?? '').toString();
        final ok = await ProductService.updateProduct(
          id: id,
          name: name,
          description: _descCtrl.text.trim(),
          price: price,
          colors: _colors,
          sizes: _sizes,
          quantity: qty,
          newImages: _newImages,
          existingImages: _existingImages,
        );
        if (!ok) throw Exception();
      } else {
        final id = await ProductService.createProduct(
          storeId: widget.storeId,
          name: name,
          description: _descCtrl.text.trim(),
          price: price,
          images: _newImages,
          colors: _colors,
          sizes: _sizes,
          quantity: qty,
        );
        if (id == null) throw Exception();
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'خطأ: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
                appBar: AppBar(
                    elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon:  Icon(Icons.close, color: AppColors.textPrimary, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isEdit ? 'تعديل المنتج' : 'إضافة منتج',
            style:  TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _label('الصور (${_newImages.length + _existingImages.length}/5)'),
              _imagesGrid(),
              const SizedBox(height: 16),
              _label('اسم المنتج'),
              _field(_nameCtrl, 'مثال: فستان أحمر'),
              const SizedBox(height: 16),
              _label('الوصف'),
              _field(_descCtrl, 'وصف تفصيلي...', maxLines: 4),
              const SizedBox(height: 16),
              _label('السعر (د.ج)'),
              _field(_priceCtrl, '0',
                  keyboard: TextInputType.number, ltr: true),
              const SizedBox(height: 16),
              _label('الكمية المتوفرة'),
              _field(_qtyCtrl, '1',
                  keyboard: TextInputType.number, ltr: true),
              const SizedBox(height: 16),
              _label('الألوان المتوفرة'),
              _chipsInput(_colorCtrl, _suggestedColors, _addColor, _colors,
                  (c) => setState(() => _colors.remove(c))),
              const SizedBox(height: 16),
              _label('المقاسات المتوفرة'),
              _chipsInput(_sizeCtrl, _suggestedSizes, _addSize, _sizes,
                  (s) => setState(() => _sizes.remove(s))),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.4)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ?  SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: AppColors.textPrimary, strokeWidth: 2.5))
                      : Text(
                          _isEdit ? 'حفظ التعديل' : 'إضافة المنتج',
                          style:  TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
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
          // الصور القديمة
          ...List.generate(_existingImages.length, (i) {
            return Stack(
              children: [
                Container(
                  width: 100,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(imageUrl: _existingImages[i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                          color: AppColors.card,
                          child:  Icon(Icons.broken_image,
                              color: AppColors.textSecondary.withValues(alpha: 0.24)))),
                ),
                Positioned(
                  top: 4,
                  right: 12,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _existingImages.removeAt(i)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child:  Icon(Icons.close,
                          color: AppColors.textPrimary, size: 14),
                    ),
                  ),
                ),
              ],
            );
          }),
          // الصور الجديدة
          ...List.generate(_newImages.length, (i) {
            return Stack(
              children: [
                Container(
                  width: 100,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(_newImages[i],
                      width: 100, height: 100, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => setState(() => _newImages.removeAt(i)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child:  Icon(Icons.close,
                          color: AppColors.textPrimary, size: 14),
                    ),
                  ),
                ),
              ],
            );
          }),
          if (_newImages.length + _existingImages.length < 5)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      width: 1.5),
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
        ],
      ),
    );
  }

  Widget _chipsInput(
    TextEditingController ctrl,
    List<String> suggestions,
    Function(String) onAdd,
    List<String> selected,
    Function(String) onRemove,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // selected chips
        if (selected.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selected
                .map((c) => Chip(
                      label: Text(c,
                          style:  TextStyle(
                              color: AppColors.textPrimary, fontSize: 12)),
                      backgroundColor: AppColors.accent,
                      deleteIconColor: AppColors.textPrimary,
                      onDeleted: () => onRemove(c),
                    ))
                .toList(),
          ),
        const SizedBox(height: 8),
        // input
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: ctrl,
                  style:  TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration:  InputDecoration(
                    hintText: 'أضف نوع آخر...',
                    hintStyle: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onSubmitted: onAdd,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onAdd(ctrl.text),
              icon: const Icon(Icons.add_circle,
                  color: AppColors.accent, size: 30),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // suggestions
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: suggestions
              .where((s) => !selected.contains(s))
              .map((s) => GestureDetector(
                    onTap: () => onAdd(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4)),
                      ),
                      child: Text(s,
                          style:  TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: Text(t,
            style:  TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      );

  Widget _field(
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
        style:  TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:  TextStyle(
              color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        ),
      ),
    );
  }
}
