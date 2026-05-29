import 'package:bercak_bali/app/services/restaurant_service.dart';
import 'package:bercak_bali/app/services/wisata_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/custom_navbar.dart';
import '../controllers/destination_city_controller.dart';

class DestinationCityView extends GetView<DestinationCityController> {
  const DestinationCityView({super.key});

  @override
  Widget build(BuildContext context) {
    return _DestinationCityBody(controller: controller);
  }
}

class _DestinationCityBody extends StatefulWidget {
  final DestinationCityController controller;
  const _DestinationCityBody({required this.controller});

  @override
  State<_DestinationCityBody> createState() => _DestinationCityBodyState();
}

class _DestinationCityBodyState extends State<_DestinationCityBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // ── HEADER GAMBAR + INFO KOTA ─────────────────────
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              floating: false,
              backgroundColor: AppColors.bgColor,
              leading: IconButton(
                onPressed: c.goBack,
                icon: const CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gambar kota dari Supabase Storage
                    c.imageUrl.isNotEmpty
                        ? Image.network(
                            c.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _cityImageFallback(),
                          )
                        : _cityImageFallback(),

                    // Gradient gelap di bawah
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),

                    // Nama & region kota
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.cityName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.region,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── TAB BAR ───────────────────────────────────────
            SliverPersistentHeader(
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryColor,
                  indicatorWeight: 3,
                  labelColor: AppColors.primaryColor,
                  unselectedLabelColor: AppColors.white70,
                  tabs: const [
                    Tab(text: 'Restoran'),
                    Tab(text: 'Wisata'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _RestaurantTab(c),
            _WisataTab(c),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 0),
    );
  }

  Widget _cityImageFallback() => Container(
        color: AppColors.cardColor,
        child: const Center(
          child: Icon(Icons.location_city, color: AppColors.white54, size: 64),
        ),
      );

  // ── TAB RESTORAN ────────────────────────────────────────────

  Widget _RestaurantTab(DestinationCityController c) {
    return Obx(() {
      if (c.isLoadingRestoran.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (c.errorRestoran.value != null) {
        return _ErrorRetry(
          message: c.errorRestoran.value!,
          onRetry: c.refreshRestaurants,
        );
      }

      if (c.restaurants.isEmpty) {
        return const Center(
          child: Text(
            'Belum ada restoran di kota ini.',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: c.restaurants.length,
        itemBuilder: (_, i) => _RestaurantCard(
          resto: c.restaurants[i],
          onTap: () => c.goToDetailRestoran(c.restaurants[i]),
        ),
      );
    });
  }

  // ── TAB WISATA ───────────────────────────────────────────────

  Widget _WisataTab(DestinationCityController c) {
    return Obx(() {
      if (c.isLoadingWisata.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (c.errorWisata.value != null) {
        return _ErrorRetry(
          message: c.errorWisata.value!,
          onRetry: c.refreshWisata,
        );
      }

      if (c.wisataList.isEmpty) {
        return const Center(
          child: Text(
            'Belum ada wisata di kota ini.',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: c.wisataList.length,
        itemBuilder: (_, i) => _WisataCard(
          wisata: c.wisataList[i],
          onTap: () => c.goToDetailWisata(c.wisataList[i]),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD: RESTORAN
// ─────────────────────────────────────────────────────────────────────────────

class _RestaurantCard extends StatelessWidget {
  final RestaurantModel resto;
  final VoidCallback onTap;
  const _RestaurantCard({required this.resto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = resto.images.isNotEmpty ? resto.images.first : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
                        errorBuilder: (_, __, ___) => _imageFallback(
                            Icons.restaurant))
                    : _imageFallback(Icons.restaurant),
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
                      _RatingBadge(rating: resto.rating.toStringAsFixed(1)),
                      const SizedBox(width: 6),
                      Text(
                        '${resto.totalReviews} ulasan',
                        style: const TextStyle(
                            color: AppColors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${resto.priceRange} • ${resto.cuisine}',
                    style: const TextStyle(
                        color: AppColors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.primaryColor, size: 11),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          resto.location,
                          style: const TextStyle(
                              color: AppColors.white54, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD: WISATA
// ─────────────────────────────────────────────────────────────────────────────

class _WisataCard extends StatelessWidget {
  final WisataModel wisata;
  final VoidCallback onTap;
  const _WisataCard({required this.wisata, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
                child: wisata.imageUrl.isNotEmpty
                    ? Image.network(wisata.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _imageFallback(Icons.landscape))
                    : _imageFallback(Icons.landscape),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wisata.title,
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
                      _RatingBadge(
                          rating: wisata.rating.toStringAsFixed(1)),
                      const SizedBox(width: 6),
                      Text(
                        '${wisata.totalReviews} ulasan',
                        style: const TextStyle(
                            color: AppColors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wisata.location,
                    style: const TextStyle(
                        color: AppColors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          color: AppColors.primaryColor, size: 11),
                      const SizedBox(width: 2),
                      Text(
                        wisata.ticketPrice,
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time,
                          color: AppColors.white54, size: 11),
                      const SizedBox(width: 2),
                      Text(
                        wisata.duration,
                        style: const TextStyle(
                            color: AppColors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

Widget _imageFallback(IconData icon) => Container(
      color: AppColors.cardColor,
      child: Icon(icon, color: Colors.white54, size: 32),
    );

class _RatingBadge extends StatelessWidget {
  final String rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.ratingColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.white, size: 10),
          const SizedBox(width: 2),
          Text(
            rating,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STICKY TAB BAR DELEGATE
// ─────────────────────────────────────────────────────────────────────────────

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _StickyTabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.bgColor, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) => false;
}