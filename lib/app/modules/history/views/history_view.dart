import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../../widgets/custom_navbar.dart';
import '../../../services/history_service.dart';
import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _HistoryHeader(controller: controller),
            Expanded(
              child: Obx(() {
                // ── Loading ──────────────────────────────────
                if (controller.isLoading.value) {
                  return const _HistorySkeletonList();
                }

                // ── Error ────────────────────────────────────
                if (controller.errorMessage.value != null) {
                  return _ErrorState(
                    message: controller.errorMessage.value!,
                    onRetry: controller.refresh,
                  );
                }

                // ── Kosong ───────────────────────────────────
                if (controller.visibleHistoryItems.isEmpty) {
                  return const _EmptyState();
                }

                // ── List dengan grouping per tanggal ─────────
                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  color: AppColors.primaryColor,
                  child: _HistoryList(controller: controller),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 3),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryHeader extends StatelessWidget {
  final HistoryController controller;
  const _HistoryHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 8, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: controller.goBack,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Riwayat Kunjungan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Tombol hapus semua — hanya tampil jika ada data
          Obx(
            () => controller.historyItems.isEmpty
                ? const SizedBox.shrink()
                : controller.isClearing.value
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white54),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.white70),
                        onPressed: controller.showClearDialog,
                        tooltip: 'Hapus semua',
                      ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIST DENGAN GROUP HEADER PER TANGGAL
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryList extends StatelessWidget {
  final HistoryController controller;
  const _HistoryList({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Buat list widget yang berisi group header + card per kelompok tanggal
    final grouped = _groupByDate(controller.visibleHistoryItems);
    final List<Widget> widgets = [];

    for (final entry in grouped.entries) {
      // Header tanggal
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            entry.key,
            style: const TextStyle(
              color: AppColors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );

      // Kartu per item dalam group ini
      for (final item in entry.value) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SwipeToDelete(
              key: ValueKey(item.id),
              onDelete: () => controller.deleteItem(item),
              child: _HistoryCard(
                item: item,
                onTap: () => controller.goToDetail(item),
              ),
            ),
          ),
        );
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 16),
      children: widgets,
    );
  }

  /// Kelompokkan item berdasarkan label bulan-tahun kunjungan.
  /// Contoh: "Februari 2026", "Januari 2026"
  Map<String, List<VisitHistoryItem>> _groupByDate(
      List<VisitHistoryItem> items) {
    const months = [
      '',
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];

    final Map<String, List<VisitHistoryItem>> grouped = {};
    for (final item in items) {
      final key =
          '${months[item.visitedAt.month]} ${item.visitedAt.year}';
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SWIPE TO DELETE
// ─────────────────────────────────────────────────────────────────────────────

class _SwipeToDelete extends StatelessWidget {
  final Widget child;
  final VoidCallback onDelete;
  const _SwipeToDelete({
    super.key,
    required this.child,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      confirmDismiss: (_) async {
        // Tanya konfirmasi sebelum swipe delete
        return await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: AppColors.cardColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            content: const Text(
              'Hapus item ini dari riwayat?',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Batal',
                    style: TextStyle(color: AppColors.white54)),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Hapus',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 26),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HISTORY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final VisitHistoryItem item;
  final VoidCallback onTap;
  const _HistoryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Gambar tempat dari Supabase Storage
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.placeImageUrl.isNotEmpty
                  ? Image.network(
                      item.placeImageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _imageFallback(item.isWisata),
                    )
                  : _imageFallback(item.isWisata),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama tempat
                  Text(
                    item.placeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Lokasi
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.primaryColor, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.placeLocation,
                          style: const TextStyle(
                              color: AppColors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating + tanggal kunjungan
                  Row(
                    children: [
                      // Rating
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
                              item.placeRating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Tanggal kunjungan
                      const Icon(Icons.calendar_today,
                          color: AppColors.white54, size: 11),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.visitDateFormatted,
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

            // Badge tipe tempat + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.isWisata ? 'Wisata' : 'Restoran',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(Icons.chevron_right,
                    color: AppColors.white54, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(bool isWisata) => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isWisata ? Icons.landscape : Icons.restaurant,
          color: AppColors.white54,
          size: 32,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SKELETON LOADING
// ─────────────────────────────────────────────────────────────────────────────

class _HistorySkeletonList extends StatelessWidget {
  const _HistorySkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 4,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: _HistoryCardSkeleton(),
      ),
    );
  }
}

class _HistoryCardSkeleton extends StatelessWidget {
  const _HistoryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Gambar skeleton
          _Shimmer(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Shimmer(
                  child: Container(
                    height: 15,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _Shimmer(
                  child: Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Shimmer(
                      child: Container(
                        height: 20,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _Shimmer(
                      child: Container(
                        height: 12,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY & ERROR STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.cardColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded,
                  color: AppColors.white54, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada riwayat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Destinasi dan restoran yang kamu kunjungi\nakan muncul di sini.',
              style: TextStyle(color: AppColors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.white54, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.bgColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER
// ─────────────────────────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
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
      builder: (_, child) =>
          Opacity(opacity: _anim.value, child: child),
      child: widget.child,
    );
  }
}
