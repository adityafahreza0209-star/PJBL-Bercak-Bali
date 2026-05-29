import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/custom_navbar.dart';
import '../../../widgets/navigation_controller.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../services/restaurant_service.dart';
import '../../../services/wisata_service.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _HomeHeader(controller: controller),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ── JELAJAHI KOTA ───────────────────────
                    const _SectionHeader('Jelajahi Bali'),
                    const SizedBox(height: 12),
                    _CitiesSection(controller: controller),

                    const SizedBox(height: 24),

                    // ── TERAKHIR DILIHAT ────────────────────
                    const _SectionHeader('Terakhir dilihat'),
                    const SizedBox(height: 12),
                    _RecentWisataSection(controller: controller),

                    const SizedBox(height: 24),

                    // ── DESTINASI POPULER ───────────────────
                    _SectionHeader(
                      'Destinasi paling populer',
                      trailing: Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PopularWisataSection(controller: controller),

                    const SizedBox(height: 24),

                    // ── RESTORAN TERBAIK ────────────────────
                    _SectionHeader(
                      'Restoran Terbaik di Sekitar',
                      trailing: Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TopRestaurantsSection(controller: controller),

                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final HomeController controller;
  const _HomeHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mau ke mana?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              Get.find<NavigationController>().changeTab(1);
              Get.toNamed(Routes.JELAJAHI);
            },
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(23),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search,
                    color: AppColors.primaryColor.withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cari destinasi wisata...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION: KOTA
// ─────────────────────────────────────────────────────────────────────────────

class _CitiesSection extends StatelessWidget {
  final HomeController controller;
  const _CitiesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCities.value) {
        return const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.errorCities.value != null) {
        return _ErrorRetry(
          message: controller.errorCities.value!,
          onRetry: controller.refreshAll,
        );
      }

      if (controller.cities.isEmpty) {
        return const SizedBox(
          height: 160,
          child: Center(
            child: Text('Belum ada kota.', style: TextStyle(color: Colors.white54)),
          ),
        );
      }

      return SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.cities.length,
          itemBuilder: (_, i) => _CityCard(
            city: controller.cities[i],
            onTap: () => controller.goToDestinationCity(controller.cities[i]),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION: WISATA TERAKHIR DILIHAT
// ─────────────────────────────────────────────────────────────────────────────

class _RecentWisataSection extends StatelessWidget {
  final HomeController controller;
  const _RecentWisataSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingWisata.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.recentWisata.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: controller.recentWisata
            .map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RecentWisataCard(
                    wisata: w,
                    onTap: () => controller.goToDetailWisata(w),
                  ),
                ))
            .toList(),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION: WISATA POPULER
// ─────────────────────────────────────────────────────────────────────────────

class _PopularWisataSection extends StatelessWidget {
  final HomeController controller;
  const _PopularWisataSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingWisata.value) {
        return const SizedBox(
          height: 260,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.errorWisata.value != null) {
        return _ErrorRetry(
          message: controller.errorWisata.value!,
          onRetry: controller.refreshAll,
        );
      }

      if (controller.popularWisata.isEmpty) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'Belum ada wisata populer.',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        );
      }

      return SizedBox(
        height: 260,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.popularWisata.length,
          itemBuilder: (_, i) {
            final w = controller.popularWisata[i];
            return _PopularWisataCard(
              wisata: w,
              onTap: () => controller.goToDetailWisata(w),
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION: RESTORAN
// ─────────────────────────────────────────────────────────────────────────────

class _TopRestaurantsSection extends StatelessWidget {
  final HomeController controller;
  const _TopRestaurantsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRestoran.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.errorRestoran.value != null) {
        return _ErrorRetry(
          message: controller.errorRestoran.value!,
          onRetry: controller.refreshRestaurants,
        );
      }

      if (controller.topRestaurants.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              'Belum ada restoran tersedia.',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        );
      }

      return Column(
        children: controller.topRestaurants
            .map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RestaurantCard(
                    resto: r,
                    onTap: () => controller.goToDetailRestoran(r),
                  ),
                ))
            .toList(),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _CityCard extends StatelessWidget {
  final CityModel city;
  final VoidCallback onTap;
  const _CityCard({required this.city, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gambar dari Supabase Storage
              city.imageUrl.isNotEmpty
                  ? Image.network(
                      city.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _cityFallback(),
                    )
                  : _cityFallback(),

              // Gradient gelap di bawah
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),

              // Teks nama & region
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.cityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      city.region,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cityFallback() => Container(
        color: AppColors.cardColor,
        child: const Icon(Icons.location_city, color: Colors.white54, size: 40),
      );
}

class _RecentWisataCard extends StatelessWidget {
  final WisataModel wisata;
  final VoidCallback onTap;
  const _RecentWisataCard({required this.wisata, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              wisata.imageUrl.isNotEmpty
                  ? Image.network(wisata.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _wisataFallback())
                  : _wisataFallback(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wisata.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wisata.category,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            wisata.location,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.ratingColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.white, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                wisata.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
  }

  Widget _wisataFallback() => Container(
        color: AppColors.cardColor,
        child:
            const Icon(Icons.landscape, color: Colors.white54, size: 48),
      );
}

class _PopularWisataCard extends StatelessWidget {
  final WisataModel wisata;
  final VoidCallback onTap;
  const _PopularWisataCard({required this.wisata, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: wisata.imageUrl.isNotEmpty
                        ? Image.network(wisata.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const Icon(
                                  Icons.landscape,
                                  color: Colors.white54,
                                  size: 48,
                                ))
                        : const Icon(Icons.landscape,
                            color: Colors.white54, size: 48),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      wisata.isFeatured ? 'UNGGULAN' : 'POPULER',
                      style: const TextStyle(
                        color: AppColors.cardColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              wisata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on,
                    color: AppColors.primaryColor, size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    wisata.location,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.ratingColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 10),
                      const SizedBox(width: 2),
                      Text(
                        wisata.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${wisata.totalReviews} ulasan',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantModel resto;
  final VoidCallback onTap;
  const _RestaurantCard({required this.resto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image =
        resto.images.isNotEmpty ? resto.images.first : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 80,
                height: 80,
                child: image.isNotEmpty
                    ? Image.network(image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                              color: AppColors.cardColor,
                              child: const Icon(Icons.restaurant,
                                  color: Colors.white54),
                            ))
                    : Container(
                        color: AppColors.cardColor,
                        child: const Icon(Icons.restaurant,
                            color: Colors.white54),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resto.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.ratingColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              resto.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        resto.cuisine,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.primaryColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        resto.distance,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.attach_money,
                          color: AppColors.primaryColor, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        resto.priceRange,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader(this.title, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}