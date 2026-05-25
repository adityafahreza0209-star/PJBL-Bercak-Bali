import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../widgets/theme_constants.dart';

class ProfileController extends GetxController {
  // Data profil pengguna — nanti ambil dari Supabase
  final userName = 'Budi Santoso'.obs;
  final userEmail = 'budi@example.com'.obs;
  final userInitial = 'B'.obs;
  final userRole = 'Traveler'.obs;

  void goToSimpan() {
    // Get.toNamed: bisa back ke Profile
    Get.toNamed(Routes.SIMPAN);
  }

  void goToHistory() {
    // Get.toNamed: bisa back ke Profile
    Get.toNamed(Routes.HISTORY);
  }

  void goToAbout() {
    // Get.toNamed: bisa back ke Profile
    Get.toNamed(Routes.ABOUT);
  }

  void showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature akan segera hadir!',
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: const Text('Konfirmasi Keluar',
            style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin keluar?',
            style: TextStyle(color: AppColors.white70)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Get.back(); // tutup dialog
              // Hapus seluruh stack → Login jadi satu-satunya halaman
              Get.offAllNamed(Routes.LOGIN);
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
