import 'package:get/get.dart';
import '../controllers/detail_wisata_controller.dart';

class DetailWisataBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailWisataController>(() => DetailWisataController());
  }
}
