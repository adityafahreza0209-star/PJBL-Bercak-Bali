import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordObscured = true.obs;

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  /// Login berhasil → hapus Login dari stack, masuk ke Home
  void onLogin() {
    Get.offNamed(Routes.HOME);
  }

  /// Dari Login → Register (Login dihapus dari stack,
  /// agar Back dari Register tidak balik ke Login)
  void goToRegister() {
    Get.offNamed(Routes.REGISTER);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}