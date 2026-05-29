import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
 
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
 
  static const Color _primaryColor = Color(0xFFD8A15D);
  static const Color _bgOverlay = Color(0xFF173232);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background image
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
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 240),
                  const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Email
                  _inputField(
                    icon: Icons.email_outlined,
                    hint: 'Masukkan email',
                    ctrl: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  // Password
                  Obx(() => _passwordField()),
                  const SizedBox(height: 28),
                  // Login Button
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
                            : controller.onLogin,
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
                                'Masuk',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Lupa kata sandi?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 45),
                  Center(
                    child: Text(
                      'Atau masuk dengan',
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
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.onLoginWithGoogle,
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
                  const SizedBox(height: 28),
                  // Daftar link
                  Center(
                    child: GestureDetector(
                      onTap: controller.goToRegister,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pengguna baru? ',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 15,
                              ),
                            ),
                            const TextSpan(
                              text: 'Daftar sekarang',
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
        hintText: 'Masukkan kata sandi',
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
 
  /// Logo Google sederhana dari teks berwarna
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