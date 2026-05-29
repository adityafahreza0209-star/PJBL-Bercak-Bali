import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {

  @override
  void onInit() {
    super.onInit();

    Future.delayed(
      const Duration(milliseconds: 2500),
      _navigate,
    );
  }

  void _navigate() {
    Get.offAllNamed(Routes.HOME);
  }
}