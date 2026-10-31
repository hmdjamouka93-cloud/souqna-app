import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/service_provider_service.dart';
import '../services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateProviderScreen extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const CreateProviderScreen({super.key, this.existing});

  @override
  State<CreateProviderScreen> createState() => _CreateProviderScreenState();
}

class _CreateProviderScreenState extends State<CreateProviderScreen> {
  final _nameCtrl = TextEditingController();
  String? _selectedTrade;
  List<String> _tradesList = [];
  bool _loadingTrades = true;
  final _bioCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  File? _newCover;
  File? _newAvatar;

  String? _wilayaCode;
  String? _wilayaName;
  String? _dairaName;

  bool _loading = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _loadTrades();
    if (_isEdit) {
      final e = widget.existing!;
      _nameCtrl.text = (e['name'] ?? '').toString();
      _selectedTrade = (e['trade'] ?? '').toString();
      _bioCtrl.text = (e['bio'] ?? '').toString();
      _phoneCtrl.text = (e['phone'] ?? '').toString();
      _wilayaName = (e['wilaya'] ?? '').toString();
      _dairaName = (e['daira'] ?? '').toString();
    }
  }

  Future<void> _loadTrades() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('SubCategories')
          .where('categoryId', isEqualTo: 'خدمات الصيانة')
          .get();
      
      final list = snap.docs.map((d) => (d.data()['name'] ?? '').toString()).toList();
      list.sort();
      
      if (mounted) {
        setState(() {
          _tradesList = list;
          _loadingTrades = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingTrades = false);
    }
  }

  Future<void> _pickImage(bool isCover) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (x == null) return;
    setState(() {
      if (isCover) {
        _newCover = File(x.path);
      } else {
        _newAvatar = File(x.path);
      }
    });
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final trade = _selectedTrade;
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty || trade == null || trade.isEmpty) {
      setState(() => _error = 'اكتب الاسم والمهنة');
      return;
    }
    if (phone.length < 9) {
      setState(() => _error = 'رقم الهاتف قصير');
      return;
    }
    if (_wilayaName == null || _dairaName == null) {
      setState(() => _error = 'اختر الولاية والدائرة');
      return;
    }
    if (!_isEdit && _newAvatar == null) {
      setState(() => _error = 'أضف صورة شخصية أو شعار');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isEdit) {
        final id = (widget.existing!['id'] ?? '').toString();
        final ok = await ServiceProviderService.updateProvider(
          id: id,
          name: name,
          trade: trade,
          bio: _bioCtrl.text.trim(),
          phone: phone,
          wilaya: _wilayaName!,
          daira: _dairaName!,
          newCover: _newCover,
          newAvatar: _newAvatar,
        );
        if (!ok) throw Exception('فشل التحديث');
      } else {
        final id = await ServiceProviderService.createProvider(
          name: name,
          trade: trade,
          bio: _bioCtrl.text.trim(),
          phone: phone,
          wilaya: _wilayaName!,
          daira: _dairaName!,
          cover: _newCover,
          avatar: _newAvatar,
        );
        if (id == null) throw Exception('فشل الإنشاء');
      }

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
                appBar: AppBar(
                    elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon:  Icon(Icons.close, color: AppColors.textPrimary, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _isEdit ? 'تعديل البروفايل' : 'إنشاء بروفايل خدمة',
            style:  TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              GestureDetector(
                onTap: () => _pickImage(true),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    image: _newCover != null
                        ? DecorationImage(image: FileImage(_newCover!), fit: BoxFit.cover)
                        : (_isEdit && (widget.existing!['cover'] ?? '').toString().isNotEmpty)
                            ? DecorationImage(image: NetworkImage(widget.existing!['cover']), fit: BoxFit.cover)
                            : null,
                  ),
                  child: _newCover == null && (!_isEdit || (widget.existing!['cover'] ?? '').toString().isEmpty)
                      ?  Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, color: AppColors.textSecondary, size: 32),
                              SizedBox(height: 8),
                              Text('أضف صورة غلاف', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              
              // Avatar
              Center(
                child: GestureDetector(
                  onTap: () => _pickImage(false),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                      image: _newAvatar != null
                          ? DecorationImage(image: FileImage(_newAvatar!), fit: BoxFit.cover)
                          : (_isEdit && (widget.existing!['avatar'] ?? '').toString().isNotEmpty)
                              ? DecorationImage(image: NetworkImage(widget.existing!['avatar']), fit: BoxFit.cover)
                              : null,
                    ),
                    child: _newAvatar == null && (!_isEdit || (widget.existing!['avatar'] ?? '').toString().isEmpty)
                        ? const Icon(Icons.person, color: AppColors.accent, size: 40)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _label('الاسم الكامل'),
              _field(_nameCtrl, 'مثال: محمد بن علي'),
              const SizedBox(height: 16),

              _label('المهنة'),
              Container(
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _loadingTrades
                    ? const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator(color: AppColors.accent))
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedTrade,
                          hint:  Text('اختر مهنتك', style: TextStyle(color: AppColors.textSecondary)),
                          dropdownColor: AppColors.card,
                          style:  TextStyle(color: AppColors.textPrimary),
                          icon:  Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                          items: _tradesList.map((t) {
                            return DropdownMenuItem<String>(value: t, child: Text(t));
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedTrade = v),
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              _label('نبذة عنك (اختياري)'),
              _field(_bioCtrl, 'اكتب وصف قصير عن خدماتك...', maxLines: 3),
              const SizedBox(height: 16),

              _label('رقم الهاتف'),
              _field(_phoneCtrl, '0xx xx xx xx', keyboard: TextInputType.phone, ltr: true),
              const SizedBox(height: 16),

              _label('الولاية'),
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
                        style:  TextStyle(color: AppColors.textPrimary),
                        icon:  Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                        items: wilayas.map((w) {
                          return DropdownMenuItem<String>(
                            value: w['code'].toString(),
                            child: Text('${w['name']} - ${w['code']}'),
                          );
                        }).toList(),
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

              _label('الدائرة'),
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
                        style:  TextStyle(color: AppColors.textPrimary),
                        icon:  Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                        items: dairas.map((d) {
                          return DropdownMenuItem<String>(value: d, child: Text(d));
                        }).toList(),
                        onChanged: _wilayaCode == null ? null : (v) => setState(() => _dairaName = v),
                      ),
                    );
                  },
                ),
              ),
              
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
                      : Text(_isEdit ? 'حفظ التعديلات' : 'إنشاء البروفايل', style:  TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
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

  Widget _field(TextEditingController c, String hint, {int maxLines = 1, TextInputType? keyboard, bool ltr = false}) {
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
