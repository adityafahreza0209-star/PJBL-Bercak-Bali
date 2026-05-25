import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: controller.goBack,
        ),
        title: const Text('Pengaturan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAccountSection(),
            const SizedBox(height: 24),
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildLanguageSection(),
            const SizedBox(height: 24),
            _buildPrivacySecuritySection(),
            const SizedBox(height: 24),
            _buildAboutSection(),
            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ========== AKUN ==========
  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Akun'),
        const SizedBox(height: 8),
        _menuItem(
          icon: Icons.person_outline,
          title: 'Pengaturan Akun',
          subtitle: 'Edit profil, ubah foto, email, username, bio',
          onTap: controller.goToAccountSettings,
        ),
      ],
    );
  }

  // ========== NOTIFIKASI ==========
  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Notifikasi'),
        const SizedBox(height: 8),
        _toggleItem(
          icon: Icons.local_offer_outlined,
          title: 'Promo & rekomendasi wisata',
          value: controller.promoWisata,
          onChanged: (v) => controller.promoWisata.value = v,
        ),
        _toggleItem(
          icon: Icons.restaurant_outlined,
          title: 'Promo restoran',
          value: controller.promoRestoran,
          onChanged: (v) => controller.promoRestoran.value = v,
        ),
        _toggleItem(
          icon: Icons.comment_outlined,
          title: 'Balasan pada ulasan saya',
          value: controller.balasanUlasan,
          onChanged: (v) => controller.balasanUlasan.value = v,
        ),
        _toggleItem(
          icon: Icons.notifications_active_outlined,
          title: 'Aktivitas akun',
          value: controller.aktivitasAkun,
          onChanged: (v) => controller.aktivitasAkun.value = v,
        ),
      ],
    );
  }

  // ========== BAHASA ==========
  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Bahasa'),
        const SizedBox(height: 8),
        Obx(() => Column(
              children: [
                _radioItem('Indonesia', controller.selectedLanguage.value == 'Indonesia', () {
                  controller.changeLanguage('Indonesia');
                }),
                _radioItem('English', controller.selectedLanguage.value == 'English', () {
                  controller.changeLanguage('English');
                }),
              ],
            )),
      ],
    );
  }

  // ========== PRIVASI & KEAMANAN ==========
  Widget _buildPrivacySecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Privasi & Keamanan'),
        const SizedBox(height: 8),
        _menuItem(
          icon: Icons.lock_outline,
          title: 'Ubah Password',
          subtitle: 'Ganti kata sandi akun Anda',
          onTap: () => Get.snackbar('Coming Soon', 'Fitur ubah password segera hadir'),
        ),
        _menuItem(
          icon: Icons.public_outlined,
          title: 'Akun Privat / Publik',
          subtitle: 'Kelola visibilitas profil',
          onTap: () => Get.snackbar('Coming Soon', 'Fitur ini akan segera tersedia'),
        ),
        _menuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Kebijakan Privasi',
          subtitle: 'Baca kebijakan privasi kami',
          onTap: () => Get.snackbar('Kebijakan Privasi', 'Halaman kebijakan privasi akan segera hadir'),
        ),
        _menuItem(
          icon: Icons.description_outlined,
          title: 'Syarat & Ketentuan',
          subtitle: 'Baca syarat dan ketentuan',
          onTap: () => Get.snackbar('Syarat & Ketentuan', 'Halaman syarat & ketentuan akan segera hadir'),
        ),
      ],
    );
  }

  // ========== TENTANG APLIKASI ==========
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Tentang Aplikasi'),
        const SizedBox(height: 8),
        _menuItem(
          icon: Icons.info_outline,
          title: 'Informasi Bercak Bali',
          subtitle: 'Versi, deskripsi, pengembang, kontak',
          onTap: controller.goToAboutApp,
        ),
      ],
    );
  }

  // ========== LOGOUT ==========
  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.logout,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembantu
  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(color: AppColors.white70, fontSize: 14, fontWeight: FontWeight.w600));
  }

  Widget _menuItem({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primaryColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: AppColors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleItem({required IconData icon, required String title, required RxBool value, required void Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
            Obx(() => Switch(value: value.value, onChanged: onChanged, activeColor: AppColors.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _radioItem(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const Spacer(),
            if (isSelected)
              Text(label == 'Indonesia' ? 'Indonesia' : 'English',
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}