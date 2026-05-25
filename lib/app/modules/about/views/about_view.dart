import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../controllers/about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildAppInfo(),
                    const SizedBox(height: 30),
                    _buildVersionInfo(),
                    const SizedBox(height: 30),
                    _buildDeveloperInfo(),
                    const SizedBox(height: 30),
                    _buildSocialLinks(),
                    const SizedBox(height: 30),
                    _buildCopyright(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: controller.goBack,
          ),
          const SizedBox(width: 8),
          const Text(
            'Tentang Aplikasi',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.5), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                'assets/images/Logo_bercak_bali.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.landscape,
                    color: AppColors.primaryColor, size: 50),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'BERCAK BALI',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4),
          ),
          const SizedBox(height: 8),
          const Text(
            'Curated Island Journeys',
            style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bercak Bali adalah aplikasi panduan wisata yang membantu Anda menemukan destinasi terbaik, restoran tersembunyi, dan pengalaman autentik di Pulau Dewata.',
            style: TextStyle(
                color: AppColors.white70, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline,
                color: AppColors.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Versi Aplikasi',
                    style:
                        TextStyle(color: AppColors.white70, fontSize: 12)),
                SizedBox(height: 4),
                Text('1.0.0',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.ratingColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Terbaru',
                style: TextStyle(
                    color: AppColors.ratingColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengembang',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('BC',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Bercak Studio',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('bercakstudio@gmail.com',
                        style: TextStyle(
                            color: AppColors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ikuti Kami',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _socialButton(Icons.facebook, 'Facebook'),
              _socialButton(Icons.camera_alt, 'Instagram'),
              _socialButton(Icons.youtube_searched_for, 'YouTube'),
              _socialButton(Icons.alternate_email, 'Twitter'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(color: AppColors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildCopyright() {
    return Column(
      children: const [
        Text('© 2026 Bercak Studio',
            style: TextStyle(color: AppColors.white54, fontSize: 12)),
        SizedBox(height: 4),
        Text('All rights reserved',
            style: TextStyle(color: AppColors.white54, fontSize: 11)),
      ],
    );
  }
}
