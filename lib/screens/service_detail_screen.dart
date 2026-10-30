import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'request_service_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> service;
  final Map<String, dynamic> provider;

  const ServiceDetailScreen({
    super.key,
    required this.service,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final title = (service['title'] ?? '').toString();
    final desc = (service['description'] ?? '').toString();
    final price = service['price'] ?? 0;
    final image = (service['image'] ?? '').toString();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'تفاصيل الخدمة',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصورة
              if (image.isNotEmpty)
                CachedNetworkImage(imageUrl: 
                  image,
                  height: 300,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    height: 300,
                    color: AppColors.card,
                    child: const Icon(Icons.broken_image, color: Colors.white54, size: 60),
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // السعر
                    Text(
                      '$price د.ج',
                      style: const TextStyle(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),
                    
                    // الوصف
                    const Text(
                      'وصف الخدمة',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc.isNotEmpty ? desc : 'لا يوجد وصف لهذه الخدمة.',
                      style:  TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),

                    // معلومات صاحب الخدمة
                    const Text(
                      'مقدم الخدمة',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.background,
                          backgroundImage: (provider['avatar'] ?? '').toString().isNotEmpty
                              ? NetworkImage(provider['avatar'])
                              : null,
                          child: (provider['avatar'] ?? '').toString().isEmpty
                              ? const Icon(Icons.person, color: AppColors.accent)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (provider['name'] ?? '').toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              (provider['trade'] ?? '').toString(),
                              style:  TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // زر الطلب
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RequestServiceScreen(
                                service: service,
                                provider: provider,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'طلب الخدمة',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
