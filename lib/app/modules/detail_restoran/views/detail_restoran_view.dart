import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/maps_helper.dart';
import '../../../widgets/shimmer_skeleton.dart';
import '../../../services/restaurant_service.dart';
import '../../../services/review_service.dart';
import '../controllers/detail_restoran_controller.dart';
import '../../../../app/routes/app_pages.dart';

const _kHeroHeight = 300.0;
const _kTabBarHeight = 48.0;

class DetailRestoranView extends GetView<DetailRestoranController> {
  const DetailRestoranView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── Loading awal ─────────────────────────────────────────
      if (controller.isLoading.value) {
        return const _DetailRestoranSkeletonPage();
      }

      // ── Error ────────────────────────────────────────────────
      if (controller.errorMessage.value != null) {
        return Scaffold(
          backgroundColor: AppColors.bgColor,
          appBar: AppBar(
            backgroundColor: AppColors.bgColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: controller.goBack,
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_outlined,
                    color: AppColors.white54,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.refresh,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // ── Konten utama ─────────────────────────────────────────
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppColors.bgColor,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _HeroSliverAppBar(controller: controller),
              _InfoSliverSection(controller: controller),
              _ActionButtonsSliver(controller: controller),
              const _StickyTabBarSliver(tabs: ['Informasi', 'Menu', 'Ulasan']),
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
    });
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
        Obx(
          () => Padding(
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
          ),
        ),
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
              child: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 20,
              ),
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
    final images = controller.images;

    if (images.isEmpty) {
      return Container(
        color: AppColors.cardColor,
        child: const Icon(Icons.restaurant, color: AppColors.white54, size: 64),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: controller.onPageChanged,
          itemBuilder: (_, i) => Image.network(
            images[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.cardColor,
              child: const Icon(
                Icons.restaurant,
                color: AppColors.white54,
                size: 64,
              ),
            ),
          ),
        ),
        // Gradient bawah
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
        ),
        // Indikator halaman
        if (images.length > 1)
          Obx(
            () => Positioned(
              bottom: 14,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.currentImage.value + 1} / ${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
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
              controller.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            // FIX: Obx di sini telah dihapus karena variabel rating bukan bertipe .obs
            // dan pembaruan UI komponen ini sudah terjamin aman oleh Obx di tingkat build utama.
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
                  '(${controller.totalUlasan} ulasan)',
                  style: const TextStyle(
                    color: AppColors.white54,
                    fontSize: 13,
                  ),
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
                const Icon(
                  Icons.location_on,
                  color: AppColors.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    [
                      if (controller.distance.isNotEmpty) controller.distance,
                      if (controller.location.isNotEmpty) controller.location,
                    ].join(' · '),
                    style: const TextStyle(
                      color: AppColors.white70,
                      fontSize: 13,
                    ),
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
              onTap: controller.openGoogleMaps,
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
            Obx(
              () => _ActionButton(
                icon: controller.isFavorite.value
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                label: 'Simpan',
                onTap: controller.toggleFavorite,
                active: controller.isFavorite.value,
              ),
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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: TabBar(
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.white54,
        indicatorColor: AppColors.primaryColor,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. TAB INFORMASI
// ─────────────────────────────────────────────────────────────────────────────

class _InformasiTab extends StatelessWidget {
  final DetailRestoranController controller;
  const _InformasiTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const _SectionLabel('Deskripsi'),
        const SizedBox(height: 10),
        Text(
          controller.description.isNotEmpty
              ? controller.description
              : 'Nikmati hidangan autentik Bali dengan cita rasa tradisional '
                    'yang kaya rempah.',
          style: const TextStyle(
            color: AppColors.white70,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Info Operasional'),
        const SizedBox(height: 10),
        _InfoCard(
          children: [
            const _InfoRow(
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
                  : '-',
            ),
            const SizedBox(height: 12),
            const _InfoRow(
              icon: Icons.people_outline,
              label: 'Kapasitas',
              value: '50 – 100 kursi',
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Kontak'),
        const SizedBox(height: 10),
        _InfoCard(
          children: [
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Telepon',
              value: controller.phoneNumber.isNotEmpty
                  ? controller.phoneNumber
                  : '-',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Alamat',
              value: controller.location.isNotEmpty
                  ? controller.location
                  : 'Bali, Indonesia',
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Fasilitas'),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FacilityChip(icon: Icons.wifi, label: 'WiFi Gratis'),
            _FacilityChip(icon: Icons.ac_unit, label: 'AC'),
            _FacilityChip(icon: Icons.local_parking, label: 'Parkir Luas'),
            _FacilityChip(icon: Icons.credit_card, label: 'Kartu Kredit'),
            _FacilityChip(icon: Icons.smoking_rooms, label: 'Area Merokok'),
            _FacilityChip(
              icon: Icons.wheelchair_pickup,
              label: 'Akses Disabilitas',
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Lokasi'),
        const SizedBox(height: 10),
        MapsPreviewTile(
          address: controller.location.isNotEmpty
              ? controller.location
              : 'Bali, Indonesia',
          onTap: controller.openGoogleMaps,
          hasLink: controller.hasGoogleMapsUrl,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. TAB MENU
// ─────────────────────────────────────────────────────────────────────────────

class _MenuTab extends StatelessWidget {
  final DetailRestoranController controller;
  const _MenuTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMenu.value) {
        return const _MenuSkeletonList();
      }

      if (controller.menuItems.isEmpty) {
        return const Center(
          child: Text(
            'Menu belum tersedia.',
            style: TextStyle(color: AppColors.white54),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          if (controller.menuMakanan.isNotEmpty) ...[
            const _SectionLabel('Makanan'),
            const SizedBox(height: 12),
            ...controller.menuMakanan.map((item) => _MenuItem(item: item)),
            const SizedBox(height: 24),
          ],
          if (controller.menuMinuman.isNotEmpty) ...[
            const _SectionLabel('Minuman'),
            const SizedBox(height: 12),
            ...controller.menuMinuman.map((item) => _MenuItem(item: item)),
          ],
        ],
      );
    });
  }
}

class _MenuItem extends StatelessWidget {
  final MenuItemModel item;
  const _MenuItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              item.category == 'Makanan'
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
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
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
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.price ?? '-',
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
// 7. TAB ULASAN
// ─────────────────────────────────────────────────────────────────────────────

class _UlasanTab extends StatelessWidget {
  final DetailRestoranController controller;
  const _UlasanTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          // ── Ringkasan rating (dinamis dari Supabase) ──────
          _RatingSummaryCard(
            ratingValue: controller.rating,
            totalUlasan: controller.totalUlasan,
            actualReviewCount: controller.actualReviewCount,
            ratingCounts: controller.ratingCounts,
          ),
          const SizedBox(height: 20),

          // ── Tombol tulis ulasan ───────────────────────────
          _WriteReviewButton(onTap: controller.goToWriteReview),
          const SizedBox(height: 16),

          const _SectionLabel('Ulasan Pengunjung'),
          const SizedBox(height: 12),

          // ── Loading ───────────────────────────────────────
          if (controller.isLoadingReviews.value)
            const _ReviewSkeletonList()
          else if (controller.reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada ulasan. Jadilah yang pertama!',
                  style: TextStyle(color: AppColors.white54),
                ),
              ),
            )
          else
            ...controller.reviews.map(
              (review) => Obx(
                () => _ReviewCard(
                  review: review,
                  isUseful: controller.userUseful[review.id] ?? false,
                  usefulCount: controller.usefulCounts[review.id] ?? 0,
                  onUsefulTap: () => controller.toggleUseful(review.id),
                ),
              ),
            ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVIEW CARD — pakai ReviewModel, nama bisa diklik ke user profile
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isUseful;
  final int usefulCount;
  final VoidCallback onUsefulTap;

  const _ReviewCard({
    required this.review,
    required this.isUseful,
    required this.usefulCount,
    required this.onUsefulTap,
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
          // ── Header: avatar + nama + tanggal + bintang ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              review.userAvatarUrl != null
                  ? CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(review.userAvatarUrl!),
                      backgroundColor: AppColors.cardColor,
                    )
                  : CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.85),
                      child: Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          color: AppColors.bgColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama — bisa diklik ke halaman profil
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        Routes.USER_PROFILE,
                        arguments: {'userId': review.userId},
                      ),
                      child: Text(
                        review.userName,
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.dateFormatted,
                      style: const TextStyle(
                        color: AppColors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Bintang
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: i < review.rating
                        ? AppColors.ratingColor
                        : Colors.white24,
                  ),
                ),
              ),
            ],
          ),

          // ── Judul ulasan (jika ada) ─────────────────────
          if (review.title != null && review.title!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          // ── Komentar ────────────────────────────────────
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(
                color: AppColors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],

          // ── Foto lampiran ────────────────────────────────
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 86,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.imageUrls.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      review.imageUrls[i],
                      width: 78,
                      height: 78,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 78,
                        height: 78,
                        color: AppColors.bgColor,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppColors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // ── Tombol Berguna ──────────────────────────────
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 14,
                    color: isUseful
                        ? AppColors.primaryColor
                        : AppColors.white54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    usefulCount > 0 ? '$usefulCount Berguna' : 'Berguna',
                    style: TextStyle(
                      color: isUseful
                          ? AppColors.primaryColor
                          : AppColors.white54,
                      fontSize: 12,
                      fontWeight: isUseful
                          ? FontWeight.w600
                          : FontWeight.normal,
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
// RATING SUMMARY CARD — dinamis dari Supabase
// ─────────────────────────────────────────────────────────────────────────────

class _RatingSummaryCard extends StatelessWidget {
  final String ratingValue;
  final int totalUlasan;
  final int actualReviewCount;
  final Map<int, int> ratingCounts;
  const _RatingSummaryCard({
    required this.ratingValue,
    required this.totalUlasan,
    required this.actualReviewCount,
    required this.ratingCounts,
  });

  @override
  Widget build(BuildContext context) {
    final r = double.tryParse(ratingValue) ?? 0;

    final bars = [
      for (var star = 5; star >= 1; star--)
        (
          star: star,
          count: ratingCounts[star] ?? 0,
          percent: actualReviewCount == 0
              ? 0.0
              : (ratingCounts[star] ?? 0) / actualReviewCount,
        ),
    ];

    String label;
    if (r >= 4.5)
      label = 'Luar Biasa';
    else if (r >= 4.0)
      label = 'Sangat Bagus';
    else if (r >= 3.0)
      label = 'Bagus';
    else
      label = 'Biasa';

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
                  child: Text(
                    ratingValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$totalUlasan ulasan',
                style: const TextStyle(color: AppColors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: bars
                  .map(
                    (b) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 26,
                            child: Text(
                              '${b.star} ★',
                              style: const TextStyle(
                                color: AppColors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: b.percent,
                                backgroundColor: Colors.white12,
                                color: AppColors.ratingColor,
                                minHeight: 7,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${b.count}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: AppColors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _WriteReviewButton extends StatelessWidget {
  final VoidCallback onTap;
  const _WriteReviewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      child: Text(
        rating,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
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
          color: AppColors.primaryColor.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
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
              color: active
                  ? AppColors.primaryColor.withOpacity(0.15)
                  : AppColors.cardColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? AppColors.primaryColor
                    : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.primaryColor : Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColors.primaryColor : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
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
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    );
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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
              Text(
                label,
                style: const TextStyle(color: AppColors.white54, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DetailRestoranSkeletonPage extends StatelessWidget {
  const _DetailRestoranSkeletonPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [
          _DetailSkeletonHero(),
          _DetailSkeletonInfo(),
          _DetailSkeletonActions(actionCount: 4),
          _DetailSkeletonTabBar(tabCount: 3),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 130, height: 18, borderRadius: 6),
                  SizedBox(height: 12),
                  _DetailInfoCardSkeleton(),
                  SizedBox(height: 20),
                  ShimmerBox(width: 90, height: 18, borderRadius: 6),
                  SizedBox(height: 12),
                  _DetailInfoCardSkeleton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSkeletonHero extends StatelessWidget {
  const _DetailSkeletonHero();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          const ShimmerBox(height: _kHeroHeight, borderRadius: 0),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: const ShimmerBox(width: 38, height: 38, borderRadius: 19),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 58,
            child: const ShimmerBox(width: 38, height: 38, borderRadius: 19),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: const ShimmerBox(width: 38, height: 38, borderRadius: 19),
          ),
        ],
      ),
    );
  }
}

class _DetailSkeletonInfo extends StatelessWidget {
  const _DetailSkeletonInfo();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.bgColor,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(
              width: double.infinity,
              height: 26,
              borderRadius: 6,
            ),
            const SizedBox(height: 10),
            const ShimmerBox(width: 220, height: 20, borderRadius: 6),
            const SizedBox(height: 12),
            Row(
              children: const [
                ShimmerBox(width: 42, height: 26, borderRadius: 6),
                SizedBox(width: 8),
                ShimmerBox(width: 96, height: 16, borderRadius: 6),
                SizedBox(width: 8),
                ShimmerBox(width: 74, height: 14, borderRadius: 6),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                ShimmerBox(width: 104, height: 24, borderRadius: 20),
                SizedBox(width: 8),
                ShimmerBox(width: 72, height: 24, borderRadius: 20),
              ],
            ),
            const SizedBox(height: 12),
            const ShimmerBox(
              width: double.infinity,
              height: 14,
              borderRadius: 6,
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.08), height: 1),
          ],
        ),
      ),
    );
  }
}

class _DetailSkeletonActions extends StatelessWidget {
  final int actionCount;
  const _DetailSkeletonActions({required this.actionCount});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            actionCount,
            (_) => const Column(
              children: [
                ShimmerBox(width: 52, height: 52, borderRadius: 26),
                SizedBox(height: 8),
                ShimmerBox(width: 46, height: 11, borderRadius: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSkeletonTabBar extends StatelessWidget {
  final int tabCount;
  const _DetailSkeletonTabBar({required this.tabCount});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: _kTabBarHeight,
        decoration: BoxDecoration(
          color: AppColors.bgColor,
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
        ),
        child: Row(
          children: List.generate(
            tabCount,
            (_) => const Expanded(
              child: Center(
                child: ShimmerBox(width: 82, height: 14, borderRadius: 6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailInfoCardSkeleton extends StatelessWidget {
  const _DetailInfoCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
          SizedBox(height: 10),
          ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
          SizedBox(height: 10),
          ShimmerBox(width: 180, height: 14, borderRadius: 6),
        ],
      ),
    );
  }
}

class _MenuSkeletonList extends StatelessWidget {
  const _MenuSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        ShimmerBox(width: 90, height: 18, borderRadius: 6),
        SizedBox(height: 12),
        _MenuSkeletonItem(),
        _MenuSkeletonItem(),
        _MenuSkeletonItem(),
        SizedBox(height: 18),
        ShimmerBox(width: 90, height: 18, borderRadius: 6),
        SizedBox(height: 12),
        _MenuSkeletonItem(),
        _MenuSkeletonItem(),
      ],
    );
  }
}

class _MenuSkeletonItem extends StatelessWidget {
  const _MenuSkeletonItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          ShimmerBox(width: 52, height: 52, borderRadius: 10),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 15, borderRadius: 6),
                SizedBox(height: 8),
                ShimmerBox(width: 96, height: 14, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSkeletonList extends StatelessWidget {
  const _ReviewSkeletonList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ReviewSkeletonCard(),
        _ReviewSkeletonCard(),
        _ReviewSkeletonCard(),
      ],
    );
  }
}

class _ReviewSkeletonCard extends StatelessWidget {
  const _ReviewSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 36, height: 36, borderRadius: 18),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 14, borderRadius: 6),
                    SizedBox(height: 6),
                    ShimmerBox(width: 84, height: 11, borderRadius: 6),
                  ],
                ),
              ),
              ShimmerBox(width: 74, height: 13, borderRadius: 6),
            ],
          ),
          SizedBox(height: 14),
          ShimmerBox(width: double.infinity, height: 13, borderRadius: 6),
          SizedBox(height: 8),
          ShimmerBox(width: double.infinity, height: 13, borderRadius: 6),
          SizedBox(height: 8),
          ShimmerBox(width: 190, height: 13, borderRadius: 6),
          SizedBox(height: 14),
          ShimmerBox(width: 88, height: 28, borderRadius: 20),
        ],
      ),
    );
  }
}
