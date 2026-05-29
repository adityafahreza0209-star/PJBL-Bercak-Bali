import 'package:get/get.dart';
import '../../../services/review_service.dart';

class UserProfileController extends GetxController {
  // ── State ────────────────────────────────────────────────────
  final isLoadingProfile = true.obs;
  final isLoadingReviews = true.obs;
  final errorMessage = RxnString();

  final profile = Rxn<UserProfileModel>();
  final reviews = <ReviewModel>[].obs;

  final _service = ReviewService();
  String _userId = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _userId = args?['userId'] as String? ?? '';

    if (_userId.isEmpty) {
      errorMessage.value = 'ID pengguna tidak valid.';
      isLoadingProfile.value = false;
      isLoadingReviews.value = false;
      return;
    }

    _fetchAll();
  }

  Future<void> _fetchAll() async {
    await Future.wait([
      _fetchProfile(),
      _fetchReviews(),
    ]);
  }

  Future<void> _fetchProfile() async {
    try {
      isLoadingProfile.value = true;
      final data = await _service.fetchUserProfile(_userId);
      if (data == null) {
        errorMessage.value = 'Pengguna tidak ditemukan.';
      } else {
        profile.value = data;
      }
    } catch (_) {
      errorMessage.value = 'Gagal memuat profil. Coba lagi.';
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> _fetchReviews() async {
    try {
      isLoadingReviews.value = true;
      final data = await _service.fetchUserReviews(_userId);
      reviews.assignAll(data);
    } catch (_) {
      // Gagal load review tidak fatal — profil tetap tampil
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> refresh() => _fetchAll();

  void goBack() => Get.back();
}