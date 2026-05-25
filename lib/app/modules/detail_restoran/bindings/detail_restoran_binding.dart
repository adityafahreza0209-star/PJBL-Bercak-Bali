import 'package:get/get.dart';
import '../controllers/detail_restoran_controller.dart';

class DetailRestoranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailRestoranController>(() => DetailRestoranController());
  }
}
