import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
 
class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordObscured = true.obs;
  final isLoading = false.obs;
 
  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }
 
  // ── Email & Password Login ───────────────────────────────────
  Future<void> onLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
 
    if (email.isEmpty || password.isEmpty) {
      _showError('Email dan password tidak boleh kosong.');
      return;
    }
 
    isLoading.value = true;
    try {
      final response = await AuthService.to.signInWithEmail(
        email: email,
        password: password,
      );
 
      if (response.user != null) {
        Get.offNamed(Routes.HOME);
      }
    } on AuthException catch (e) {
      _showError(_translateAuthError(e.message));
    } catch (_) {
      _showError('Terjadi kesalahan. Coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }
 
  // ── Google Login ─────────────────────────────────────────────
  Future<void> onLoginWithGoogle() async {
    isLoading.value = true;
    try {
      await AuthService.to.signInWithGoogle();
      // Redirect ditangani oleh onAuthStateChange di AuthService
    } catch (_) {
      _showError('Login dengan Google gagal. Coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }
 
  /// Dari Login → Register
  void goToRegister() {
    Get.offNamed(Routes.REGISTER);
  }
 
  // ── Helpers ──────────────────────────────────────────────────
  void _showError(String message) {
    Get.snackbar(
      'Login Gagal',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2A2A2A),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
 
  String _translateAuthError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password')) {
      return 'Email atau password salah.';
    } else if (msg.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek inbox email kamu.';
    } else if (msg.contains('too many requests')) {
      return 'Terlalu banyak percobaan. Tunggu beberapa saat.';
    }
    return message;
  }
 
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}