import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/saved_place_service.dart';
import '../../../routes/app_pages.dart';

enum SimpanTab { semua, wisata, restoran }

class SimpanController extends GetxController {
  // ── State ────────────────────────────────────────────────────
  final activeTab = SimpanTab.semua.obs;
  final allItems = <SavedPlaceItem>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  // ── Service ──────────────────────────────────────────────────
  final _service = SavedPlaceService();

  // ── Getters ──────────────────────────────────────────────────

  List<SavedPlaceItem> get filteredItems {
    return switch (activeTab.value) {
      SimpanTab.wisata => allItems.where((i) => i.placeType == 'wisata').toList(),
      SimpanTab.restoran => allItems.where((i) => i.placeType == 'restoran').toList(),
      SimpanTab.semua => allItems.toList(),
    };
  }

  // ── Lifecycle ────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadSavedPlaces();
  }

  // ── Data ─────────────────────────────────────────────────────

  Future<void> loadSavedPlaces() async {
    // Pastikan user sudah login
    if (!AuthService.to.isLoggedIn.value) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = AuthService.to.userId;
      final items = await _service.fetchSavedPlaces(userId);
      allItems.assignAll(items);
    } catch (_) {
      errorMessage.value = 'Gagal memuat data. Tarik ke bawah untuk coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() => loadSavedPlaces();

  // ── Actions ───────────────────────────────────────────────────

  void selectTab(SimpanTab tab) => activeTab.value = tab;

  /// Hapus item dari list lokal dulu (optimistic), lalu sinkron ke Supabase.
  Future<void> unsaveItem(SavedPlaceItem item) async {
    allItems.remove(item);

    try {
      await _service.unsave(item.savedId);
      Get.snackbar(
        'Dihapus',
        '${item.title} dihapus dari simpanan',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      // Rollback jika gagal
      allItems.add(item);
      allItems.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      Get.snackbar(
        'Gagal',
        'Tidak dapat menghapus. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void goToDetail(SavedPlaceItem item) {
    if (item.placeType == 'wisata' && item.wisata != null) {
      Get.toNamed(Routes.DETAIL_WISATA, arguments: item.wisata!.toArguments());
    } else if (item.restaurant != null) {
      Get.toNamed(Routes.DETAIL_RESTORAN, arguments: item.restaurant!.toArguments());
    }
  }
}