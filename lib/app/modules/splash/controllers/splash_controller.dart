import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 4000), () {
      // Splash selesai → buang dari stack, ganti ke Login
      Get.offNamed(Routes.LOGIN);
    });
  }
}