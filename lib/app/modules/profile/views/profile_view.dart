import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/custom_navbar.dart';
import '../controllers/profile_controller.dart';
import '../../../services/profile_service.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primaryColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Header ────────────────────────────────────
              SliverToBoxAdapter(
                child: _ProfileHeader(controller: controller),
              ),

              // ── Kartu profil ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Obx(
                    () => controller.isLoadingProfile.value
                        ? const _ProfileCardSkeleton()
                        : _ProfileCard(
                            profile: controller.profile.value,
                            onEditTap: controller.goToEditProfile,
                          ),
                  ),
                ),
              ),

              // ── Aktivitas Saya ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: const _SectionLabel('Aktivitas Saya'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Obx(
                    () => controller.isLoadingCounts.value
                        ? const _ActivitySkeleton()
                        : _ActivityCard(
                            counts: controller.counts.value,
                            onSavedTap: controller.goToSavedPlaces,
                            onHistoryTap: controller.goToVisitHistory,
                            onReviewsTap: controller.goToMyReviews,
                          ),
                  ),
                ),
              ),

              // ── Pengaturan ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: const _SectionLabel('Pengaturan'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: _SettingsCard(controller: controller),
                ),
              ),

              // ── Tombol Logout ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: _LogoutButton(onTap: controller.signOut),
                ),
              ),

              // Space untuk navbar
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 3),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final ProfileController controller;
  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Profil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: controller.goToSettings,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KARTU PROFIL
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final ProfileData? profile;
  final VoidCallback onEditTap;
  const _ProfileCard({required this.profile, required this.onEditTap});

  @override
  Widget build(BuildContext context) {
    final name = profile?.fullName ?? 'Pengguna';
    final email = profile?.email ?? '';
    final avatarUrl = profile?.avatarUrl;
    final roleLabel = profile?.roleLabel ?? 'Traveler';
    final initial = profile?.initial ?? 'P';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          _Avatar(avatarUrl: avatarUrl, initial: initial, size: 64),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        email,
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onEditTap,
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.white54,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Badge role
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    roleLabel,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
// ACTIVITY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final ActivityCount counts;
  final VoidCallback onSavedTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onReviewsTap;

  const _ActivityCard({
    required this.counts,
    required this.onSavedTap,
    required this.onHistoryTap,
    required this.onReviewsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _ActivityTile(
            icon: Icons.bookmark_border_rounded,
            label: 'Destinasi Tersimpan',
            count: counts.saved,
            onTap: onSavedTap,
            showDivider: true,
          ),
          _ActivityTile(
            icon: Icons.history_rounded,
            label: 'Riwayat Kunjungan',
            count: counts.visited,
            onTap: onHistoryTap,
            showDivider: true,
          ),
          _ActivityTile(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Ulasan Saya',
            count: counts.reviews,
            onTap: onReviewsTap,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;
  final bool showDivider;

  const _ActivityTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.white70, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  '$count',
                  style: const TextStyle(
                    color: AppColors.white54,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.white54,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            color: Colors.white.withOpacity(0.06),
            height: 1,
            indent: 52,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final ProfileController controller;
  const _SettingsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            onTap: () {},
            showDivider: true,
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            label: 'Bahasa',
            trailing: const Text(
              'Indonesia',
              style: TextStyle(
                  color: AppColors.white54, fontSize: 14),
            ),
            onTap: () {},
            showDivider: true,
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'Tentang Aplikasi',
            onTap: () {},
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.white70, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15),
                  ),
                ),
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 6),
                ],
                const Icon(Icons.chevron_right,
                    color: AppColors.white54, size: 20),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            color: Colors.white.withOpacity(0.06),
            height: 1,
            indent: 52,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGOUT BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.red.withOpacity(0.3), width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            SizedBox(width: 8),
            Text(
              'Keluar',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun ini?',
          style: TextStyle(color: AppColors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onTap();
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SKELETON WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCardSkeleton extends StatelessWidget {
  const _ProfileCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar skeleton
          _Shimmer(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Text skeletons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Shimmer(
                  child: Container(
                    height: 18,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _Shimmer(
                  child: Container(
                    height: 13,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _Shimmer(
                  child: Container(
                    height: 24,
                    width: 72,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
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

class _ActivitySkeleton extends StatelessWidget {
  const _ActivitySkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(3, (i) {
          final isLast = i == 2;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    _Shimmer(
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _Shimmer(
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    _Shimmer(
                      child: Container(
                        width: 20,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  color: Colors.white.withOpacity(0.06),
                  height: 1,
                  indent: 52,
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String initial;
  final double size;
  const _Avatar({
    required this.avatarUrl,
    required this.initial,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: AppColors.cardColor,
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primaryColor,
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.bgColor,
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
        ),
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
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
    );
  }
}

/// Widget shimmer sederhana — berkedip pelan untuk memberi kesan loading.
/// Tidak memerlukan package tambahan.
class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) =>
          Opacity(opacity: _animation.value, child: child),
      child: widget.child,
    );
  }
}