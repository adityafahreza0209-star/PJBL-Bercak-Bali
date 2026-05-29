import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  static const Color _primaryColor = Color(0xFFD8A15D);
  static const Color _bgOverlay = Color(0xFF173232);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay
          Container(color: _bgOverlay.withOpacity(0.9)),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 180),
                  const Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _inputField(
                    icon: Icons.person_outline,
                    hint: 'Nama lengkap',
                    ctrl: controller.nameController,
                  ),
                  const SizedBox(height: 20),
                  _inputField(
                    icon: Icons.email_outlined,
                    hint: 'Email',
                    ctrl: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  Obx(() => _passwordField()),
                  const SizedBox(height: 20),
                  Obx(() => _confirmPasswordField()),
                  // Tombol Daftar
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.onRegister,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Atau daftar dengan',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Tombol Google ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.onRegisterWithGoogle,
                      icon: _googleLogo(),
                      label: const Text(
                        'Lanjutkan dengan Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: GestureDetector(
                      onTap: controller.goToLogin,
                      child: Text.rich(
                        TextSpan(
                          text: 'Sudah punya akun? ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 15,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Masuk',
                              style: TextStyle(
                                color: _primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required IconData icon,
    required String hint,
    TextEditingController? ctrl,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _primaryColor),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _primaryColor),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: controller.passwordController,
      obscureText: controller.isPasswordObscured.value,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: _primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            controller.isPasswordObscured.value
                ? Icons.visibility_off
                : Icons.visibility,
            color: _primaryColor,
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
        hintText: 'Password',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _primaryColor),
        ),
      ),
    );
  }

  Widget _confirmPasswordField() {
    return TextField(
      controller: controller.confirmPasswordController,
      obscureText: controller.isPasswordObscured.value,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: _primaryColor), // Diubah warnanya
        suffixIcon: IconButton(
          icon: Icon(
            controller.isPasswordObscured.value
                ? Icons.visibility_off
                : Icons.visibility,
            color: _primaryColor, // Diubah warnanya
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
        hintText: 'Ulangi password',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), // Diubah hintStyle-nya
        enabledBorder: const UnderlineInputBorder( // Diubah dari OutlineInputBorder ke UnderlineInputBorder
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: const UnderlineInputBorder( // Diubah dari OutlineInputBorder ke UnderlineInputBorder
          borderSide: BorderSide(color: _primaryColor),
        ),
        // Menghapus filled dan fillColor untuk konsistensi
      ),
    );
  }

  Widget _googleLogo() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}