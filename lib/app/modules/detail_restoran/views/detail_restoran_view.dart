import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/maps_helper.dart';
import '../controllers/detail_restoran_controller.dart';
import '../../../../app/routes/app_pages.dart';

const _kHeroHeight   = 300.0;
const _kTabBarHeight = 48.0;

class DetailRestoranView extends GetView<DetailRestoranController> {
  const DetailRestoranView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _HeroSliverAppBar(controller: controller),
            _InfoSliverSection(controller: controller),
            _ActionButtonsSliver(controller: controller),
            const _StickyTabBarSliver(
              tabs: ['Informasi', 'Menu', 'Ulasan'],
            ),
          ],
          body: TabBarView(
            children: [
              _InformasiTab(controller: controller),
              _MenuTab(controller: controller),
              _UlasanTab(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. HERO SLIVER APP BAR
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSliverAppBar extends StatelessWidget {
  final DetailRestoranController controller;
  const _HeroSliverAppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: _kHeroHeight,
      pinned: true,
      backgroundColor: AppColors.bgColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: controller.goBack,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
      ),
      actions: [
        Obx(() => Padding(
              padding: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
              child: GestureDetector(
                onTap: controller.toggleFavorite,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.isFavorite.value
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: controller.isFavorite.value
                        ? AppColors.primaryColor
                        : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            )),
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: controller.sharePlace,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.share_outlined, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _HeroImageCarousel(controller: controller),
      ),
    );
  }
}

class _HeroImageCarousel extends StatelessWidget {
  final DetailRestoranController controller;
  const _HeroImageCarousel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: controller.images.length,
          onPageChanged: controller.onPageChanged,
          itemBuilder: (_, i) => Image.asset(
            controller.images[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.cardColor,
              child: const Icon(Icons.restaurant,
                  color: AppColors.white54, size: 64),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
        ),
        Obx(() => Positioned(
              bottom: 14,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.currentImage.value + 1} / ${controller.images.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. INFO SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _InfoSliverSection extends StatelessWidget {
  final DetailRestoranController controller;
  const _InfoSliverSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.bgColor,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.name.isNotEmpty ? controller.name : 'Restoran',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _RatingBadge(rating: controller.rating),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(5, (i) {
                    final r = double.tryParse(controller.rating) ?? 0;
                    return Icon(
                      i < r.floor()
                          ? Icons.star
                          : (i < r ? Icons.star_half : Icons.star_border),
                      color: AppColors.ratingColor,
                      size: 15,
                    );
                  }),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${controller.reviews.length} ulasan)',
                  style: const TextStyle(
                      color: AppColors.white54, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (controller.cuisine.isNotEmpty)
                  _CategoryBadge(label: controller.cuisine),
                if (controller.cuisine.isNotEmpty) const SizedBox(width: 8),
                if (controller.priceRange.isNotEmpty)
                  _CategoryBadge(label: controller.priceRange),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on,
                    color: AppColors.primaryColor, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    [
                      if (controller.distance.isNotEmpty) controller.distance,
                      if (controller.location.isNotEmpty) controller.location,
                    ].join(' · '),
                    style: const TextStyle(
                        color: AppColors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.08), height: 1),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. ACTION BUTTONS
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButtonsSliver extends StatelessWidget {
  final DetailRestoranController controller;
  const _ActionButtonsSliver({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ActionButton(
              icon: Icons.directions,
              label: 'Rute',
              onTap: () => controller.openGoogleMaps(
                  controller.dummyLat, controller.dummyLng),
            ),
            _ActionButton(
              icon: Icons.phone_outlined,
              label: 'Telepon',
              onTap: controller.callRestoran,
            ),
            _ActionButton(
              icon: Icons.share_outlined,
              label: 'Bagikan',
              onTap: controller.sharePlace,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. STICKY TAB BAR
// ─────────────────────────────────────────────────────────────────────────────
class _StickyTabBarSliver extends StatelessWidget {
  final List<String> tabs;
  const _StickyTabBarSliver({required this.tabs});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(tabs: tabs),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final List<String> tabs;
  const _TabBarDelegate({required this.tabs});

  @override
  double get minExtent => _kTabBarHeight;
  @override
  double get maxExtent => _kTabBarHeight;

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.tabs != tabs;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: TabBar(
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.white54,
        indicatorColor: AppColors.primaryColor,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal, fontSize: 14),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. TAB 1 — INFORMASI
// ─────────────────────────────────────────────────────────────────────────────
class _InformasiTab extends StatelessWidget {
  final DetailRestoranController controller;
  const _InformasiTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _SectionLabel('Deskripsi'),
        const SizedBox(height: 10),
        Text(
          controller.description.isNotEmpty
              ? controller.description
              : 'Nikmati hidangan autentik Bali dengan cita rasa tradisional '
                  'yang kaya rempah. Restoran ini menawarkan suasana nyaman '
                  'dan pelayanan ramah untuk pengalaman kuliner yang tak terlupakan.',
          style: const TextStyle(
              color: AppColors.white70, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 24),
        _SectionLabel('Info Operasional'),
        const SizedBox(height: 10),
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.access_time,
            label: 'Jam Buka',
            value: '10:00 – 22:00 (Setiap hari)',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.attach_money,
            label: 'Kisaran Harga',
            value: controller.priceRange.isNotEmpty
                ? controller.priceRange
                : 'Rp 50.000 – Rp 150.000 / orang',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.people_outline,
            label: 'Kapasitas',
            value: '50 – 100 kursi',
          ),
        ]),
        const SizedBox(height: 24),
        _SectionLabel('Kontak'),
        const SizedBox(height: 10),
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Telepon',
            value: controller.phoneNumber,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            value: controller.location.isNotEmpty
                ? controller.location
                : 'Bali, Indonesia',
          ),
        ]),
        const SizedBox(height: 24),
        _SectionLabel('Fasilitas'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _FacilityChip(icon: Icons.wifi,            label: 'WiFi Gratis'),
            _FacilityChip(icon: Icons.ac_unit,         label: 'AC'),
            _FacilityChip(icon: Icons.local_parking,   label: 'Parkir Luas'),
            _FacilityChip(icon: Icons.credit_card,     label: 'Kartu Kredit'),
            _FacilityChip(icon: Icons.smoking_rooms,   label: 'Area Merokok'),
            _FacilityChip(icon: Icons.wheelchair_pickup, label: 'Akses Disabilitas'),
          ],
        ),
        const SizedBox(height: 24),
        _SectionLabel('Lokasi'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => controller.openGoogleMaps(
              controller.dummyLat, controller.dummyLng),
          child: MapsPreviewTile(
            location: controller.name,
            address: controller.location.isNotEmpty
                ? controller.location
                : 'Bali, Indonesia',
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. TAB 2 — MENU
// ─────────────────────────────────────────────────────────────────────────────
class _MenuTab extends StatelessWidget {
  final DetailRestoranController controller;
  const _MenuTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        _SectionLabel('Makanan'),
        const SizedBox(height: 12),
        ...controller.menuMakanan.map((item) => _MenuItem(item: item)),
        const SizedBox(height: 24),
        _SectionLabel('Minuman'),
        const SizedBox(height: 12),
        ...controller.menuMinuman.map((item) => _MenuItem(item: item)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const _MenuItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item['category'] == 'Makanan'
                  ? Icons.restaurant_menu
                  : Icons.local_cafe,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item['popular'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.ratingColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'POPULER',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['price'],
                  style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
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
// 7. TAB 3 — ULASAN (dengan tombol berguna)
// ─────────────────────────────────────────────────────────────────────────────
class _UlasanTab extends StatelessWidget {
  final DetailRestoranController controller;
  const _UlasanTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _RatingSummaryCard(
          ratingValue: controller.rating,
          label: 'Sangat Baik',
          totalUlasan: controller.reviews.length,
          rows: const [
            _RatingBarData(star: '5', percent: 0.70, total: 3),
            _RatingBarData(star: '4', percent: 0.20, total: 1),
            _RatingBarData(star: '3', percent: 0.10, total: 1),
            _RatingBarData(star: '2', percent: 0.00, total: 0),
            _RatingBarData(star: '1', percent: 0.00, total: 0),
          ],
        ),
        const SizedBox(height: 20),
        
        // Tombol Tulis Ulasan
        _buildWriteReviewButton(),
        const SizedBox(height: 16),
        
        _SectionLabel('Ulasan Pengunjung'),
        const SizedBox(height: 12),
        
        // List review dengan tombol berguna
        ...controller.reviews.asMap().entries.map((entry) {
          final index = entry.key;
          final review = entry.value;
          return Obx(() => _ReviewCard(
            review: review,
            index: index,
            onUsefulTap: () => controller.toggleUseful(index),
            isUseful: controller.userUseful[index] ?? false,
            usefulCount: controller.usefulCounts[index] ?? 0,
          ));
        }).toList(),
      ],
    );
  }

  Widget _buildWriteReviewButton() {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.WRITE_REVIEW, arguments: {
          'placeId': controller.name,
          'placeName': controller.name,
          'placeType': 'restoran',
          'placeImage': controller.images.isNotEmpty 
              ? controller.images[0] 
              : 'assets/images/restoran1.jpg',
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryColor, Color(0xFFC88D4A)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Tulis Ulasan',
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: 15
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== REVIEW CARD DENGAN TOMBOL BERGUNA ====================
class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final int index;
  final VoidCallback? onUsefulTap;
  final bool isUseful;
  final int usefulCount;

  const _ReviewCard({
    required this.review,
    required this.index,
    this.onUsefulTap,
    this.isUseful = false,
    this.usefulCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryColor.withOpacity(0.85),
                child: Text(
                  (review['name'] as String)[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.bgColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama USER BISA DIKLIK ke profil
                    GestureDetector(
                      onTap: () {
                        final userId = review['userId'] ?? 'user_unknown';
                        Get.toNamed(Routes.USER_PROFILE, arguments: {'userId': userId});
                      },
                      child: Text(
                        review['name'],
                        style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                    Text(review['date'],
                        style: const TextStyle(
                            color: AppColors.white54, fontSize: 11)),
                  ],
                ),
              ),
              // Rating bintang
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 13,
                    color: i < (review['rating'] as int)
                        ? AppColors.ratingColor
                        : Colors.white24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Isi komentar
          Text(
            review['comment'],
            style: const TextStyle(
                color: AppColors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 10),
          // TOMBOL BERGUNA (THUMBS UP)
          Row(
            children: [
              GestureDetector(
                onTap: onUsefulTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUseful
                        ? AppColors.primaryColor.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUseful
                          ? AppColors.primaryColor
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up_outlined,
                        size: 14,
                        color: isUseful ? AppColors.primaryColor : AppColors.white54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        usefulCount > 0 ? '$usefulCount' : 'Berguna',
                        style: TextStyle(
                          color: isUseful ? AppColors.primaryColor : AppColors.white54,
                          fontSize: 12,
                          fontWeight: isUseful ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== SHARED SMALL WIDGETS ====================
class _RatingBadge extends StatelessWidget {
  final String rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.ratingColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(rating,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.35), width: 1),
      ),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.1), width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2));
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.white54, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FacilityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FacilityChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(color: AppColors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RatingBarData {
  final String star;
  final double percent;
  final int total;
  const _RatingBarData(
      {required this.star, required this.percent, required this.total});
}

class _RatingSummaryCard extends StatelessWidget {
  final String ratingValue;
  final String label;
  final int totalUlasan;
  final List<_RatingBarData> rows;
  const _RatingSummaryCard({
    required this.ratingValue,
    required this.label,
    required this.totalUlasan,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.ratingColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(ratingValue,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              Text('$totalUlasan ulasan',
                  style: const TextStyle(
                      color: AppColors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: rows
                  .map((r) => _RatingBarRow(
                      star: r.star, percent: r.percent, total: r.total))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBarRow extends StatelessWidget {
  final String star;
  final double percent;
  final int total;
  const _RatingBarRow(
      {required this.star, required this.percent, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text('$star ★',
                style: const TextStyle(
                    color: AppColors.white54, fontSize: 11)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.white12,
                color: AppColors.ratingColor,
                minHeight: 7,
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 26,
            child: Text(total.toString(),
                textAlign: TextAlign.end,
                style: const TextStyle(
                    color: AppColors.white54, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}