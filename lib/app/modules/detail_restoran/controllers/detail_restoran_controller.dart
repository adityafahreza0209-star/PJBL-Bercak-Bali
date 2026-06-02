import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/restaurant_service.dart';
import '../../../services/review_service.dart';

class DetailRestoranController extends GetxController {
  // ── State utama ───────────────────────────────────────────────
  final isLoading = true.obs;
  final errorMessage = RxnString();

  // ── Data restoran (diisi setelah fetch) ───────────────────────
  RestaurantModel? _restoran;

  String get name => _restoran?.name ?? '';
  String get location => _restoran?.location ?? '';
  String get cuisine => _restoran?.cuisine ?? '';
  String get description => _restoran?.description ?? '';
  String get priceRange => _restoran?.priceRange ?? '';
  String get distance => _restoran?.distance ?? '';
  String get phoneNumber => _restoran?.phoneNumber ?? '';
  String get rating => _restoran?.rating.toStringAsFixed(1) ?? '0.0';
  int get totalUlasan => _restoran?.totalReviews ?? 0;
  String? get googleMapsUrl => _restoran?.googleMapsUrl;
  bool get hasGoogleMapsUrl => googleMapsUrl?.isNotEmpty == true;
  List<String> get images => _restoran?.images ?? [];

  // ── State carousel gambar ─────────────────────────────────────
  final currentImage = 0.obs;

  // ── State simpan/favorit ──────────────────────────────────────
  final isFavorite = false.obs;

  // ── State reviews ─────────────────────────────────────────────
  final reviews = <ReviewModel>[].obs;
  final isLoadingReviews = false.obs;

  Map<int, int> get ratingCounts {
    final counts = {for (var star = 1; star <= 5; star++) star: 0};
    for (final review in reviews) {
      if (counts.containsKey(review.rating)) {
        counts[review.rating] = counts[review.rating]! + 1;
      }
    }
    return counts;
  }

  int get actualReviewCount => reviews.length;

  // ── State tombol "Berguna" per review (key = review_id) ───────
  final usefulCounts = <String, int>{}.obs;
  final userUseful = <String, bool>{}.obs;

  // ── State menu ────────────────────────────────────────────────
  final menuItems = <MenuItemModel>[].obs;
  final isLoadingMenu = false.obs;

  final _restaurantService = RestaurantService();
  final _reviewService = ReviewService();
  String _restaurantId = '';

  // ── Getter menu per kategori ──────────────────────────────────
  List<MenuItemModel> get menuMakanan =>
      menuItems.where((m) => m.category == 'Makanan').toList();
  List<MenuItemModel> get menuMinuman =>
      menuItems.where((m) => m.category == 'Minuman').toList();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _restaurantId = args?['restaurantId'] as String? ?? '';

    if (_restaurantId.isEmpty) {
      errorMessage.value = 'ID restoran tidak valid.';
      isLoading.value = false;
      return;
    }

    _fetchAll();
  }

  // ── FETCH ─────────────────────────────────────────────────────

  Future<void> _fetchAll() async {
    await Future.wait([_fetchRestoranDetail(), _fetchReviews(), _fetchMenus()]);
  }

  Future<void> _fetchRestoranDetail() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final data = await _restaurantService.fetchRestaurantById(_restaurantId);
      if (data == null) {
        errorMessage.value = 'Restoran tidak ditemukan.';
        return;
      }

      _restoran = data;

      final userId = AuthService.to.userId;
      if (userId.isNotEmpty) {
        isFavorite.value = await _restaurantService.isSaved(
          restaurantId: _restaurantId,
          userId: userId,
        );
        await _restaurantService.recordVisit(
          restaurantId: _restaurantId,
          userId: userId,
        );
      }
    } catch (_) {
      errorMessage.value = 'Gagal memuat data restoran. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchReviews() async {
    if (_restaurantId.isEmpty) return;
    try {
      isLoadingReviews.value = true;

      final data = await _reviewService.fetchRestaurantReviews(_restaurantId);
      reviews.assignAll(data);

      // Inisialisasi state berguna dari data Supabase
      for (final r in data) {
        usefulCounts[r.id] = r.usefulCount;
        userUseful[r.id] = false;
      }

      // Tandai review yang sudah di-vote user ini
      final userId = AuthService.to.userId;
      if (userId.isNotEmpty) {
        final votedIds = await _reviewService.fetchUserVotes(userId);
        for (final id in votedIds) {
          if (userUseful.containsKey(id)) {
            userUseful[id] = true;
          }
        }
      }
    } catch (_) {
      // Gagal load review tidak fatal
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> _fetchMenus() async {
    if (_restaurantId.isEmpty) return;
    try {
      isLoadingMenu.value = true;
      final data = await _restaurantService.fetchMenus(_restaurantId);
      menuItems.assignAll(data);
    } catch (_) {
      // Menu gagal dimuat — UI cukup kosong
    } finally {
      isLoadingMenu.value = false;
    }
  }

  // Dipanggil setelah submit review berhasil
  Future<void> refresh() => _fetchAll();

  // ── AKSI TERPROTEKSI (perlu login) ────────────────────────────

  Future<void> toggleFavorite() async {
    if (!AuthService.to.isLoggedIn.value) {
      AuthService.to.requireLogin(
        message: 'Login terlebih dahulu untuk menyimpan restoran.',
      );
      return;
    }

    final userId = AuthService.to.userId;
    final nowFavorite = isFavorite.value;

    isFavorite.value = !nowFavorite; // optimistic update

    try {
      if (nowFavorite) {
        await _restaurantService.unsavePlace(
          restaurantId: _restaurantId,
          userId: userId,
        );
      } else {
        await _restaurantService.savePlace(
          restaurantId: _restaurantId,
          userId: userId,
        );
      }
    } catch (_) {
      isFavorite.value = nowFavorite; // rollback
      Get.snackbar('Gagal', 'Tidak bisa menyimpan restoran. Coba lagi.');
    }
  }

  Future<void> toggleUseful(String reviewId) async {
    if (!AuthService.to.isLoggedIn.value) {
      AuthService.to.requireLogin(
        message: 'Login terlebih dahulu untuk menandai ulasan berguna.',
      );
      return;
    }

    final userId = AuthService.to.userId;
    final alreadyVoted = userUseful[reviewId] ?? false;
    final currentCount = usefulCounts[reviewId] ?? 0;

    // Optimistic update
    userUseful[reviewId] = !alreadyVoted;
    usefulCounts[reviewId] = alreadyVoted ? currentCount - 1 : currentCount + 1;

    try {
      if (alreadyVoted) {
        await _reviewService.removeVote(reviewId: reviewId, userId: userId);
      } else {
        await _reviewService.addVote(reviewId: reviewId, userId: userId);
      }
    } catch (_) {
      // Rollback
      userUseful[reviewId] = alreadyVoted;
      usefulCounts[reviewId] = currentCount;
      Get.snackbar('Gagal', 'Tidak bisa memproses vote. Coba lagi.');
    }
  }

  Future<void> goToWriteReview() async {
    if (!AuthService.to.isLoggedIn.value) {
      AuthService.to.requireLogin(
        message: 'Login terlebih dahulu untuk menulis ulasan.',
      );
      return;
    }

    // result: true → review berhasil dikirim → refresh halaman
    final result = await Get.toNamed(
      Routes.WRITE_REVIEW,
      arguments: {
        'restaurantId': _restaurantId,
        'placeName': name,
        'placeType': 'restoran',
      },
    );

    if (result == true) await refresh();
  }

  // ── AKSI BEBAS (tidak perlu login) ────────────────────────────

  void onPageChanged(int index) => currentImage.value = index;

  Future<void> openGoogleMaps() async {
    final link = googleMapsUrl;

    if (link == null || link.trim().isEmpty) {
      Get.snackbar('Info', 'Link lokasi belum tersedia');
      return;
    }

    final url = Uri.tryParse(link.trim());
    if (url == null ||
        !url.isAbsolute ||
        url.host.isEmpty ||
        (url.scheme != 'http' && url.scheme != 'https')) {
      Get.snackbar('Error', 'Link Google Maps tidak valid');
      return;
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Link Google Maps tidak valid');
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak bisa membuka Google Maps.');
    }
  }

  Future<void> callRestoran() async {
    if (phoneNumber.isEmpty) {
      Get.snackbar('Info', 'Nomor telepon tidak tersedia.');
      return;
    }
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (_) {
      Get.snackbar('Error', 'Tidak bisa melakukan panggilan.');
    }
  }

  Future<void> sharePlace() async =>
      Get.snackbar('Bagikan', 'Fitur bagikan segera hadir.');

  void goBack() => Get.back();
}
