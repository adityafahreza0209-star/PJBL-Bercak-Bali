import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/custom_navbar.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildProfileCard(),
              const SizedBox(height: 24),
              _sectionHeader('Aktivitas Saya'),
              const SizedBox(height: 12),
              _buildActivityMenu(),
              const SizedBox(height: 24),
              _sectionHeader('Pengaturan'),
              const SizedBox(height: 12),
              _buildSettingsMenu(),
              const SizedBox(height: 24),
              _buildLogoutButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 3),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profil',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: Colors.white, size: 22),
            onPressed: () =>
                Get.toNamed(Routes.SETTINGS), // Navigasi ke halaman Settings
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Obx(() => CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.primaryColor,
                child: Text(
                  controller.userInitial.value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cardColor,
                  ),
                ),
              )),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(controller.userName.value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold))),
                const SizedBox(height: 4),
                Obx(() => Text(controller.userEmail.value,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14))),
                const SizedBox(height: 8),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(controller.userRole.value,
                          style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.white70, size: 20),
            onPressed: () => Get.toNamed(Routes.EDIT_PROFILE),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white));
  }

  Widget _buildActivityMenu() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _menuItem(Icons.bookmark_outline, 'Destinasi Tersimpan', '12',
              onTap: controller.goToSimpan),
          _menuDivider(),
          _menuItem(Icons.history, 'Riwayat Kunjungan', '8',
              onTap: controller.goToHistory),
          _menuDivider(),
          _menuItem(Icons.rate_review_outlined, 'Ulasan Saya', '5',
              onTap: () => Get.toNamed(Routes.MY_REVIEWS)),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _menuItem(Icons.notifications_outlined, 'Notifikasi', '',
              onTap: () =>
                   Get.toNamed(Routes.SETTINGS),),
          _menuDivider(),
          _menuItem(Icons.language, 'Bahasa', 'Indonesia',
              onTap: () =>  Get.toNamed(Routes.SETTINGS)),
          _menuDivider(),
          _menuItem(Icons.info_outline, 'Tentang Aplikasi', '',
              onTap: () => Get.toNamed(Routes.SETTINGS)), 
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle,
      {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
            ),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 14)),
            Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.3), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _menuDivider() {
    return Divider(
        height: 1,
        color: Colors.white.withOpacity(0.1),
        indent: 16,
        endIndent: 16);
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: controller.showLogoutDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Center(
          child: Text(
            'Keluar',
            style: TextStyle(
                color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
