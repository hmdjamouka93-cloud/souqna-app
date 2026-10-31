import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/auth_gate.dart';
import '../services/location_service.dart';
import '../services/order_service.dart';
import '../services/product_like_service.dart';
import '../services/report_service.dart';
import '../widgets/comments_section.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final Map<String, dynamic> store;
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.store,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _likes = 0;
  int _dislikes = 0;
  String? _myReaction;

  int _currentImage = 0;
  String? _selectedColor;
  String? _selectedSize;
  int _quantity = 1;

  final _firstNameCtrl = TextEditingController();
    final _phoneCtrl = TextEditingController();

  String? _wilayaName;
  String? _wilayaCode;
  String? _dairaName;
  List<Map<String, String>> _wilayas = [];
  List<String> _dairas = [];

  bool _sending = false;
  String? _error;

  List<String> get _images =>
      (widget.product['images'] as List?)?.cast<String>() ?? [];
  List<String> get _colors =>
      (widget.product['colors'] as List?)?.cast<String>() ?? [];
  List<String> get _sizes =>
      (widget.product['sizes'] as List?)?.cast<String>() ?? [];
  int get _availableQty => (widget.product['quantity'] ?? 0) as int;

  @override
  void initState() {
    super.initState();
    _loadLikes();
    if (_colors.isNotEmpty) _selectedColor = _colors.first;
    if (_sizes.isNotEmpty) _selectedSize = _sizes.first;
    _loadWilayas();
    _prefillUserData();
  }

  Future<void> _prefillUserData() async {
    final data = await AuthService.getUserData();
    if (!mounted || data == null) return;
    final name = (data['name'] ?? '').toString().trim();
    final parts = name.split(' ');
    setState(() {
    });
  }

  Future<void> _loadWilayas() async {
    final list = await LocationService.getWilayas();
    if (!mounted) return;
    setState(() => _wilayas = list);
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
    _firstNameCtrl.dispose();
        _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOrder() async {
    if (!AuthService.isLoggedIn) {
      await requireAuth(context, _sendOrder,
          message: 'يجب تسجيل الدخول لإرسال الطلب.');
      return;
    }
    final fullName = _firstNameCtrl.text.trim();
    final fn = fullName;
    final ln = '';
    final phone = _phoneCtrl.text.trim();

    if (fn.isEmpty) {
      setState(() => _error = 'اكتب الاسم واللقب');
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

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      final id = await OrderService.createOrder(
        storeId: (widget.store['id'] ?? '').toString(),
        productId: (widget.product['id'] ?? '').toString(),
        productName: (widget.product['name'] ?? '').toString(),
        productPrice: (widget.product['price'] ?? 0) as int,
        productImage:
            _images.isNotEmpty ? _images.first : '',
        firstName: fn,
        lastName: ln,
        phone: phone,
        wilaya: _wilayaName!,
        daira: _dairaName!,
        color: _selectedColor ?? '',
        size: _selectedSize ?? '',
        quantity: _quantity,
      );

      if (!mounted) return;
      if (id == null) {
        setState(() {
          _error = 'فشل إرسال الطلب، حاول مرة أخرى';
          _sending = false;
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title:  Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('تم إرسال الطلب',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            content:  Text(
              'سيتواصل معك صاحب المتجر قريباً لتأكيد الطلب.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.6),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child:  Text('حسناً',
                    style: TextStyle(color: AppColors.textPrimary)),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'خطأ: $e';
        _sending = false;
      });
    }
  }

  Future<void> _loadLikes() async {
    final status = await ProductLikeService.getLikesStatus(
        (widget.product['id'] ?? '').toString());
    if (!mounted) return;
    setState(() {
      _likes = status['likes'] ?? 0;
      _dislikes = status['dislikes'] ?? 0;
      _myReaction = status['myReaction'];
    });
  }

  Future<void> _toggleReaction(bool isLike) async {
    if (!AuthService.isLoggedIn) {
      await requireAuth(context, () => _toggleReaction(isLike),
          message: 'يجب تسجيل الدخول للتفاعل مع المنتج.');
      return;
    }
    final ok = await ProductLikeService.toggleReaction(
      productId: (widget.product['id'] ?? '').toString(),
      isLike: isLike,
    );
    if (ok) _loadLikes();
  }

  Widget _reactionsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _toggleReaction(true),
              icon: Icon(
                _myReaction == 'like' ? Icons.thumb_up : Icons.thumb_up_outlined,
                color: _myReaction == 'like' ? AppColors.accent : AppColors.textPrimary,
                size: 20,
              ),
              label: Text('$_likes',
                  style: TextStyle(
                      color: _myReaction == 'like' ? AppColors.accent : AppColors.textPrimary)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: _myReaction == 'like' ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.24)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _toggleReaction(false),
              icon: Icon(
                _myReaction == 'dislike' ? Icons.thumb_down : Icons.thumb_down_outlined,
                color: _myReaction == 'dislike' ? Colors.red : AppColors.textPrimary,
                size: 20,
              ),
              label: Text('$_dislikes',
                  style: TextStyle(
                      color: _myReaction == 'dislike' ? Colors.red : AppColors.textPrimary)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: _myReaction == 'dislike' ? Colors.red : AppColors.textSecondary.withValues(alpha: 0.24)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReportDialog() async {
    if (!AuthService.isLoggedIn) {
      await requireAuth(context, _openReportDialog,
          message: 'يجب تسجيل الدخول للإبلاغ عن المنتج.');
      return;
    }
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title:  Text('الإبلاغ عن المنتج',
              style: TextStyle(color: AppColors.textPrimary)),
          content: TextField(
            controller: reasonCtrl,
            maxLines: 3,
            style:  TextStyle(color: AppColors.textPrimary),
            decoration:  InputDecoration(
              hintText: 'اكتب سبب الإبلاغ هنا...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.24))),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:  Text('إلغاء',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child:  Text('إبلاغ',
                  style: TextStyle(color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
    if (ok == true && reasonCtrl.text.trim().isNotEmpty) {
      final success = await ReportService.submitReport(
        productId: (widget.product['id'] ?? '').toString(),
        reason: reasonCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(success
                  ? 'تم إرسال الإبلاغ، شكراً لك'
                  : 'حدث خطأ، حاول مرة أخرى')),
        );
      }
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
            icon:  Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title:  Text('تفاصيل المنتج',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                      _gallery(),
                      const SizedBox(height: 16),
                      _header(),
                      const SizedBox(height: 16),
                      _reactionsRow(),
                      const SizedBox(height: 16),
                      if (_colors.isNotEmpty) _colorSection(),
                      if (_sizes.isNotEmpty) _sizeSection(),
                      const SizedBox(height: 8),
                      _quantitySection(),
                      const SizedBox(height: 20),
                       Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(color: AppColors.textSecondary.withValues(alpha: 0.12)),
                      ),
                      const SizedBox(height: 12),
                       Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('معلومات الطلب',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      _orderForm(),
                      const SizedBox(height: 24),
                       Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(color: AppColors.textSecondary.withValues(alpha: 0.12)),
                      ),
                      const SizedBox(height: 8),
                      CommentsSection(
                        listingId: (widget.product['id'] ?? '').toString(),
                      ),
                      const SizedBox(height: 24),
                    ],
          ),
        ),
      ),
    );
  }

  Widget _gallery() {
    if (_images.isEmpty) {
      return Container(
        height: 300,
        color: AppColors.card,
        child:  Icon(Icons.image_outlined,
            color: AppColors.textSecondary.withValues(alpha: 0.24), size: 80),
      );
    }
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _currentImage = i),
            itemBuilder: (_, i) => CachedNetworkImage(imageUrl: 
              _images[i],
              fit: BoxFit.cover,
              width: double.infinity,
              errorWidget: (_, _, _) => Container(
                  color: AppColors.card,
                  child:  Icon(Icons.broken_image,
                      color: AppColors.textSecondary.withValues(alpha: 0.24), size: 60)),
            ),
          ),
          if (_images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _images.length,
                  (i) => Container(
                    width: _currentImage == i ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _currentImage == i
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((widget.product['name'] ?? '').toString(),
              style:  TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${widget.product['price']} د.ج',
              style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if ((widget.product['description'] ?? '').toString().isNotEmpty)
            Text((widget.product['description'] ?? '').toString(),
                style:  TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.7)),
        ],
      ),
    );
  }

  Widget _colorSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('اللون',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colors
                .map((c) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedColor == c
                              ? AppColors.accent
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _selectedColor == c
                                  ? AppColors.accent
                                  : AppColors.textSecondary.withValues(alpha: 0.24)),
                        ),
                        child: Text(c,
                            style: TextStyle(
                                color: _selectedColor == c
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _sizeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('المقاس',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sizes
                .map((s) => GestureDetector(
                      onTap: () => setState(() => _selectedSize = s),
                      child: Container(
                        width: 52,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedSize == s
                              ? AppColors.accent
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _selectedSize == s
                                  ? AppColors.accent
                                  : AppColors.textSecondary.withValues(alpha: 0.24)),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                color: _selectedSize == s
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _quantitySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
           Text('الكمية:',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  icon:  Icon(Icons.remove, color: AppColors.textPrimary),
                ),
                Text('$_quantity',
                    style:  TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _quantity < _availableQty
                      ? () => setState(() => _quantity++)
                      : null,
                  icon:  Icon(Icons.add, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _orderForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(_firstNameCtrl, 'الاسم الكامل (الاسم واللقب)'),
                  const SizedBox(height: 12),
          _field(_phoneCtrl, 'رقم الهاتف',
              keyboard: TextInputType.phone, ltr: true),
          const SizedBox(height: 12),
          _wilayaDropdown(),
          const SizedBox(height: 12),
          _dairaDropdown(),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
              ),
              child: Text(_error!,
                  style: const TextStyle(
                      color: Colors.redAccent, fontSize: 13)),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _sendOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: _sending
                  ?  SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.textPrimary, strokeWidth: 2.5))
                  :  Icon(Icons.send, color: AppColors.textPrimary),
              label: Text(
                _sending ? 'جاري الإرسال...' : 'إرسال الطلب',
                style:  TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
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
                    child: Text(d,
                        style:  TextStyle(color: AppColors.textPrimary)),
                  ))
              .toList(),
          onChanged: _wilayaCode == null
              ? null
              : (v) => setState(() => _dairaName = v),
        ),
      ),
    );
  }

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
        style:  TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
               TextStyle(color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        ),
      ),
    );
  }
}
