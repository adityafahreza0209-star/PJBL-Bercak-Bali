import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/custom_navbar.dart';
import '../../../widgets/maps_helper.dart';
import '../controllers/destination_city_controller.dart';

class DestinationCityView extends GetView<DestinationCityController> {
  const DestinationCityView({super.key});

  @override
  Widget build(BuildContext context) {
    return _DestinationCityBody(controller: controller);
  }
}

// Body pakai StatefulWidget untuk TabController
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
            // HEADER GAMBAR + INFO KOTA
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
                    Image.asset(
                      c.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardColor,
                        child: const Center(
                          child: Icon(Icons.location_city,
                              color: AppColors.white54, size: 64),
                        ),
                      ),
                    ),
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
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.cityName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(c.region,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // TAB BAR
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
            _buildRestaurantTab(c),
            _buildAttractionTab(c),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 0),
    );
  }

  // ================= TAB RESTORAN =================
  Widget _buildRestaurantTab(DestinationCityController c) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DESKRIPSI KOTA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.cityName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(c.description,
                    style: const TextStyle(
                        color: AppColors.white70, fontSize: 14, height: 1.5)),
                const SizedBox(height: 12),
                const Text('Selengkapnya',
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // HEADER RESTORAN
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Restoran',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                      'Semua tempat yang hidangannya terbukti enak',
                      style:
                          TextStyle(color: AppColors.white54, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Text('Lihat semua',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),

          // LIST RESTORAN
          ...c.recommendedRestaurants
              .map((resto) => _restaurantCard(resto, c))
              .toList(),

          const SizedBox(height: 24),
          const Text('Peta',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          MapsPreviewTile(
            location: c.cityName,
            address: '${c.cityName}, ${c.region}, Bali',
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= TAB WISATA =================
  Widget _buildAttractionTab(DestinationCityController c) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hal yang dapat dilakukan',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Tempat wisata terbaik di ${c.cityName}',
              style:
                  const TextStyle(color: AppColors.white54, fontSize: 12)),
          const SizedBox(height: 20),

          ...c.recommendedAttractions
              .map((wisata) => _attractionCard(wisata, c))
              .toList(),

          const SizedBox(height: 24),
          _cityStats(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= STATISTIK KOTA =================
  Widget _cityStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(Icons.restaurant, 'Restoran', '120+',
                  AppColors.primaryColor),
              _statItem(Icons.place, 'Wisata', '45', AppColors.ratingColor),
              _statItem(Icons.hotel, 'Hotel', '80+', Colors.blue),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.white54),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(Icons.star, 'Rating', '4.6', Colors.amber),
              _statItem(Icons.access_time, 'Jam Buka', '08:00-20:00',
                  AppColors.primaryColor),
              _statItem(Icons.attach_money, 'Tiket', 'Rp 15-50k',
                  AppColors.ratingColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(color: AppColors.white54, fontSize: 11)),
      ],
    );
  }

  // ================= RESTORAN CARD =================
  Widget _restaurantCard(
      Map<String, dynamic> resto, DestinationCityController c) {
    return GestureDetector(
      onTap: () => c.goToDetailRestoran(resto),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(resto['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resto['name'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
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
                            Text(resto['rating'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('${resto['reviews']} ulasan',
                          style: const TextStyle(
                              color: AppColors.white54, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${resto['price']} • ${resto['cuisine']}',
                      style: const TextStyle(
                          color: AppColors.white70, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.primaryColor, size: 11),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(resto['location'],
                            style: const TextStyle(
                                color: AppColors.white54, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
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

  // ================= WISATA CARD =================
  Widget _attractionCard(
      Map<String, dynamic> wisata, DestinationCityController c) {
    return GestureDetector(
      onTap: () => c.goToDetailWisata(wisata),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(wisata['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wisata['name'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
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
                            Text(wisata['rating'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('(${wisata['reviews']})',
                          style: const TextStyle(
                              color: AppColors.white54, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(wisata['location'],
                      style: const TextStyle(
                          color: AppColors.white70, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          color: AppColors.primaryColor, size: 11),
                      const SizedBox(width: 2),
                      Text(wisata['price'],
                          style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time,
                          color: AppColors.white54, size: 11),
                      const SizedBox(width: 2),
                      const Text('2-3 jam',
                          style: TextStyle(
                              color: AppColors.white54, fontSize: 11)),
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

// ================= STICKY TAB BAR DELEGATE =================
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
