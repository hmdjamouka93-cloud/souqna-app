import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/showroom_service.dart';
import '../services/auth_service.dart';

class CreateShowroomScreen extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const CreateShowroomScreen({super.key, this.existing});

  @override
  State<CreateShowroomScreen> createState() => _CreateShowroomScreenState();
}

class _CreateShowroomScreenState extends State<CreateShowroomScreen> {
  final _nameCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _picker = ImagePicker();

  File? _newLogo;
  String _existingLogoUrl = '';
  bool _loading = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final x = widget.existing!;
      _nameCtrl.text = (x['name'] ?? '').toString();
      _locCtrl.text = (x['location'] ?? '').toString();
      _phoneCtrl.text = (x['phone'] ?? '').toString();
      _existingLogoUrl = (x['logo'] ?? '').toString();
    } else {
      _loadUserPhone();
    }
  }

  Future<void> _loadUserPhone() async {
    final data = await AuthService.getUserData();
    if (!mounted) return;
    setState(() => _phoneCtrl.text = (data?['phone'] ?? '').toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;
    setState(() => _newLogo = File(picked.path));
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final loc = _locCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'اكتب اسم المعرض');
      return;
    }
    if (loc.isEmpty) {
      setState(() => _error = 'اكتب العنوان');
      return;
    }
    if (phone.length < 9) {
      setState(() => _error = 'رقم الهاتف قصير');
      return;
    }
    if (!_isEdit && _newLogo == null) {
      setState(() => _error = 'أضف شعار المعرض');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isEdit) {
        final id = (widget.existing!['id'] ?? '').toString();
        final ok = await ShowroomService.updateShowroom(
          id: id,
          name: name,
          location: loc,
          phone: phone,
          newLogo: _newLogo,
        );
        if (!ok) throw Exception();
      } else {
        final id = await ShowroomService.createShowroom(
          name: name,
          location: loc,
          phone: phone,
          logo: _newLogo!,
        );
        if (id == null) throw Exception();
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
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
            icon: const Icon(Icons.close, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isEdit ? 'تعديل المعرض' : 'إنشاء معرض',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الشعار
              Center(
                child: GestureDetector(
                  onTap: _pickLogo,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _newLogo != null
                        ? Image.file(_newLogo!, fit: BoxFit.cover)
                        : (_existingLogoUrl.isNotEmpty
                            ? Image.network(_existingLogoUrl,
                                fit: BoxFit.cover)
                            : const Icon(Icons.add_a_photo_outlined,
                                color: AppColors.accent, size: 40)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'شعار المعرض',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),

              _label('اسم المعرض'),
              _field(_nameCtrl, 'مثال: معرض النخبة للسيارات'),
              const SizedBox(height: 16),

              _label('العنوان'),
              _field(_locCtrl, 'مثال: وهران، حي المدينة'),
              const SizedBox(height: 16),

              _label('رقم الهاتف'),
              _field(_phoneCtrl, '0555 12 34 56',
                  keyboard: TextInputType.phone, ltr: true),

              if (_error != null) ...[
                const SizedBox(height: 16),
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
              ],

              const SizedBox(height: 26),
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
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          _isEdit ? 'حفظ التعديل' : 'إنشاء المعرض',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      );

  Widget _field(
    TextEditingController c,
    String hint, {
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
        keyboardType: keyboard,
        textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        ),
      ),
    );
  }
}
