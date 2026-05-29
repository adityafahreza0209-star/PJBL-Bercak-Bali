import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/review_service.dart';
import '../../../services/wisata_service.dart';

class DetailWisataController extends GetxController {
  // ── State utama ───────────────────────────────────────────────
  final isLoading = true.obs;
  final errorMessage = RxnString();

  // ── Data wisata (diisi setelah fetch) ─────────────────────────
  WisataModel? _wisata;

  String get title => _wisata?.title ?? '';
  String get location => _wisata?.location ?? '';
  String get category => _wisata?.category ?? '';
  String get description => _wisata?.description ?? '';
  String get ticketPrice => _wisata?.ticketPrice ?? '';
  String get openHours => _wisata?.openHours ?? '';
  String get duration => _wisata?.duration ?? '';
  String get rating => _wisata?.rating.toStringAsFixed(1) ?? '0.0';
  int get totalUlasan => _wisata?.totalReviews ?? 0;
  double get latitude => _wisata?.latitude ?? 0.0;
  double get longitude => _wisata?.longitude ?? 0.0;
  List<String> get images => _wisata?.images ?? [];

  // ── State carousel gambar ─────────────────────────────────────
  final currentImage = 0.obs;

  // ── State simpan/favorit ──────────────────────────────────────
  final isFavorite = false.obs;

  // ── State reviews ─────────────────────────────────────────────
  final reviews = <ReviewModel>[].obs;
  final isLoadingReviews = false.obs;

  // ── State tombol "Berguna" per review ─────────────────────────
  final usefulCounts = <String, int>{}.obs;
  final userUseful = <String, bool>{}.obs;

  final _wisataService = WisataService();
  final _reviewService = ReviewService();
  String _wisataId = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _wisataId = args?['wisataId'] as String? ?? '';

    if (_wisataId.isEmpty) {
      errorMessage.value = 'ID wisata tidak valid.';
      isLoading.value = false;
      return;
    }

    _fetchAll();
  }

  // ── FETCH ─────────────────────────────────────────────────────

  Future<void> _fetchAll() async {
    await Future.wait([
      _fetchWisataDetail(),
      _fetchReviews(),
    ]);
  }

  Future<void> _fetchWisataDetail() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final data = await _wisataService.fetchWisataById(_wisataId);
      if (data == null) {
        errorMessage.value = 'Wisata tidak ditemukan.';
        return;
      }

      _wisata = data;

      final userId = AuthService.to.userId;
      if (userId.isNotEmpty) {
        isFavorite.value = await _wisataService.isSaved(
          wisataId: _wisataId,
          userId: userId,
        );
        await _wisataService.recordVisit(
          wisataId: _wisataId,
          userId: userId,
        );
      }
    } catch (_) {
      errorMessage.value = 'Gagal memuat data wisata. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchReviews() async {
    if (_wisataId.isEmpty) return;
    try {
      isLoadingReviews.value = true;

      final data = await _reviewService.fetchWisataReviews(_wisataId);
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

  // Dipanggil setelah submit review berhasil
  Future<void> refresh() => _fetchAll();

  // ── AKSI TERPROTEKSI (perlu login) ────────────────────────────

  Future<void> toggleFavorite() async {
    if (!AuthService.to.isLoggedIn.value) {
      AuthService.to.requireLogin(
          message: 'Login terlebih dahulu untuk menyimpan wisata.');
      return;
    }

    final userId = AuthService.to.userId;
    final nowFavorite = isFavorite.value;

    isFavorite.value = !nowFavorite; // optimistic update

    try {
      if (nowFavorite) {
        await _wisataService.unsavePlace(wisataId: _wisataId, userId: userId);
      } else {
        await _wisataService.savePlace(wisataId: _wisataId, userId: userId);
      }
    } catch (_) {
      isFavorite.value = nowFavorite; // rollback
      Get.snackbar('Gagal', 'Tidak bisa menyimpan wisata. Coba lagi.');
    }
  }

  Future<void> toggleUseful(String reviewId) async {
    if (!AuthService.to.isLoggedIn.value) {
      AuthService.to.requireLogin(
          message: 'Login terlebih dahulu untuk menandai ulasan berguna.');
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
          message: 'Login terlebih dahulu untuk menulis ulasan.');
      return;
    }

    // result: true → review berhasil dikirim, refresh untuk tampilkan ulasan baru
    final result = await Get.toNamed(
      Routes.WRITE_REVIEW,
      arguments: {
        'wisataId': _wisataId,
        'placeName': title,
        'placeType': 'wisata',
      },
    );

    if (result == true) await refresh();
  }

  // ── AKSI BEBAS (tidak perlu login) ────────────────────────────

  void onPageChanged(int index) => currentImage.value = index;

  Future<void> openGoogleMaps() async {
    final lat = latitude;
    final lng = longitude;

    if (lat == 0.0 && lng == 0.0) {
      Get.snackbar('Info', 'Koordinat lokasi belum tersedia.');
      return;
    }

    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak bisa membuka Google Maps.');
    }
  }

  Future<void> sharePlace() async =>
      Get.snackbar('Bagikan', 'Fitur bagikan segera hadir.');

  void goBack() => Get.back();
}