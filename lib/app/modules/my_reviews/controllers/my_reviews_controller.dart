import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/review_service.dart';
import '../../../widgets/theme_constants.dart';
import '../../../routes/app_pages.dart';

class MyReviewsController extends GetxController {
  final _reviewService = ReviewService();
  
  final myReviews = <ReviewModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    final userId = AuthService.to.userId;
    if (userId.isEmpty) return;

    isLoading.value = true;
    try {
      final reviews = await _reviewService.fetchUserReviews(userId);
      myReviews.assignAll(reviews);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat memuat ulasan Anda.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editReview(ReviewModel review) async {
    final result = await Get.toNamed(
      Routes.WRITE_REVIEW,
      arguments: {
        'review': review,
      },
    );
    
    if (result == true) {
      fetchReviews();
    }
  }

  void deleteReview(ReviewModel review) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: const Text('Hapus Ulasan', style: TextStyle(color: Colors.white)),
        content: Text(
          'Apakah Anda yakin ingin menghapus ulasan untuk ${review.placeName ?? 'tempat ini'}?',
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
            onPressed: () async {
              Get.back(); // Tutup dialog
              isLoading.value = true;
              try {
                await _reviewService.deleteReview(
                  reviewId: review.id,
                  userId: AuthService.to.userId,
                );
                myReviews.remove(review);
                Get.snackbar(
                  'Berhasil',
                  'Ulasan berhasil dihapus',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Gagal',
                  'Gagal menghapus ulasan. Silakan coba lagi.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } finally {
                isLoading.value = false;
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void goBack() => Get.back();
}