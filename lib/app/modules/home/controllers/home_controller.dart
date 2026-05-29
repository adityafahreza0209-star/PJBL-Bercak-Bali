import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../services/restaurant_service.dart';
import '../../../services/wisata_service.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final isSearching = false.obs;

  // ── State restoran ──────────────────────────────────────────
  final topRestaurants = <RestaurantModel>[].obs;
  final isLoadingRestoran = false.obs;
  final errorRestoran = RxnString();

  // ── State kota ──────────────────────────────────────────────
  final cities = <CityModel>[].obs;
  final isLoadingCities = false.obs;
  final errorCities = RxnString();

  // ── State wisata populer & terakhir dilihat ─────────────────
  final popularWisata = <WisataModel>[].obs;
  final recentWisata = <WisataModel>[].obs;
  final isLoadingWisata = false.obs;
  final errorWisata = RxnString();

  final _restaurantService = RestaurantService();
  final _wisataService = WisataService();

  @override
  void onInit() {
    super.onInit();
    _fetchAll();
  }

  // ── FETCH ───────────────────────────────────────────────────

  Future<void> _fetchAll() async {
    await Future.wait([
      _fetchCities(),
      _fetchFeaturedRestaurants(),
      _fetchWisata(),
    ]);
  }

  Future<void> _fetchCities() async {
    try {
      isLoadingCities.value = true;
      errorCities.value = null;
      final data = await _wisataService.fetchAllCities();
      cities.assignAll(data);
    } catch (_) {
      errorCities.value = 'Gagal memuat kota. Coba lagi.';
    } finally {
      isLoadingCities.value = false;
    }
  }

  Future<void> _fetchFeaturedRestaurants() async {
    try {
      isLoadingRestoran.value = true;
      errorRestoran.value = null;
      final data = await _restaurantService.fetchFeaturedRestaurants();
      topRestaurants.assignAll(data);
    } catch (_) {
      errorRestoran.value = 'Gagal memuat restoran. Coba lagi.';
    } finally {
      isLoadingRestoran.value = false;
    }
  }

  Future<void> _fetchWisata() async {
    try {
      isLoadingWisata.value = true;
      errorWisata.value = null;

      final featured = await _wisataService.fetchFeaturedWisata();
      popularWisata.assignAll(featured);

      // "Terakhir dilihat" diambil dari 2 wisata pertama (nanti bisa
      // diganti dengan data visit_histories milik user yang sedang login)
      recentWisata.assignAll(featured.take(2).toList());
    } catch (_) {
      errorWisata.value = 'Gagal memuat wisata. Coba lagi.';
    } finally {
      isLoadingWisata.value = false;
    }
  }

  Future<void> refreshAll() => _fetchAll();
  Future<void> refreshRestaurants() => _fetchFeaturedRestaurants();

  // ── NAVIGASI ────────────────────────────────────────────────

  void onSearchChanged(String value) => isSearching.value = value.isNotEmpty;

  void clearSearch() {
    searchController.clear();
    isSearching.value = false;
  }

  void goToDestinationCity(CityModel city) =>
      Get.toNamed(Routes.DESTINATION_CITY, arguments: city.toArguments());

  void goToDetailWisata(WisataModel wisata) =>
      Get.toNamed(Routes.DETAIL_WISATA, arguments: wisata.toArguments());

  void goToDetailRestoran(RestaurantModel resto) =>
      Get.toNamed(Routes.DETAIL_RESTORAN, arguments: resto.toArguments());

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}