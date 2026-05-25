import 'package:get/get.dart';

class SimpanController extends GetxController {
  // Gunakan RxList agar bisa dideteksi Obx
  var selectedTab = 'Semua'.obs;
  
  final List<String> categories = const [
    'Semua', 'Alam', 'Pantai', 'Budaya', 'Hidden Gem', 'Restoran'
  ];
  
  // Gunakan RxList
  var savedItems = <Map<String, dynamic>>[
    {
      'image': 'assets/images/tegalalang.jpg',
      'title': 'Tegalalang Rice Terrace',
      'location': 'Gianyar, Bali',
      'rating': '4.7',
      'savedDate': '2 hari lalu',
      'category': 'Alam',
    },
    {
      'image': 'assets/images/kelingking.jpg',
      'title': 'Pantai Kelingking',
      'location': 'Nusa Penida, Bali',
      'rating': '4.9',
      'savedDate': '5 hari lalu',
      'category': 'Pantai',
    },
    {
      'image': 'assets/images/uluwatu.jpg',
      'title': 'Pura Uluwatu',
      'location': 'Badung, Bali',
      'rating': '4.8',
      'savedDate': '1 minggu lalu',
      'category': 'Budaya',
    },
    {
      'image': 'assets/images/lahangan.jpg',
      'title': 'Lahangan Sweet',
      'location': 'Karangasem, Bali',
      'rating': '4.8',
      'savedDate': '2 minggu lalu',
      'category': 'Hidden Gem',
    },
    {
      'image': 'assets/images/restoran1.jpg',
      'title': 'Warung Babi Guling Ibu Oka',
      'location': 'Ubud, Bali',
      'rating': '4.8',
      'savedDate': '3 hari lalu',
      'category': 'Restoran',
    },
    {
      'image': 'assets/images/restoran2.jpg',
      'title': 'Bebek Bengil Dirty Duck',
      'location': 'Ubud, Bali',
      'rating': '4.7',
      'savedDate': '1 minggu lalu',
      'category': 'Restoran',
    },
    {
      'image': 'assets/images/restoran3.jpg',
      'title': 'La Favela',
      'location': 'Seminyak, Bali',
      'rating': '4.6',
      'savedDate': '2 minggu lalu',
      'category': 'Restoran',
    },
    {
      'image': 'assets/images/denpasar.jpg',
      'title': 'Tukad Cepung Waterfall',
      'location': 'Bangli, Bali',
      'rating': '4.7',
      'savedDate': '3 minggu lalu',
      'category': 'Alam',
    },
  ].obs; // <-- OBS di sini

  // Getter dengan .value
  List<Map<String, dynamic>> get filteredItems {
    if (selectedTab.value == 'Semua') return savedItems.toList();
    return savedItems.where((item) => item['category'] == selectedTab.value).toList();
  }

  void selectTab(String tab) {
    selectedTab.value = tab;
    update(); // Panggil update() untuk GetBuilder, atau biarkan Rx bekerja
  }

  // Tambahkan method untuk refresh jika perlu
  void refreshData() {
    savedItems.refresh();
  }
}