import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../controllers/write_review_controller.dart';

class WriteReviewView extends GetView<WriteReviewController> {
  const WriteReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: controller.goBack,
        ),
        title: const Text(
          'Tulis Ulasan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isSubmitting.value ? null : controller.submitReview,
                child: Text(
                  controller.isSubmitting.value ? 'Mengirim...' : 'Kirim',
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlaceInfo(),
            const SizedBox(height: 24),
            _buildRatingSection(),
            const SizedBox(height: 24),
            _buildTitleField(),
            const SizedBox(height: 20),
            _buildReviewField(),
            const SizedBox(height: 20),
            _buildPhotoSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceInfo() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            controller.placeImage,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 60,
              height: 60,
              color: AppColors.cardColor,
              child: const Icon(Icons.location_on, color: AppColors.white54),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.placeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  controller.placeType == 'restoran' ? 'Restoran' : 'Wisata',
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => controller.setRating(index + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      index < controller.rating.value ? Icons.star : Icons.star_border,
                      color: AppColors.ratingColor,
                      size: 40,
                    ),
                  ),
                );
              }),
            )),
        const SizedBox(height: 8),
        Obx(() => Text(
              controller.rating.value == 0
                  ? 'Belum memberi rating'
                  : controller.rating.value == 1
                      ? 'Sangat Buruk'
                      : controller.rating.value == 2
                          ? 'Buruk'
                          : controller.rating.value == 3
                              ? 'Cukup'
                              : controller.rating.value == 4
                                  ? 'Baik'
                                  : 'Luar Biasa',
              style: TextStyle(
                color: controller.rating.value > 0 ? AppColors.ratingColor : AppColors.white54,
                fontSize: 13,
              ),
            )),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Judul Ulasan (Opsional)',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.titleController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Contoh: Pengalaman seru di sini!',
            hintStyle: const TextStyle(color: AppColors.white54),
            filled: true,
            fillColor: AppColors.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ulasan',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.reviewController,
          style: const TextStyle(color: Colors.white),
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Ceritakan pengalaman Anda di sini...',
            hintStyle: const TextStyle(color: AppColors.white54),
            filled: true,
            fillColor: AppColors.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tambah Foto (Opsional)',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Tombol tambah foto
                GestureDetector(
                  onTap: controller.addPhoto,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryColor.withOpacity(0.5)),
                    ),
                    child: const Icon(Icons.add_photo_alternate, color: AppColors.primaryColor, size: 30),
                  ),
                ),
                // List foto yang sudah dipilih
                ...controller.selectedImages.map((image) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: AppColors.cardColor,
                              child: const Icon(Icons.image, color: AppColors.white54),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => controller.removePhoto(controller.selectedImages.indexOf(image)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            )),
      ],
    );
  }
}