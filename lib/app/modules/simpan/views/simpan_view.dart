import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/custom_navbar.dart';
import '../controllers/simpan_controller.dart';
import '../../../services/saved_place_service.dart';
import '../../../services/auth_service.dart';

class SimpanView extends GetView<SimpanController> {
  const SimpanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            _TabBar(controller: controller),
            Expanded(child: _Body(controller: controller)),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 2),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tersimpan',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() {
            final count = Get.find<SimpanController>().allItems.length;
            return Text(
              '$count tempat tersimpan',
              style: const TextStyle(color: AppColors.white54, fontSize: 14),
            );
          }),
        ],
      ),
    );
  }
}

// ── Tab Bar ─────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({required this.controller});
  final SimpanController controller;

  static const _tabs = [
    (tab: SimpanTab.semua, label: 'Semua', icon: Icons.apps_rounded),
    (tab: SimpanTab.wisata, label: 'Wisata', icon: Icons.landscape),
    (tab: SimpanTab.restoran, label: 'Restoran', icon: Icons.restaurant),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Obx(() {
        return Row(
          children: _tabs.map((item) {
            final isSelected = controller.activeTab.value == item.tab;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => controller.selectTab(item.tab),
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
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 16,
                          color: isSelected ? AppColors.bgColor : AppColors.white70,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected ? AppColors.bgColor : AppColors.white,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}

// ── Body ────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.controller});
  final SimpanController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. Loading → tampilkan skeleton
      if (controller.isLoading.value) {
        return const _SkeletonList();
      }

      // 2. Belum login
      if (!AuthService.to.isLoggedIn.value) {
        return const _LoginPromptView();
      }

      // 3. Error
      if (controller.errorMessage.value.isNotEmpty) {
        return _ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.onRefresh,
        );
      }

      final items = controller.filteredItems;

      // 4. Kosong
      if (items.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          color: AppColors.primaryColor,
          backgroundColor: AppColors.cardColor,
          child: ListView(
            children: const [
              SizedBox(height: 120),
              _EmptyView(),
            ],
          ),
        );
      }

      // 5. Daftar item
      return RefreshIndicator(
        onRefresh: controller.onRefresh,
        color: AppColors.primaryColor,
        backgroundColor: AppColors.cardColor,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _SavedItemCard(
              key: ValueKey(item.savedId),
              item: item,
              onTap: () => controller.goToDetail(item),
              onUnsave: () => controller.unsaveItem(item),
            );
          },
        ),
      );
    });
  }
}

// ── Saved Item Card ─────────────────────────────────────────────

class _SavedItemCard extends StatelessWidget {
  const _SavedItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onUnsave,
  });

  final SavedPlaceItem item;
  final VoidCallback onTap;
  final VoidCallback onUnsave;

  Color get _categoryColor {
    switch (item.categoryLabel) {
      case 'Restoran':
        return const Color(0xFFF44336);
      case 'Pantai':
        return const Color(0xFF2196F3);
      case 'Budaya':
        return const Color(0xFF9C27B0);
      case 'Hidden Gem':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.savedId),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      confirmDismiss: (_) => _confirmUnsave(context),
      onDismissed: (_) => onUnsave(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(imageUrl: item.imageUrl),
              const SizedBox(width: 14),
              Expanded(child: _CardContent(item: item, categoryColor: _categoryColor)),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmUnsave(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus dari simpanan?',
            style: TextStyle(color: AppColors.white, fontSize: 16)),
        content: Text(
          item.title,
          style: const TextStyle(color: AppColors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus',
                style: TextStyle(color: Color(0xFFF44336), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF44336),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_remove, color: Colors.white, size: 26),
          SizedBox(height: 4),
          Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 96,
          height: 96,
          color: AppColors.bgColor,
          child: const Icon(Icons.image_not_supported,
              color: AppColors.white54, size: 32),
        ),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _ShimmerBox(width: 96, height: 96, borderRadius: 12);
        },
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.item, required this.categoryColor});
  final SavedPlaceItem item;
  final Color categoryColor;

  String _formatSavedDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    return '${(diff.inDays / 30).floor()} bulan lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul + chip kategori
        Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.categoryLabel,
                style: TextStyle(
                    color: categoryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Lokasi
        Row(
          children: [
            const Icon(Icons.location_on,
                color: AppColors.primaryColor, size: 13),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.location,
                style: const TextStyle(color: AppColors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Rating + tanggal simpan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Rating
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.ratingColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 12),
                  const SizedBox(width: 3),
                  Text(
                    item.rating.toStringAsFixed(1),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Tanggal
            Row(
              children: [
                const Icon(Icons.bookmark,
                    color: AppColors.white54, size: 12),
                const SizedBox(width: 4),
                Text(
                  _formatSavedDate(item.savedAt),
                  style: const TextStyle(
                      color: AppColors.white54, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ── Skeleton ────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail placeholder
          _ShimmerBox(width: 96, height: 96, borderRadius: 12),
          const SizedBox(width: 14),
          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _ShimmerBox(width: double.infinity, height: 16, borderRadius: 6)),
                    const SizedBox(width: 8),
                    _ShimmerBox(width: 52, height: 20, borderRadius: 6),
                  ],
                ),
                const SizedBox(height: 10),
                _ShimmerBox(width: 140, height: 12, borderRadius: 6),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ShimmerBox(width: 50, height: 22, borderRadius: 6),
                    _ShimmerBox(width: 80, height: 12, borderRadius: 6),
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

/// Widget shimmer murni — tidak butuh package external.
/// Menggunakan AnimationController untuk efek gerak cahaya.
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_anim.value - 0.5).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.5).clamp(0.0, 1.0),
            ],
            colors: const [
              Color(0xFF2A2A2A),
              Color(0xFF3A3A3A),
              Color(0xFF2A2A2A),
            ],
          ),
        ),
      ),
    );
  }
}

// ── State Views ─────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: AppColors.cardColor, shape: BoxShape.circle),
          child: const Icon(Icons.bookmark_border,
              color: AppColors.white54, size: 48),
        ),
        const SizedBox(height: 16),
        const Text(
          'Belum ada tempat tersimpan',
          style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap ikon bookmark di halaman detail\nuntuk menyimpan tempat favoritmu.',
          style: TextStyle(color: AppColors.white54, fontSize: 13, height: 1.6),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginPromptView extends StatelessWidget {
  const _LoginPromptView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: AppColors.white54, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Login untuk melihat simpanan',
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masuk ke akun kamu untuk melihat tempat yang sudah disimpan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white54, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => AuthService.to.requireLogin(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.bgColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Masuk',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
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
            const Icon(Icons.wifi_off, color: AppColors.white54, size: 56),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.white70, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.bgColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}