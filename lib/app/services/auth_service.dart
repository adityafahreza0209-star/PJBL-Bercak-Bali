import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_pages.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final _supabase = Supabase.instance.client;

  final Rx<User?> currentUser = Rx<User?>(null);
  final isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Set user awal
    currentUser.value = _supabase.auth.currentUser;
    isLoggedIn.value = currentUser.value != null;

    // Listen perubahan auth state
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      currentUser.value = session?.user;
      isLoggedIn.value = session?.user != null;

      if (event == AuthChangeEvent.signedIn) {
        Get.offAllNamed(Routes.HOME);
      } else if (event == AuthChangeEvent.signedOut) {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  // ============================================================
  // EMAIL & PASSWORD
  // ============================================================

  /// Register dengan email & password
  Future<AuthResponse> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    return response;
  }

  /// Login dengan email & password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // ============================================================
  // GOOGLE OAUTH
  // ============================================================

  /// Login / Register dengan Google
  Future<bool> signInWithGoogle() async {
    final response = await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.bercakbali://login-callback',
    );
    return response;
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ============================================================
  // HELPER
  // ============================================================

  String get userId => currentUser.value?.id ?? '';
  String get userEmail => currentUser.value?.email ?? '';
  String get userFullName =>
      currentUser.value?.userMetadata?['full_name'] as String? ??
      currentUser.value?.email?.split('@').first ??
      'Pengguna';
  String? get userAvatarUrl =>
      currentUser.value?.userMetadata?['avatar_url'] as String?;

  /// Tampilkan dialog/snackbar lalu redirect ke login
  /// Digunakan saat user belum login tapi mencoba aksi terproteksi
  void requireLogin({String? message}) {
    Get.snackbar(
      'Login Diperlukan',
      message ?? 'Silakan login terlebih dahulu untuk melanjutkan.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(seconds: 1), () {
      Get.toNamed(Routes.LOGIN);
    });
  }
}
