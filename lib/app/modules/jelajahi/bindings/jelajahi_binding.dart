import 'package:get/get.dart';
import '../controllers/jelajahi_controller.dart';

class JelajahiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JelajahiController>(() => JelajahiController());
  }
}