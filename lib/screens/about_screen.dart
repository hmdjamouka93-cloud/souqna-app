import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _email = 'souqna.dz@gmail.com';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'حول',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    size: 60,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'سوقنا',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'الإصدار 1.0.0',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _paragraph(
                'سوقنا هو سوق مغاربي شامل للإعلانات المبوبة، حيث يمكنك بيع وشراء أي شيء '
                'تريده مجاناً وبدون أي عمولة. يجمع سوقنا بين البائعين والمشترين في منصة '
                'واحدة سهلة الاستخدام وآمنة، في الجزائر وتونس والمغرب وليبيا.',
              ),
              const SizedBox(height: 16),
              _paragraph(
                'يوفر سوقنا للبائع منصة قوية لعرض سلعه وخدماته، سواء كان فرداً أو شركة '
                'أو متجراً. كما يتيح للمشتري تصفح آلاف الإعلانات يومياً للعثور على أفضل '
                'العروض في كل المجالات — سيارات، عقارات، إلكترونيات، ملابس، والمزيد.',
              ),
              const SizedBox(height: 16),
              _paragraph(
                'نهدف من خلال سوقنا إلى تسهيل التجارة الإلكترونية في المغرب العربي، وربط '
                'البائع بالمشتري بشكل مباشر وسريع، مع الحفاظ على الخصوصية والأمان. '
                'انضم إلينا اليوم واكتشف تجربة تسوق مختلفة!',
              ),
              const SizedBox(height: 34),
              const Center(
                child: Text(
                  'منتج من',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.memory,
                        color: AppColors.accent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Jamouka',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'للتكنولوجيا الرقمية',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('الموقع الإلكتروني - قريباً'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.language, color: AppColors.accent),
                  label: const Text(
                    'تصفح موقعنا',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _contact(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.email_outlined, color: Colors.white),
                  label: const Text(
                    'تواصل معنا',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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

  Widget _paragraph(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.7,
      ),
    );
  }

  Future<void> _contact(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      query: 'subject=استفسار حول تطبيق سوقنا',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('راسلنا على $_email')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text('راسلنا على $_email')),
      );
    }
  }
}
