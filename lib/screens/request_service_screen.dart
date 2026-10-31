import 'package:flutter/material.dart';
import '../main.dart';
import '../services/service_order_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../services/auth_gate.dart';

class RequestServiceScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  final Map<String, dynamic> provider;

  const RequestServiceScreen({
    super.key,
    required this.service,
    required this.provider,
  });

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  String? _wilayaCode;
  String? _wilayaName;
  String? _dairaName;

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!AuthService.isLoggedIn) {
      await requireAuth(context, _submit,
          message: 'يجب تسجيل الدخول لطلب الخدمة.');
      return;
    }

    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'اكتب اسمك الكامل');
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

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final id = await ServiceOrderService.createOrder(
        providerId: (widget.provider['id'] ?? '').toString(),
        serviceId: (widget.service['id'] ?? '').toString(),
        serviceTitle: (widget.service['title'] ?? '').toString(),
        clientName: name,
        clientPhone: phone,
        wilaya: _wilayaName!,
        daira: _dairaName!,
      );

      if (!mounted) return;

      if (id == null) {
        setState(() {
          _error = 'حدث خطأ أثناء إرسال الطلب';
          _loading = false;
        });
        return;
      }

      // نجاح
      showDialog(
        context: context,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title:  Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('تم إرسال الطلب', style: TextStyle(color: AppColors.textPrimary)),
              ],
            ),
            content:  Text(
              'سيتواصل معك مقدم الخدمة في أقرب وقت لتأكيد الموعد.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context); // نرجعو لصفحة الخدمة
                },
                child: const Text('حسناً', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon:  Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title:  Text(
            'طلب الخدمة',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الخدمة
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.handyman, color: AppColors.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (widget.service['title'] ?? '').toString(),
                            style:  TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (widget.provider['name'] ?? '').toString(),
                            style:  TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
               Text(
                'معلومات الطلب',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _label('الاسم الكامل'),
              _field(_nameCtrl, 'الاسم واللقب'),
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
                height: 52,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _loading
                      ?  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.textPrimary, strokeWidth: 2.5))
                      :  Icon(Icons.send, color: AppColors.textPrimary),
                  label: Text(
                    _loading ? 'جاري الإرسال...' : 'إرسال الطلب',
                    style:  TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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

  Widget _field(TextEditingController c, String hint, {TextInputType? keyboard, bool ltr = false}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: c,
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
