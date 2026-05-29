import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/wisata_service.dart';
import '../../../services/restaurant_service.dart';

/// Tab aktif di halaman Jelajahi
enum JelajahiTab { semua, wisata, restoran }

class JelajahiController extends GetxController {
  // ── UI State ────────────────────────────────────────────────
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  final activeTab = JelajahiTab.semua.obs;

  // ── Data ────────────────────────────────────────────────────
  final wisataList = <WisataModel>[].obs;
  final restaurantList = <RestaurantModel>[].obs;

  // ── Status ──────────────────────────────────────────────────
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ── Search ──────────────────────────────────────────────────
  /// Teks pencarian yang sudah di-debounce (tidak langsung dari TextField)
  final _searchQuery = ''.obs;
  Timer? _debounceTimer;

  /// Getter untuk mengakses nilai search query dari View secara reaktif
  String get searchQuery => _searchQuery.value;

  // ── Services ────────────────────────────────────────────────
  final _wisataService = WisataService();
  final _restaurantService = RestaurantService();

  // ── Getters: Filtered Lists ──────────────────────────────────

  /// Wisata yang tampil setelah filter pencarian
  List<WisataModel> get filteredWisata {
    final query = _searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return wisataList;
    return wisataList.where((w) {
      return w.title.toLowerCase().contains(query) ||
          w.location.toLowerCase().contains(query) ||
          w.category.toLowerCase().contains(query);
    }).toList();
  }

  /// Restoran yang tampil setelah filter pencarian
  List<RestaurantModel> get filteredRestaurants {
    final query = _searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return restaurantList;
    return restaurantList.where((r) {
      return r.name.toLowerCase().contains(query) ||
          r.location.toLowerCase().contains(query) ||
          r.cuisine.toLowerCase().contains(query);
    }).toList();
  }

  // ── Lifecycle ───────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadData();

    // Debounce pencarian 400ms agar tidak trigger filter setiap ketukan
    searchController.addListener(() {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 400), () {
        _searchQuery.value = searchController.text;
      });
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  // ── Data Loading ────────────────────────────────────────────

  Future<void> _loadData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Fetch keduanya secara paralel untuk meminimalisir waktu tunggu
      final results = await Future.wait([
        _wisataService.fetchAllWisata(),
        _restaurantService.fetchAllRestaurants(),
      ]);

      wisataList.assignAll(results[0] as List<WisataModel>);
      restaurantList.assignAll(results[1] as List<RestaurantModel>);
    } catch (e) {
      errorMessage.value = 'Gagal memuat data. Periksa koneksi internet Anda.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Dipanggil saat user menarik ke bawah untuk refresh
  Future<void> onRefresh() => _loadData();

  // ── User Actions ────────────────────────────────────────────

  void selectTab(JelajahiTab tab) {
    activeTab.value = tab;
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery.value = '';
    searchFocusNode.unfocus();
  }

  void goToDetailWisata(WisataModel wisata) {
    Get.toNamed(Routes.DETAIL_WISATA, arguments: wisata.toArguments());
  }

  void goToDetailRestoran(RestaurantModel resto) {
    Get.toNamed(Routes.DETAIL_RESTORAN, arguments: resto.toArguments());
  }
}