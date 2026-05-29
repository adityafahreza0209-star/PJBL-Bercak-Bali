import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/history_service.dart';
import '../../../widgets/theme_constants.dart';

class HistoryController extends GetxController {
  // ── State ────────────────────────────────────────────────────
  final isLoading = true.obs;
  final isClearing = false.obs;
  final errorMessage = RxnString();
  final historyItems = <VisitHistoryItem>[].obs;

  final _service = HistoryService();

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  // ── FETCH ─────────────────────────────────────────────────────

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final data =
          await _service.fetchHistory(AuthService.to.userId);
      historyItems.assignAll(data);
    } catch (_) {
      errorMessage.value = 'Gagal memuat riwayat. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => fetchHistory();

  // ── HAPUS SATU ITEM (swipe) ───────────────────────────────────

  Future<void> deleteItem(VisitHistoryItem item) async {
    // Optimistic remove
    historyItems.remove(item);
    try {
      await _service.deleteItem(item.id);
    } catch (_) {
      // Rollback jika gagal
      historyItems.add(item);
      historyItems.sort(
          (a, b) => b.visitedAt.compareTo(a.visitedAt));
      Get.snackbar('Gagal', 'Tidak bisa menghapus item. Coba lagi.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ── HAPUS SEMUA ───────────────────────────────────────────────

  void showClearDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Riwayat',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Semua riwayat kunjungan akan dihapus. Tindakan ini tidak bisa dibatalkan.',
          style: TextStyle(color: AppColors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.white54)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _clearAll();
            },
            child: const Text(
              'Hapus Semua',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAll() async {
    final backup = List<VisitHistoryItem>.from(historyItems);
    historyItems.clear(); // optimistic
    try {
      isClearing.value = true;
      await _service.clearAll(AuthService.to.userId);
      Get.snackbar(
        'Berhasil',
        'Riwayat berhasil dihapus.',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      historyItems.assignAll(backup); // rollback
      Get.snackbar('Gagal', 'Tidak bisa menghapus riwayat. Coba lagi.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isClearing.value = false;
    }
  }

  // ── NAVIGASI ─────────────────────────────────────────────────

  void goBack() => Get.back();

  void goToDetail(VisitHistoryItem item) {
    if (item.isWisata) {
      Get.toNamed(
        Routes.DETAIL_WISATA,
        arguments: {'wisataId': item.placeId},
      );
    } else {
      Get.toNamed(
        Routes.DETAIL_RESTORAN,
        arguments: {'restaurantId': item.placeId},
      );
    }
  }
}