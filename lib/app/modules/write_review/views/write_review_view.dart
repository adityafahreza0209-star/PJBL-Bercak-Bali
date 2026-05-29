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
        title: Text(
          controller.isEditing ? 'Edit Ulasan' : 'Tulis Ulasan',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              child: TextButton(
                onPressed:
                    controller.isSubmitting.value ? null : controller.submitReview,
                style: TextButton.styleFrom(
                  backgroundColor: controller.isSubmitting.value
                      ? AppColors.cardColor
                      : AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Kirim',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlaceInfoCard(controller: controller),
            const SizedBox(height: 24),
            _RatingSection(controller: controller),
            const SizedBox(height: 24),
            _TitleField(controller: controller),
            const SizedBox(height: 16),
            _ReviewField(controller: controller),
            const SizedBox(height: 24),
            _PhotoSection(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO TEMPAT
// ─────────────────────────────────────────────────────────────────────────────

class _PlaceInfoCard extends StatelessWidget {
  final WriteReviewController controller;
  const _PlaceInfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              controller.placeType == 'restoran'
                  ? Icons.restaurant
                  : Icons.landscape,
              color: AppColors.primaryColor,
              size: 24,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RATING
// ─────────────────────────────────────────────────────────────────────────────

class _RatingSection extends StatelessWidget {
  final WriteReviewController controller;
  const _RatingSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Rating'),
        const SizedBox(height: 14),
        Obx(
          () => Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => controller.setRating(i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    i < controller.rating.value
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.ratingColor,
                    size: 44,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            controller.ratingLabel,
            style: TextStyle(
              color: controller.rating.value > 0
                  ? AppColors.ratingColor
                  : AppColors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JUDUL (OPSIONAL)
// ─────────────────────────────────────────────────────────────────────────────

class _TitleField extends StatelessWidget {
  final WriteReviewController controller;
  const _TitleField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Judul Ulasan (Opsional)'),
        const SizedBox(height: 10),
        TextField(
          controller: controller.titleController,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: _inputDecoration('Contoh: Pengalaman yang tak terlupakan!'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KOMENTAR
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewField extends StatelessWidget {
  final WriteReviewController controller;
  const _ReviewField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Ulasan'),
        const SizedBox(height: 10),
        TextField(
          controller: controller.reviewController,
          style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          maxLines: 6,
          decoration: _inputDecoration('Ceritakan pengalaman Anda...'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOTO
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoSection extends StatelessWidget {
  final WriteReviewController controller;
  const _PhotoSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionLabel('Foto (Opsional)'),
            const Spacer(),
            Obx(
              () {
                final totalCount = controller.selectedImages.length + controller.existingImageUrls.length;
                return Text(
                  '$totalCount/5',
                  style: const TextStyle(color: AppColors.white54, fontSize: 13),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Tambahkan foto untuk membantu pengunjung lain.',
          style: TextStyle(color: AppColors.white54, fontSize: 12),
        ),
        const SizedBox(height: 14),
        Obx(
          () {
            final totalCount = controller.selectedImages.length + controller.existingImageUrls.length;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // Tombol tambah foto
                if (totalCount < 5)
                  GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: AppColors.primaryColor, size: 28),
                          SizedBox(height: 4),
                          Text(
                            'Tambah',
                            style: TextStyle(
                                color: AppColors.primaryColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Preview foto lama (Supabase)
                ...controller.existingImageUrls.asMap().entries.map(
                      (entry) => _NetworkImagePreviewTile(
                        imageUrl: entry.value,
                        onRemove: () => controller.removeExistingImage(entry.key),
                      ),
                    ),

                // Preview foto baru yang baru dipilih
                ...controller.selectedImages.asMap().entries.map(
                      (entry) => _ImagePreviewTile(
                        file: entry.value,
                        onRemove: () => controller.removeImage(entry.key),
                      ),
                    ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _NetworkImagePreviewTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onRemove;
  const _NetworkImagePreviewTile({required this.imageUrl, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 86,
            height: 86,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 86,
              height: 86,
              color: AppColors.bgColor,
              child: const Icon(Icons.broken_image, color: AppColors.white54),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePreviewTile extends StatelessWidget {
  final Object file; // File (dart:io)
  final VoidCallback onRemove;
  const _ImagePreviewTile({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file as dynamic,
            width: 86,
            height: 86,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.white54, fontSize: 14),
      filled: true,
      fillColor: AppColors.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppColors.primaryColor.withOpacity(0.5), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );