import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/theme_constants.dart';

class SettingsController extends GetxController {
  // Toggles notifikasi
  final promoWisata = true.obs;
  final promoRestoran = true.obs;
  final balasanUlasan = true.obs;
  final aktivitasAkun = true.obs;


  // Bahasa aktif
  final selectedLanguage = 'Indonesia'.obs;

  void changeLanguage(String lang) {
    if (lang == 'Indonesia') {
      selectedLanguage.value = 'Indonesia';
    } else {
      selectedLanguage.value = 'English';
    }
    Get.snackbar(
      'Bahasa',
      'Aplikasi akan menggunakan ${selectedLanguage.value}',
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
    );
  }

  void goToAccountSettings() {
    Get.toNamed(Routes.EDIT_PROFILE);
  }

  void goToPrivacySecurity() {
    Get.toNamed(Routes.PRIVACY_SECURITY);
  }

  void goToAboutApp() {
    Get.toNamed(Routes.ABOUT);
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: const Text('Konfirmasi Keluar', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin keluar?', style: TextStyle(color: AppColors.white70)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal', style: TextStyle(color: AppColors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Get.back();
              Get.offAllNamed(Routes.LOGIN);
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void goBack() => Get.back();
}