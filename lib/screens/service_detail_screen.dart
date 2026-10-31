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
                appBar: AppBar(
                    elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon:  Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title:  Text(
            'تفاصيل الخدمة',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
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
                    child:  Icon(Icons.broken_image, color: AppColors.textSecondary, size: 60),
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
                      style:  TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // السعر
                    Text(
                      '$price د.ج',
                      style: const TextStyle(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                     Divider(color: AppColors.textSecondary.withValues(alpha: 0.12)),
                    const SizedBox(height: 16),
                    
                    // الوصف
                     Text(
                      'وصف الخدمة',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc.isNotEmpty ? desc : 'لا يوجد وصف لهذه الخدمة.',
                      style:  TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                     Divider(color: AppColors.textSecondary.withValues(alpha: 0.12)),
                    const SizedBox(height: 16),

                    // معلومات صاحب الخدمة
                     Text(
                      'مقدم الخدمة',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
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
                              style:  TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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
                        child:  Text(
                          'طلب الخدمة',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
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
