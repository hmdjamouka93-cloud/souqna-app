import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/store_service.dart';
import '../services/location_service.dart';

class CreateStoreScreen extends StatefulWidget {
  final String categoryName;
  final Map<String, dynamic>? existing;
  const CreateStoreScreen({
    super.key,
    required this.categoryName,
    this.existing,
  });

  @override
  State<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _picker = ImagePicker();

  File? _newCover;
  File? _newLogo;
  String _existingCover = '';
  String _existingLogo = '';

  String? _wilayaName;
  String? _wilayaCode;
  String? _dairaName;
  List<Map<String, String>> _wilayas = [];
  List<String> _dairas = [];

  bool _loading = false;
  bool _loadingLoc = true;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final x = widget.existing!;
      _nameCtrl.text = (x['name'] ?? '').toString();
      _bioCtrl.text = (x['bio'] ?? '').toString();
      _phoneCtrl.text = (x['phone'] ?? '').toString();
      _existingCover = (x['cover'] ?? '').toString();
      _existingLogo = (x['logo'] ?? '').toString();
      _wilayaName = (x['wilaya'] ?? '').toString();
      _dairaName = (x['daira'] ?? '').toString();
    }
    _loadWilayas();
  }

  Future<void> _loadWilayas() async {
    final list = await LocationService.getWilayas();
    if (!mounted) return;
    setState(() {
      _wilayas = list;
      _loadingLoc = false;
    });
    // إذا كانت ولاية محفوظة، نلقاو الـ code ونحمّلو الدوائر
    if (_isEdit && _wilayaName != null) {
      final w = _wilayas.firstWhere(
        (e) => e['name'] == _wilayaName,
        orElse: () => {},
      );
      if (w.isNotEmpty && w['code'] != null) {
        _wilayaCode = w['code'];
        final ds = await LocationService.getDairas(w['code']!);
        if (!mounted) return;
        setState(() => _dairas = ds);
      }
    }
  }

  Future<void> _onWilayaChange(String? code) async {
    if (code == null) return;
    final w = _wilayas.firstWhere((e) => e['code'] == code);
    setState(() {
      _wilayaCode = code;
      _wilayaName = w['name'];
      _dairaName = null;
      _dairas = [];
    });
    final ds = await LocationService.getDairas(code);
    if (!mounted) return;
    setState(() => _dairas = ds);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final p = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 1280);
    if (p == null) return;
    setState(() => _newCover = File(p.path));
  }

  Future<void> _pickLogo() async {
    final p = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 512);
    if (p == null) return;
    setState(() => _newLogo = File(p.path));
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'اكتب اسم المتجر');
      return;
    }
    if (phone.length < 9) {
      setState(() => _error = 'رقم الهاتف قصير');
      return;
    }
    if (_wilayaCode == null || _dairaName == null) {
      setState(() => _error = 'اختر الولاية والدائرة');
      return;
    }
    if (!_isEdit && _newCover == null) {
      setState(() => _error = 'أضف صورة الغلاف');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isEdit) {
        final id = (widget.existing!['id'] ?? '').toString();
        final ok = await StoreService.updateStore(
          id: id,
          name: name,
          bio: _bioCtrl.text.trim(),
          phone: phone,
          wilaya: _wilayaName!,
          daira: _dairaName!,
          newCover: _newCover,
          newLogo: _newLogo,
        );
        if (!ok) throw Exception();
      } else {
      final existing = await StoreService.getMyStore(widget.categoryName);
      if (existing != null) {
        if (!mounted) return;
        setState(() {
          _error = 'عندك متجر في هذا القسم من قبل';
          _loading = false;
        });
        return;
      }
        final id = await StoreService.createStore(
          name: name,
          categoryName: widget.categoryName,
          cover: _newCover!,
          logo: _newLogo,
          bio: _bioCtrl.text.trim(),
          phone: phone,
          wilaya: _wilayaName!,
          daira: _dairaName!,
        );
        if (id == null) throw Exception();
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) { print("SUBMIT_ERR: $e");
      if (!mounted) return;
      setState(() {
        _error = 'خطأ، حاول مرة أخرى';
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
            icon:  Icon(Icons.close, color: AppColors.textPrimary, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isEdit ? 'تعديل المتجر' : 'إنشاء متجر',
            style:  TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: _loadingLoc
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('صورة الغلاف (إجبارية)'),
                    _coverPicker(),
                    const SizedBox(height: 16),
                    _label('شعار المتجر (اختياري)'),
                    _logoPicker(),
                    const SizedBox(height: 16),
                    _label('اسم المتجر'),
                    _field(_nameCtrl, 'مثال: متجر الأناقة'),
                    const SizedBox(height: 16),
                    _label('نبذة (اختياري)'),
                    _field(_bioCtrl, 'مثال: أحسن ملابس في وهران',
                        maxLines: 3),
                    const SizedBox(height: 16),
                    _label('رقم الهاتف'),
                    _field(_phoneCtrl, '0555 12 34 56',
                        keyboard: TextInputType.phone, ltr: true),
                    const SizedBox(height: 16),
                    _label('الولاية (إجبارية)'),
                    _wilayaDropdown(),
                    const SizedBox(height: 16),
                    _label('الدائرة (إجبارية)'),
                    _dairaDropdown(),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.red.withValues(alpha: 0.4)),
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
                                _isEdit ? 'حفظ التعديل' : 'إنشاء المتجر',
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

  Widget _coverPicker() {
    return GestureDetector(
      onTap: _pickCover,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.4), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: _newCover != null
            ? Image.file(_newCover!, fit: BoxFit.cover)
            : (_existingCover.isNotEmpty
                ? CachedNetworkImage(imageUrl: _existingCover, fit: BoxFit.cover)
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.accent, size: 32),
                        SizedBox(height: 6),
                        Text('اضغط لاختيار غلاف',
                            style: TextStyle(
                                color: AppColors.accent, fontSize: 12)),
                      ],
                    ),
                  )),
      ),
    );
  }

  Widget _logoPicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickLogo,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.4), width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: _newLogo != null
              ? Image.file(_newLogo!, fit: BoxFit.cover)
              : (_existingLogo.isNotEmpty
                  ? CachedNetworkImage(imageUrl: _existingLogo, fit: BoxFit.cover)
                  : const Icon(Icons.storefront,
                      color: AppColors.accent, size: 40)),
        ),
      ),
    );
  }

  Widget _wilayaDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _wilayaCode,
          hint:  Text('اختر الولاية',
              style: TextStyle(color: AppColors.textSecondary)),
          dropdownColor: AppColors.card,
          style:  TextStyle(color: AppColors.textPrimary, fontSize: 14),
          icon:  Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary),
          items: _wilayas
              .map((w) => DropdownMenuItem<String>(
                    value: w['code'],
                    child: Text('${w['code']} - ${w['name']}',
                        style:  TextStyle(color: AppColors.textPrimary)),
                  ))
              .toList(),
          onChanged: _onWilayaChange,
        ),
      ),
    );
  }

  Widget _dairaDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _dairaName,
          hint: Text(
              _wilayaCode == null ? 'اختر الولاية أولاً' : 'اختر الدائرة',
              style:  TextStyle(color: AppColors.textSecondary)),
          dropdownColor: AppColors.card,
          style:  TextStyle(color: AppColors.textPrimary, fontSize: 14),
          icon:  Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary),
          items: _dairas
              .map((d) => DropdownMenuItem<String>(
                    value: d,
                    child: Text(d, style:  TextStyle(color: AppColors.textPrimary)),
                  ))
              .toList(),
          onChanged: _wilayaCode == null
              ? null
              : (v) => setState(() => _dairaName = v),
        ),
      ),
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
