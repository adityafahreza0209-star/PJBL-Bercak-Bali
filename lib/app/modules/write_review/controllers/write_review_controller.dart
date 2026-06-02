import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/auth_service.dart';
import '../../../services/review_service.dart';
import '../../../widgets/theme_constants.dart';

class WriteReviewController extends GetxController {
  // ── Mode Edit ────────────────────────────────────────────────
  bool isEditing = false;
  String? reviewId;
  final existingImageUrls = <String>[].obs;
  final imagesToDelete = <String>[].obs;

  // ── Data tempat yang akan di-review ─────────────────────────
  late String placeType; // 'wisata' atau 'restoran'
  late String placeName;
  String? wisataId;
  String? restaurantId;

  // ── Form fields ──────────────────────────────────────────────
  final rating = 0.obs;
  final titleController = TextEditingController();
  final reviewController = TextEditingController();

  // ── Gambar yang dipilih user (File lokal) ────────────────────
  final selectedImages = <File>[].obs;
  final isSubmitting = false.obs;

  final _service = ReviewService();
  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    
    // Cek jika ada objek review untuk diedit
    final ReviewModel? existingReview = args?['review'] as ReviewModel?;
    
    if (existingReview != null) {
      isEditing = true;
      reviewId = existingReview.id;
      placeType = existingReview.placeType;
      placeName = existingReview.placeName ?? '';
      wisataId = existingReview.wisataId;
      restaurantId = existingReview.restaurantId;
      
      // Pre-fill form
      rating.value = existingReview.rating;
      titleController.text = existingReview.title ?? '';
      reviewController.text = existingReview.comment;
      
      // Muat gambar lama yang sudah terupload
      existingImageUrls.assignAll(existingReview.imageUrls);
    } else {
      isEditing = false;
      placeType = args?['placeType'] as String? ?? 'wisata';
      placeName = args?['placeName'] as String? ?? '';
      wisataId = args?['wisataId'] as String?;
      restaurantId = args?['restaurantId'] as String?;
    }
  }

  // ── RATING ───────────────────────────────────────────────────

  void setRating(int value) => rating.value = value;

  String get ratingLabel => switch (rating.value) {
        0 => 'Belum memberi rating',
        1 => 'Sangat Buruk',
        2 => 'Buruk',
        3 => 'Cukup',
        4 => 'Bagus',
        _ => 'Luar Biasa',
      };

  // ── GAMBAR LOKAL ─────────────────────────────────────────────

  Future<void> pickImage() async {
    final totalImages = selectedImages.length + existingImageUrls.length;
    if (totalImages >= 5) {
      Get.snackbar('Batas Foto', 'Maksimal 5 foto per ulasan.',
          backgroundColor: AppColors.cardColor, colorText: Colors.white);
      return;
    }

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // kompres sebelum upload
    );

    if (picked != null) {
      selectedImages.add(File(picked.path));
    }
  }

  void removeImage(int index) => selectedImages.removeAt(index);

  // ── GAMBAR LAMA (SUPABASE) ───────────────────────────────────

  void removeExistingImage(int index) {
    final removed = existingImageUrls.removeAt(index);
    imagesToDelete.add(removed);
  }

  // ── SUBMIT ───────────────────────────────────────────────────

  Future<void> submitReview() async {
    // Validasi rating
    if (rating.value == 0) {
      Get.snackbar('Validasi', 'Harap berikan rating bintang.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Validasi komentar
    final comment = reviewController.text.trim();
    if (comment.isEmpty) {
      Get.snackbar('Validasi', 'Harap tulis ulasan Anda.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;

    try {
      if (isEditing) {
        await _service.updateReview(
          reviewId: reviewId!,
          userId: AuthService.to.userId,
          rating: rating.value,
          title: titleController.text.trim(),
          comment: comment,
          newImages: selectedImages.toList(),
          imagesToDelete: imagesToDelete.toList(),
        );
      } else {
        await _service.submitReview(
          userId: AuthService.to.userId,
          placeType: placeType,
          wisataId: wisataId,
          restaurantId: restaurantId,
          rating: rating.value,
          title: titleController.text.trim(),
          comment: comment,
          images: selectedImages.toList(),
        );
      }

      // Kembali ke halaman sebelumnya dengan sinyal sukses (result: true)
      Get.back(result: true);

      Get.snackbar(
        'Berhasil',
        isEditing
            ? 'Ulasan Anda telah diperbarui.'
            : 'Ulasan Anda telah dikirim. Terima kasih!',
        backgroundColor: AppColors.ratingColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      final message = _isDuplicateReviewError(e)
          ? 'Anda hanya dapat memberikan 1 ulasan per ${placeType == 'restoran' ? 'restoran' : 'wisata'}.'
          : 'Terjadi kesalahan. Silakan coba lagi.';

      Get.snackbar(
        'Gagal',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  bool _isDuplicateReviewError(Object error) {
    if (error is PostgrestException && error.code == '23505') {
      return true;
    }

    final errorText = error.toString().toLowerCase();
    return errorText.contains('duplicate') || errorText.contains('unique');
  }

  void goBack() => Get.back();

  @override
  void onClose() {
    titleController.dispose();
    reviewController.dispose();
    super.onClose();
  }
}
