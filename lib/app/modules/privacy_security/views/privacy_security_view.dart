import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../controllers/privacy_security_controller.dart';

class PrivacySecurityView extends GetView<PrivacySecurityController> {
  const PrivacySecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: controller.goBack,
        ),
        title: const Text('Privasi & Keamanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: AppColors.white54),
            const SizedBox(height: 20),
            const Text('Halaman ini akan segera hadir', style: TextStyle(color: AppColors.white70)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: controller.goBack,
              child: const Text('Kembali', style: TextStyle(color: AppColors.primaryColor)),
            ),
          ],
        ),
      ),
    );
  }
}