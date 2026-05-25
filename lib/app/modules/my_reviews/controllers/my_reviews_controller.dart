import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';

class MyReviewsController extends GetxController {
  // Data review statis (nanti dari Supabase)
  var myReviews = <Map<String, dynamic>>[
    {
      'id': '1',
      'placeName': 'Pantai Kelingking',
      'rating': 5,
      'date': '15 Februari 2026',
      'usefulCount': 10,
      'review': 'Pemandangan sangat indah! Airnya jernih, sayang aksesnya cukup ekstrim tapi worth it.',
      'image': 'assets/images/kelingking.jpg',
    },
    {
      'id': '2',
      'placeName': 'Warung Babi Guling Ibu Oka',
      'rating': 4,
      'date': '10 Februari 2026',
      'usefulCount': 5,
      'review': 'Babi gulingnya enak, bumbu meresap. Antrian lumayan panjang tapi cepat.',
      'image': 'assets/images/restoran1.jpg',
    },
    {
      'id': '3',
      'placeName': 'Tegalalang Rice Terrace',
      'rating': 5,
      'date': '5 Februari 2026',
      'usefulCount': 15,
      'review': 'Sawah terasering yang hijau, cocok untuk foto pagi hari. Ada ayunan instagramable.',
      'image': 'assets/images/tegalalang.jpg',
    },
  ].obs;

  void editReview(Map<String, dynamic> review) {
    // Nanti akan navigasi ke halaman edit review
    Get.snackbar(
      'Edit Review',
      'Fitur edit akan segera hadir untuk ${review['placeName']}',
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
    );
  }

  void deleteReview(Map<String, dynamic> review) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: const Text('Hapus Ulasan', style: TextStyle(color: Colors.white)),
        content: Text(
          'Apakah Anda yakin ingin menghapus ulasan untuk ${review['placeName']}?',
          style: const TextStyle(color: AppColors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: AppColors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              myReviews.remove(review);
              Get.back();
              Get.snackbar(
                'Berhasil',
                'Ulasan berhasil dihapus',
                backgroundColor: Colors.green,
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

  void goBack() => Get.back();
}