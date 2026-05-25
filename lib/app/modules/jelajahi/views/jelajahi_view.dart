import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/custom_navbar.dart';
import '../controllers/jelajahi_controller.dart';

class JelajahiView extends GetView<JelajahiController> {
  const JelajahiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        slivers: [
          // SEARCH BAR
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppColors.bgColor,
            elevation: 0,
            expandedHeight: 110,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        focusNode: controller.searchFocusNode,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(
                          hintText: 'Cari destinasi atau restoran...',
                          hintStyle: TextStyle(color: AppColors.white54),
                          prefixIcon:
                              Icon(Icons.search, color: AppColors.white54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // CATEGORY CHIPS
          SliverToBoxAdapter(
            child: Container(
              height: 90,
              margin: const EdgeInsets.only(top: 16, bottom: 12),
              child: Obx(() {
                // SOLUSI: Ambil nilai reaktif di sini agar terbaca langsung oleh Obx
                final selectedCat = controller.selectedCategory.value;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final cat = controller.categories[index];
                    // Gunakan variabel lokal yang sudah reaktif di atas
                    final isSelected = cat['name'] == selectedCat;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () =>
                            controller.selectCategory(cat['name']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: 80,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primaryColor,
                                      AppColors.primaryColor.withOpacity(0.8),
                                    ],
                                  )
                                : null,
                            color:
                                isSelected ? null : AppColors.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryColor
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                cat['icon'],
                                color: isSelected
                                    ? AppColors.bgColor
                                    : AppColors.white70,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cat['name'],
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.bgColor
                                      : AppColors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          
          // DESTINATION LIST
          Obx(() {
            final selected = controller.selectedCategory.value;
            final list = selected == 'Semua'
                ? controller.destinations
                : controller.destinations
                    .where((d) => d['category'] == selected)
                    .toList();
            return SliverPadding(
              padding: const EdgeInsets.only(top: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dest = list[index];
                    return GestureDetector(
                      onTap: () => controller.goToDetailWisata(dest),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Image.network(
                                    dest['image'],
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: AppColors.bgColor,
                                        child: const Center(
                                          child: Icon(
                                              Icons.image_not_supported,
                                              color: AppColors.white54,
                                              size: 48),
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgColor
                                            .withOpacity(0.8),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: AppColors.primaryColor,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            dest['rating'].toString(),
                                            style: const TextStyle(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dest['title'],
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                  Icons.location_on,
                                                  size: 16,
                                                  color:
                                                      AppColors.primaryColor),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(dest['location'],
                                                style: const TextStyle(
                                                    color: AppColors.white70,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                        Text('${dest['reviews']} reviews',
                                            style: const TextStyle(
                                                color: AppColors.white54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: list.length,
                ),
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 1),
    );
  }
}