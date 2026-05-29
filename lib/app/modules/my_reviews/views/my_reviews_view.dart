import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../services/review_service.dart';
import '../controllers/my_reviews_controller.dart';

class MyReviewsView extends GetView<MyReviewsController> {
  const MyReviewsView({super.key});

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
        title: const Text(
          'Ulasan Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        if (controller.myReviews.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myReviews.length,
          itemBuilder: (context, index) {
            final review = controller.myReviews[index];
            return _ReviewCard(
              review: review,
              onEdit: () => controller.editReview(review),
              onDelete: () => controller.deleteReview(review),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.rate_review_outlined, color: AppColors.white54, size: 48),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada ulasan',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ulasan yang kamu tulis akan muncul di sini',
            style: TextStyle(color: AppColors.white54),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan gambar, nama tempat, rating, tanggal
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: review.placeImageUrl != null
                      ? Image.network(
                          review.placeImageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _placeholderIcon(review.placeType),
                        )
                      : _placeholderIcon(review.placeType),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge tipe tempat + Nama tempat
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              review.placeType == 'restoran' ? 'Restoran' : 'Wisata',
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              review.placeName ?? 'Tempat',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                              color: AppColors.ratingColor,
                              size: 16,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            review.dateFormatted,
                            style: const TextStyle(color: AppColors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Judul ulasan (jika ada)
          if (review.title != null && review.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Text(
                review.title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Isi review
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              review.comment,
              style: const TextStyle(color: AppColors.white70, fontSize: 13, height: 1.45),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Foto lampiran (jika ada)
          if (review.imageUrls.isNotEmpty) ...[
            SizedBox(
              height: 86,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: review.imageUrls.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      review.imageUrls[i],
                      width: 74,
                      height: 74,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 74,
                        height: 74,
                        color: AppColors.bgColor,
                        child: const Icon(Icons.image_not_supported,
                            color: AppColors.white54, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Tombol edit & hapus
          Divider(color: Colors.white.withOpacity(0.07), height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryColor),
                label: const Text('Edit', style: TextStyle(color: AppColors.primaryColor, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                label: const Text('Hapus', style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholderIcon(String placeType) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        placeType == 'restoran' ? Icons.restaurant : Icons.landscape,
        color: AppColors.white54,
        size: 24,
      ),
    );
  }
}