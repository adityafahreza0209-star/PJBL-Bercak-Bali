import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../services/restaurant_service.dart';
import '../../../services/wisata_service.dart';

class DestinationCityController extends GetxController {
  // Data kota diterima via Get.arguments
  late String cityId;
  late String cityName;
  late String region;
  late String description;
  late String imageUrl;

  // ── State restoran ──────────────────────────────────────────
  final restaurants = <RestaurantModel>[].obs;
  final isLoadingRestoran = false.obs;
  final errorRestoran = RxnString();

  // ── State wisata ────────────────────────────────────────────
  final wisataList = <WisataModel>[].obs;
  final isLoadingWisata = false.obs;
  final errorWisata = RxnString();

  final _restaurantService = RestaurantService();
  final _wisataService = WisataService();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    cityId = args?['cityId'] as String? ?? '';
    cityName = args?['cityName'] as String? ?? '';
    region = args?['region'] as String? ?? '';
    description = args?['description'] as String? ?? '';
    imageUrl = args?['imageUrl'] as String? ?? '';

    // Muat restoran dan wisata secara paralel
    Future.wait([
      _fetchRestaurants(),
      _fetchWisata(),
    ]);
  }

  // ── FETCH ───────────────────────────────────────────────────

  Future<void> _fetchRestaurants() async {
    if (cityId.isEmpty) {
      errorRestoran.value = 'ID kota tidak valid.';
      return;
    }
    try {
      isLoadingRestoran.value = true;
      errorRestoran.value = null;
      final data = await _restaurantService.fetchRestaurantsByCityId(cityId);
      restaurants.assignAll(data);
    } catch (_) {
      errorRestoran.value = 'Gagal memuat restoran. Coba lagi.';
    } finally {
      isLoadingRestoran.value = false;
    }
  }

  Future<void> _fetchWisata() async {
    if (cityId.isEmpty) {
      errorWisata.value = 'ID kota tidak valid.';
      return;
    }
    try {
      isLoadingWisata.value = true;
      errorWisata.value = null;
      final data = await _wisataService.fetchWisataByCityId(cityId);
      wisataList.assignAll(data);
    } catch (_) {
      errorWisata.value = 'Gagal memuat wisata. Coba lagi.';
    } finally {
      isLoadingWisata.value = false;
    }
  }

  Future<void> refreshRestaurants() => _fetchRestaurants();
  Future<void> refreshWisata() => _fetchWisata();

  // ── NAVIGASI ────────────────────────────────────────────────

  void goBack() => Get.back();

  void goToDetailRestoran(RestaurantModel resto) =>
      Get.toNamed(Routes.DETAIL_RESTORAN, arguments: resto.toArguments());

  void goToDetailWisata(WisataModel wisata) =>
      Get.toNamed(Routes.DETAIL_WISATA, arguments: wisata.toArguments());
}