import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/custom_navbar.dart';
import '../controllers/jelajahi_controller.dart';
import '../../../services/wisata_service.dart';
import '../../../services/restaurant_service.dart';

class JelajahiView extends GetView<JelajahiController> {
  const JelajahiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        color: AppColors.primaryColor,
        backgroundColor: AppColors.cardColor,
        child: CustomScrollView(
          slivers: [
            _SearchAppBar(controller: controller),
            _TabBar(controller: controller),
            _Body(controller: controller),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 1),
    );
  }
}

// ── Search AppBar ──────────────────────────────────────────────

class _SearchAppBar extends StatelessWidget {
  const _SearchAppBar({required this.controller});
  final JelajahiController controller;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
                child: Obx(() {
                  // Membaca getter reaktif agar Obx bekerja dengan benar dan tidak error
                  final hasText = controller.searchQuery.isNotEmpty;
                  return TextField(
                    controller: controller.searchController,
                    focusNode: controller.searchFocusNode,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      hintText: 'Cari destinasi atau restoran...',
                      hintStyle: const TextStyle(color: AppColors.white54),
                      prefixIcon: const Icon(Icons.search, color: AppColors.white54),
                      suffixIcon: hasText
                          ? IconButton(
                              icon: const Icon(Icons.close, color: AppColors.white54, size: 20),
                              onPressed: controller.clearSearch,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab Bar (Semua / Wisata / Restoran) ────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({required this.controller});
  final JelajahiController controller;

  static const _tabs = [
    (tab: JelajahiTab.semua, label: 'Semua', icon: Icons.apps),
    (tab: JelajahiTab.wisata, label: 'Wisata', icon: Icons.landscape),
    (tab: JelajahiTab.restoran, label: 'Restoran', icon: Icons.restaurant),
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Obx(() {
          return Row(
            children: _tabs.map((item) {
              final isSelected = controller.activeTab.value == item.tab;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _TabChip(
                    label: item.label,
                    icon: item.icon,
                    isSelected: isSelected,
                    onTap: () => controller.selectTab(item.tab),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
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
          color: isSelected ? null : AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.bgColor : AppColors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.bgColor : AppColors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Body: loading / error / list ───────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.controller});
  final JelajahiController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading state
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      // Error state
      if (controller.errorMessage.value.isNotEmpty) {
        return SliverFillRemaining(
          child: _ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.onRefresh,
          ),
        );
      }

      final tab = controller.activeTab.value;
      final wisata = controller.filteredWisata;
      final restaurants = controller.filteredRestaurants;

      // Empty state saat search tidak menemukan hasil
      final isEmpty = switch (tab) {
        JelajahiTab.wisata => wisata.isEmpty,
        JelajahiTab.restoran => restaurants.isEmpty,
        JelajahiTab.semua => wisata.isEmpty && restaurants.isEmpty,
      };

      if (isEmpty) {
        return const SliverFillRemaining(child: _EmptyView());
      }

      // Daftar hasil
      return SliverPadding(
        padding: const EdgeInsets.only(top: 4),
        sliver: SliverList(
          delegate: SliverChildListDelegate(
            _buildItems(tab, wisata, restaurants),
          ),
        ),
      );
    });
  }

  List<Widget> _buildItems(
    JelajahiTab tab,
    List<WisataModel> wisata,
    List<RestaurantModel> restaurants,
  ) {
    final items = <Widget>[];

    if (tab == JelajahiTab.semua || tab == JelajahiTab.wisata) {
      if (wisata.isNotEmpty) {
        if (tab == JelajahiTab.semua) {
          items.add(_SectionHeader(title: 'Wisata', count: wisata.length));
        }
        items.addAll(
          wisata.map(
            (w) => _WisataCard(
              wisata: w,
              onTap: () => controller.goToDetailWisata(w),
            ),
          ),
        );
      }
    }

    if (tab == JelajahiTab.semua || tab == JelajahiTab.restoran) {
      if (restaurants.isNotEmpty) {
        if (tab == JelajahiTab.semua) {
          items.add(_SectionHeader(title: 'Restoran', count: restaurants.length));
        }
        items.addAll(
          restaurants.map(
            (r) => _RestaurantCard(
              resto: r,
              onTap: () => controller.goToDetailRestoran(r),
            ),
          ),
        );
      }
    }

    return items;
  }
}

// ── Section Header ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wisata Card ────────────────────────────────────────────────

class _WisataCard extends StatelessWidget {
  const _WisataCard({required this.wisata, required this.onTap});
  final WisataModel wisata;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PlaceCard(
      imageUrl: wisata.imageUrl,
      title: wisata.title,
      subtitle: wisata.location,
      rating: wisata.rating,
      totalReviews: wisata.totalReviews,
      badgeText: wisata.category.isNotEmpty ? wisata.category : null,
      badgeIcon: Icons.landscape,
      onTap: onTap,
    );
  }
}

// ── Restaurant Card ────────────────────────────────────────────

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.resto, required this.onTap});
  final RestaurantModel resto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PlaceCard(
      imageUrl: resto.imageUrl,
      title: resto.name,
      subtitle: resto.location,
      rating: resto.rating,
      totalReviews: resto.totalReviews,
      badgeText: resto.cuisine.isNotEmpty ? resto.cuisine : null,
      badgeIcon: Icons.restaurant,
      extraInfo: resto.priceRange.isNotEmpty ? resto.priceRange : null,
      onTap: onTap,
    );
  }
}

// ── Shared Place Card ──────────────────────────────────────────

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.totalReviews,
    this.badgeText,
    required this.badgeIcon,
    this.extraInfo,
    required this.onTap,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final double rating;
  final int totalReviews;
  final String? badgeText;
  final IconData badgeIcon;
  final String? extraInfo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              _CardImage(imageUrl: imageUrl, rating: rating),
              _CardInfo(
                title: title,
                subtitle: subtitle,
                totalReviews: totalReviews,
                badgeText: badgeText,
                badgeIcon: badgeIcon,
                extraInfo: extraInfo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.imageUrl, required this.rating});
  final String imageUrl;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 200,
            color: AppColors.bgColor,
            child: const Center(
              child: Icon(Icons.image_not_supported, color: AppColors.white54, size: 48),
            ),
          ),
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: AppColors.bgColor,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
        // Badge rating
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppColors.primaryColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CardInfo extends StatelessWidget {
  const _CardInfo({
    required this.title,
    required this.subtitle,
    required this.totalReviews,
    this.badgeText,
    required this.badgeIcon,
    this.extraInfo,
  });

  final String title;
  final String subtitle;
  final int totalReviews;
  final String? badgeText;
  final IconData badgeIcon;
  final String? extraInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          // Lokasi & ulasan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Lokasi
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$totalReviews ulasan',
                style: const TextStyle(
                  color: AppColors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Badge kategori & harga (opsional)
          if (badgeText != null || extraInfo != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (badgeText != null)
                  _InfoChip(icon: badgeIcon, label: badgeText!),
                if (badgeText != null && extraInfo != null)
                  const SizedBox(width: 8),
                if (extraInfo != null)
                  _InfoChip(icon: Icons.payments_outlined, label: extraInfo!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── State Views ────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.white54),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada hasil ditemukan',
            style: TextStyle(
              color: AppColors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba kata kunci lain',
            style: TextStyle(color: AppColors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: AppColors.white54),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.white70, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.bgColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}