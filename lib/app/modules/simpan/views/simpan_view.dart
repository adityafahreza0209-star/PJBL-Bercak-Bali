import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/custom_navbar.dart';
import '../controllers/simpan_controller.dart';

class SimpanView extends StatelessWidget { // HAPUS GetView
  const SimpanView({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan GetBuilder, bukan Obx
    return GetBuilder<SimpanController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildCategoryTabs(controller),
                Expanded(
                  child: controller.filteredItems.isEmpty
                      ? _buildEmptyState()
                      : _buildSavedList(controller.filteredItems),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const CustomNavBar(selectedIndex: 2),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tersimpan',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(SimpanController controller) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final cat = controller.categories[index];
          final isSelected = cat == controller.selectedTab.value;
          return GestureDetector(
            onTap: () => controller.selectTab(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : AppColors.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? AppColors.bgColor : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.cardColor, shape: BoxShape.circle),
            child: const Icon(Icons.bookmark_border, color: AppColors.white54, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada item tersimpan',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Item yang kamu simpan akan muncul di sini',
            style: TextStyle(color: AppColors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSavedList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _SavedItemCard(item: items[index]);
      },
    );
  }
}

// SAVED ITEM CARD (tidak berubah)
class _SavedItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _SavedItemCard({required this.item});

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Alam': return const Color(0xFF4CAF50);
      case 'Pantai': return const Color(0xFF2196F3);
      case 'Budaya': return const Color(0xFF9C27B0);
      case 'Hidden Gem': return const Color(0xFFFF9800);
      case 'Restoran': return const Color(0xFFF44336);
      default: return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(item['category']);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              item['image'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 100,
                color: AppColors.bgColor,
                child: const Icon(Icons.broken_image, color: AppColors.white54, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['title'],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item['category'], style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item['location'],
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.ratingColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 12),
                              const SizedBox(width: 2),
                              Text(item['rating'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, color: Colors.white.withOpacity(0.3), size: 12),
                        const SizedBox(width: 4),
                        Text(item['savedDate'], style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_vert, color: AppColors.white54, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}