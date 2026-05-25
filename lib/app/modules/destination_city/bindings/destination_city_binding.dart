import 'package:get/get.dart';
import '../controllers/destination_city_controller.dart';

class DestinationCityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DestinationCityController>(
        () => DestinationCityController());
  }
}
