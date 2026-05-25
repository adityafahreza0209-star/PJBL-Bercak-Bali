import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTo(int index) {
    currentIndex.value = index;
  }

  
  void changeTab(int index) {
    currentIndex.value = index;
  }
}