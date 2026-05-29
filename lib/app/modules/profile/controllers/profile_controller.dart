import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/profile_service.dart';

class ProfileController extends GetxController {
  // ── State profil ─────────────────────────────────────────────
  final isLoadingProfile = true.obs;
  final profile = Rxn<ProfileData>();

  // ── State activity counts ────────────────────────────────────
  final isLoadingCounts = true.obs;
  final counts = const ActivityCount.empty().obs;

  final _service = ProfileService();

  @override
  void onInit() {
    super.onInit();
    // Listen perubahan login state — jika user login/logout,
    // langsung refresh data tanpa perlu reload seluruh halaman
    ever(AuthService.to.isLoggedIn, (_) => _onAuthChanged());
    _onAuthChanged();
  }

  // ── INTERNAL ─────────────────────────────────────────────────

  void _onAuthChanged() {
    if (AuthService.to.isLoggedIn.value) {
      _fetchAll();
    } else {
      // Reset semua state saat logout
      profile.value = null;
      counts.value = const ActivityCount.empty();
      isLoadingProfile.value = false;
      isLoadingCounts.value = false;
    }
  }

  Future<void> _fetchAll() async {
    // Profil & counts diload paralel
    await Future.wait([
      _fetchProfile(),
      _fetchCounts(),
    ]);
  }

  Future<void> _fetchProfile() async {
    try {
      isLoadingProfile.value = true;
      final data = await _service.fetchProfile(AuthService.to.userId);
      profile.value = data;
    } catch (_) {
      // Profil gagal dimuat — UI tetap tampil dengan data kosong
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> _fetchCounts() async {
    try {
      isLoadingCounts.value = true;
      final data =
          await _service.fetchActivityCounts(AuthService.to.userId);
      counts.value = data;
    } catch (_) {
      counts.value = const ActivityCount.empty();
    } finally {
      isLoadingCounts.value = false;
    }
  }

  // ── AKSI ─────────────────────────────────────────────────────

  /// Refresh manual (pull-to-refresh)
  Future<void> refresh() => _fetchAll();

  void goToEditProfile() => Get.toNamed(Routes.EDIT_PROFILE);

  void goToSettings() => Get.toNamed(Routes.SETTINGS);

  void goToSavedPlaces() => Get.toNamed(Routes.SIMPAN);

  void goToVisitHistory() => Get.toNamed(Routes.HISTORY);

  void goToMyReviews() => Get.toNamed(Routes.MY_REVIEWS);

  Future<void> signOut() async {
    await AuthService.to.signOut();
    // AuthService listener akan redirect ke LOGIN otomatis
  }
}