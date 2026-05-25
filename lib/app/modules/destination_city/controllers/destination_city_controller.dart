import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';

class DestinationCityController extends GetxController {
  // Data diterima dari arguments Get.toNamed
  late String cityName;
  late String region;
  late String image;
  late String description;

  // Data restoran rekomendasi
  final List<Map<String, dynamic>> recommendedRestaurants = const [
    {
      'name': 'Motel Mexicola Seminyak',
      'rating': '4.1',
      'reviews': '5.865',
      'cuisine': 'Meksiko • Bar',
      'price': 'Rp 150-300k',
      'location': 'Seminyak, Indonesia',
      'image': 'assets/images/restoran3.jpg',
      'distance': '0.5 km',
    },
    {
      'name': 'Waroeng Berna',
      'rating': '4.9',
      'reviews': '3.333',
      'cuisine': 'Indonesia',
      'price': 'Rp 50-150k',
      'location': 'Seminyak, Indonesia',
      'image': 'assets/images/restoran1.jpg',
      'distance': '1.2 km',
    },
    {
      'name': 'La Favela',
      'rating': '4.6',
      'reviews': '2.100',
      'cuisine': 'Fusion • Barat',
      'price': 'Rp 200-400k',
      'location': 'Seminyak, Indonesia',
      'image': 'assets/images/restoran2.jpg',
      'distance': '2.0 km',
    },
  ];

  // Data wisata rekomendasi
  final List<Map<String, dynamic>> recommendedAttractions = const [
    {
      'name': 'Pantai Kelingking',
      'rating': '4.6',
      'reviews': '1.721',
      'category': 'Pantai',
      'location': 'Nusa Penida, Indonesia',
      'image': 'assets/images/kelingking.jpg',
      'price': 'Rp 15.000',
    },
    {
      'name': 'Tanah Lot',
      'rating': '4.2',
      'reviews': '11.000',
      'category': 'Tempat Menarik',
      'location': 'Beraban, Indonesia',
      'image': 'assets/images/tanahlot.jpg',
      'price': 'Rp 30.000',
    },
    {
      'name': 'Tegalalang Rice Terrace',
      'rating': '4.7',
      'reviews': '8.500',
      'category': 'Alam',
      'location': 'Ubud, Indonesia',
      'image': 'assets/images/tegalalang.jpg',
      'price': 'Rp 25.000',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      cityName = args['cityName'] ?? '';
      region = args['region'] ?? '';
      image = args['image'] ?? '';
      description = args['description'] ?? '';
    }
  }

  void goBack() => Get.back();

  void goToDetailRestoran(Map<String, dynamic> resto) {
    final data = {
      'images': const [
        'assets/images/restoran1.jpg',
        'assets/images/restoran2.jpg',
        'assets/images/restoran3.jpg',
      ],
      'name': resto['name'],
      'location': resto['location'],
      'cuisine': resto['cuisine'],
      'rating': resto['rating'],
      'priceRange': resto['price'],
      'distance': resto['distance'],
      'description':
          '${resto['name']} adalah restoran rekomendasi di $cityName yang menyajikan hidangan lezat dengan suasana nyaman.',
    };
    // Get.toNamed: bisa back ke DestinationCity
    Get.toNamed(Routes.DETAIL_RESTORAN, arguments: data);
  }

  void goToDetailWisata(Map<String, dynamic> wisata) {
    final data = {
      'title': wisata['name'],
      'location': wisata['location'],
      'detailImages': const [
        'assets/images/kelingking.jpg',
        'assets/images/tanahlot.jpg',
        'assets/images/tegalalang.jpg',
      ],
    };
    // Get.toNamed: bisa back ke DestinationCity
    Get.toNamed(Routes.DETAIL_WISATA, arguments: data);
  }
}
