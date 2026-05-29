// lib/app/modules/register/controllers/register_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isPasswordObscured = true.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  // ── Email & Password Register ────────────────────────────────
  Future<void> onRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Semua field harus diisi.');
      return;
    }
    if (password.length < 6) {
      _showError('Password minimal 6 karakter.');
      return;
    }
    if (password != confirmPassword) {
      _showError('Konfirmasi password tidak sama.');
      return;
    }

    isLoading.value = true;
    try {
      final response = await AuthService.to.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Jika email confirmation diaktifkan di Supabase, arahkan ke login
        // dengan pesan. Jika tidak, langsung ke home.
        if (response.session != null) {
          // Auto-confirm → langsung masuk
          Get.offNamed(Routes.HOME);
        } else {
          // Perlu konfirmasi email
          Get.offNamed(Routes.LOGIN);
          _showSuccess(
            'Pendaftaran berhasil! Cek email kamu untuk konfirmasi akun.',
          );
        }
      }
    } on AuthException catch (e) {
      _showError(_translateAuthError(e.message));
    } catch (_) {
      _showError('Terjadi kesalahan. Coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Google Register ──────────────────────────────────────────
  Future<void> onRegisterWithGoogle() async {
    isLoading.value = true;
    try {
      await AuthService.to.signInWithGoogle();
      // Redirect ditangani oleh onAuthStateChange di AuthService
    } catch (_) {
      _showError('Daftar dengan Google gagal. Coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Kembali ke Login
  void goToLogin() {
    Get.offNamed(Routes.LOGIN);
  }

  // ── Helpers ──────────────────────────────────────────────────
  void _showError(String message) {
    Get.snackbar(
      'Pendaftaran Gagal',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2A2A2A),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1A5C5C),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  String _translateAuthError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('user already registered') ||
        msg.contains('email already in use')) {
      return 'Email sudah terdaftar. Silakan login.';
    } else if (msg.contains('password should be at least')) {
      return 'Password minimal 6 karakter.';
    } else if (msg.contains('invalid email')) {
      return 'Format email tidak valid.';
    }
    return message;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
