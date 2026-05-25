import 'package:get/get.dart';

import '../controllers/privacy_security_controller.dart';

class PrivacySecurityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivacySecurityController>(
      () => PrivacySecurityController(),
    );
  }
}
