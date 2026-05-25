import 'package:get/get.dart';
import '../controllers/simpan_controller.dart';

class SimpanBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SimpanController(), permanent: false);
  }
}