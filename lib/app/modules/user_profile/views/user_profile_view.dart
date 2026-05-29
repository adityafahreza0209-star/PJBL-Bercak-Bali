import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../services/review_service.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Obx(() {
        // ── Loading awal ───────────────────────────────────────
        if (controller.isLoadingProfile.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // ── Error ──────────────────────────────────────────────
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
                    const Icon(Icons.person_off_outlined,
                        color: AppColors.white54, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: controller.refresh,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final p = controller.profile.value!;

        // ── Konten utama ───────────────────────────────────────
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _ProfileSliverAppBar(
              profile: p,
              onBack: controller.goBack,
            ),
          ],
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            color: AppColors.primaryColor,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                // ── Info detail ──────────────────────────────
                _InfoSection(profile: p),
                const SizedBox(height: 20),

                // ── Statistik ────────────────────────────────
                Obx(() => _StatsCard(
                      reviewCount: controller.reviews.length,
                    )),
                const SizedBox(height: 24),

                // ── Riwayat ulasan ───────────────────────────
                const _SectionLabel('Riwayat Ulasan'),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.isLoadingReviews.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (controller.reviews.isEmpty) {
                    return _EmptyReviews();
                  }
                  return Column(
                    children: controller.reviews
                        .map((r) => _ReviewHistoryCard(review: r))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SLIVER APP BAR (foto profil + nama + lokasi)
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileSliverAppBar extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback onBack;
  const _ProfileSliverAppBar({required this.profile, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.bgColor,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: onBack,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1C2E3A), AppColors.bgColor],
                ),
              ),
            ),

            // Konten: avatar + nama + lokasi
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Avatar
                  profile.avatarUrl != null
                      ? CircleAvatar(
                          radius: 48,
                          backgroundImage:
                              NetworkImage(profile.avatarUrl!),
                          backgroundColor: AppColors.cardColor,
                        )
                      : CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.primaryColor,
                          child: Text(
                            profile.initial,
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: AppColors.bgColor,
                            ),
                          ),
                        ),
                  const SizedBox(height: 14),

                  // Nama
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Lokasi
                  if (profile.location != null &&
                      profile.location!.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on,
                            size: 13, color: AppColors.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          profile.location!,
                          style: const TextStyle(
                              color: AppColors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),

                  // Tanggal bergabung
                  Text(
                    'Bergabung ${profile.memberSince}',
                    style: const TextStyle(
                        color: AppColors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION INFO (bio + sosmed)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final UserProfileModel profile;
  const _InfoSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasBio = profile.bio != null && profile.bio!.isNotEmpty;
    final hasSosmed =
        profile.socialMedia != null && profile.socialMedia!.isNotEmpty;

    if (!hasBio && !hasSosmed) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          if (hasBio) ...[
            const _FieldLabel('Bio'),
            const SizedBox(height: 6),
            Text(
              profile.bio!,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.55),
            ),
            if (hasSosmed) const SizedBox(height: 14),
          ],

          // Sosial media
          if (hasSosmed) ...[
            const _FieldLabel('Media Sosial'),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.link,
                    size: 15, color: AppColors.primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    profile.socialMedia!,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATISTIK
// ─────────────────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final int reviewCount;
  const _StatsCard({required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.rate_review_outlined,
                color: AppColors.primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$reviewCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Ulasan ditulis',
                style:
                    TextStyle(color: AppColors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KARTU RIWAYAT ULASAN
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewHistoryCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewHistoryCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: gambar tempat + nama + bintang + tanggal ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar tempat atau ikon fallback
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: review.placeImageUrl != null
                      ? Image.network(
                          review.placeImageUrl!,
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderIcon(review.placeType),
                        )
                      : _placeholderIcon(review.placeType),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge tipe tempat
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          review.placeType == 'restoran'
                              ? 'Restoran'
                              : 'Wisata',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Nama tempat
                      Text(
                        review.placeName ?? 'Tempat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Bintang + tanggal
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < review.rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: AppColors.ratingColor,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            review.dateFormatted,
                            style: const TextStyle(
                                color: AppColors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Judul ulasan (jika ada) ──────────────────────────
          if (review.title != null && review.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
              child: Text(
                review.title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // ── Teks komentar ────────────────────────────────────
          if (review.comment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Text(
                review.comment,
                style: const TextStyle(
                    color: AppColors.white70, fontSize: 13, height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // ── Foto lampiran (scroll horizontal) ───────────────
          if (review.imageUrls.isNotEmpty) ...[
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
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
                        child: const Icon(Icons.image_not_supported,
                            color: AppColors.white54),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ── Footer: berguna count ─────────────────────────────
          if (review.usefulCount > 0) ...[
            Divider(
                color: Colors.white.withOpacity(0.07), height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.thumb_up_outlined,
                      size: 14, color: AppColors.white54),
                  const SizedBox(width: 6),
                  Text(
                    '${review.usefulCount} orang merasa ulasan ini berguna',
                    style: const TextStyle(
                        color: AppColors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _placeholderIcon(String placeType) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        placeType == 'restoran' ? Icons.restaurant : Icons.landscape,
        color: AppColors.white54,
        size: 28,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyReviews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.rate_review_outlined,
              color: AppColors.white54, size: 48),
          SizedBox(height: 12),
          Text(
            'Belum ada ulasan',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Pengguna ini belum menulis ulasan apapun.',
            style: TextStyle(color: AppColors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
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
        fontSize: 17,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}