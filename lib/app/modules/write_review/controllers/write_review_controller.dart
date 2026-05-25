import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';

class WriteReviewController extends GetxController {
  // Data tempat yang akan di-review
  late String placeId;
  late String placeName;
  late String placeType; // 'wisata' atau 'restoran'
  late String placeImage;

  // Form fields
  final rating = 0.obs;
  final titleController = TextEditingController();
  final reviewController = TextEditingController();

  // Photo upload (simulasi)
  final selectedImages = <String>[].obs; // nanti pakai file path
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      placeId = args['placeId'] ?? '';
      placeName = args['placeName'] ?? '';
      placeType = args['placeType'] ?? 'wisata';
      placeImage = args['placeImage'] ?? '';
    }
  }

  void setRating(int value) {
    rating.value = value;
  }

  void addPhoto() {
    Get.snackbar(
      'Upload Foto',
      'Fitur upload foto akan segera hadir',
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
    );
    // Nanti implementasi dengan image_picker
  }

  void removePhoto(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> submitReview() async {
    // Validasi
    if (rating.value == 0) {
      Get.snackbar(
        'Validasi',
        'Harap berikan rating bintang',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (reviewController.text.trim().isEmpty) {
      Get.snackbar(
        'Validasi',
        'Harap tulis ulasan Anda',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;

    // Simulasi proses submit (nanti ganti dengan panggilan Supabase)
    await Future.delayed(const Duration(seconds: 1));

    // Data review yang akan dikirim
    final reviewData = {
      'placeId': placeId,
      'placeName': placeName,
      'placeType': placeType,
      'rating': rating.value,
      'title': titleController.text.trim(),
      'review': reviewController.text.trim(),
      'images': selectedImages.toList(),
      'date': DateTime.now().toString(),
    };

    debugPrint('Review submitted: $reviewData');

    isSubmitting.value = false;

    // Kembali ke halaman sebelumnya dan tampilkan pesan sukses
    Get.back(result: true);
    Get.snackbar(
      'Berhasil',
      'Ulasan Anda telah dikirim',
      backgroundColor: AppColors.ratingColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goBack() => Get.back();

  @override
  void onClose() {
    titleController.dispose();
    reviewController.dispose();
    super.onClose();
  }
}