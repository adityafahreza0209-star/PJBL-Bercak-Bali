import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../widgets/theme_constants.dart';
import 'package:flutter/material.dart';

class HistoryController extends GetxController {
  final historyItems = <Map<String, dynamic>>[
    {
      'image': 'assets/images/tegalalang.jpg',
      'title': 'Tegalalang Rice Terrace',
      'location': 'Gianyar, Bali',
      'rating': '4.7',
      'visitDate': '12 Februari 2026',
      'category': 'Alam',
    },
    {
      'image': 'assets/images/uluwatu.jpg',
      'title': 'Pura Uluwatu',
      'location': 'Badung, Bali',
      'rating': '4.8',
      'visitDate': '5 Februari 2026',
      'category': 'Budaya',
    },
    {
      'image': 'assets/images/kelingking.jpg',
      'title': 'Pantai Kelingking',
      'location': 'Nusa Penida, Bali',
      'rating': '4.9',
      'visitDate': '28 Januari 2026',
      'category': 'Pantai',
    },
    {
      'image': 'assets/images/restoran1.jpg',
      'title': 'Warung Babi Guling Ibu Oka',
      'location': 'Ubud, Bali',
      'rating': '4.8',
      'visitDate': '20 Januari 2026',
      'category': 'Restoran',
    },
  ].obs;

  void goBack() => Get.back();

  void goToDetailWisata(Map<String, dynamic> item) {
    final data = {
      'title': item['title'],
      'location': item['location'],
      'detailImages': const [
        'assets/images/tegalalang.jpg',
        'assets/images/uluwatu.jpg',
        'assets/images/tanahlot.jpg',
      ],
    };
    // Get.toNamed: bisa back ke History
    Get.toNamed(Routes.DETAIL_WISATA, arguments: data);
  }

  void showClearDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: const Text('Hapus Riwayat',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'Apakah Anda yakin ingin menghapus semua riwayat kunjungan?',
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
              Get.back();
              historyItems.clear();
              Get.snackbar(
                'Berhasil',
                'Riwayat berhasil dihapus',
                backgroundColor: AppColors.primaryColor,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
