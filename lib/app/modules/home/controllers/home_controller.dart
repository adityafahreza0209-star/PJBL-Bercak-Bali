import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final isSearching = false.obs;

  // ============================================================
  // DATA KOTA
  // ============================================================
  final List<Map<String, dynamic>> cities = const [
    {
      'cityName': 'Ubud',
      'region': 'Gianyar',
      'image': 'assets/images/tegalalang.jpg',
      'description':
          'Ubud adalah pusat seni dan budaya Bali, dikelilingi sawah terasering dan hutan tropis. Dikenal sebagai destinasi yoga dan wellness dunia.',
    },
    {
      'cityName': 'Denpasar',
      'region': 'Denpasar',
      'image': 'assets/images/denpasar.jpg',
      'description':
          'Denpasar adalah ibu kota Bali yang modern namun kaya tradisi. Pusat perdagangan, kuliner, dan seni budaya Bali yang autentik.',
    },
    {
      'cityName': 'Kuta',
      'region': 'Badung',
      'image': 'assets/images/kuta.jpg',
      'description':
          'Kuta dikenal dengan pantainya yang ramai, sunset yang memukau, dan kehidupan malam yang semarak. Surga bagi peselancar pemula.',
    },
    {
      'cityName': 'Gianyar',
      'region': 'Gianyar',
      'image': 'assets/images/gianyar.jpg',
      'description':
          'Gianyar adalah kabupaten seni dengan pengrajin batik, perak, dan ukiran kayu terbaik Bali. Rumah bagi Tegalalang dan pasar seni tradisional.',
    },
  ];

  // ============================================================
  // DATA TERAKHIR DILIHAT
  // ============================================================
  final List<Map<String, dynamic>> recentDestinations = const [
    {
      'image': 'assets/images/tegalalang.jpg',
      'title': 'Tegalalang Rice Terrace',
      'location': 'Gianyar, Bali',
      'rating': '4.7',
      'category': 'Alam • Sawah',
      'detailImages': [
        'assets/images/tegalalang.jpg',
        'assets/images/denpasar.jpg',
        'assets/images/tanahlot.jpg',
      ],
    },
    {
      'image': 'assets/images/uluwatu.jpg',
      'title': 'Pura Uluwatu',
      'location': 'Badung, Bali',
      'rating': '4.8',
      'category': 'Budaya • Pura',
      'detailImages': [
        'assets/images/uluwatu.jpg',
        'assets/images/tanahlot.jpg',
        'assets/images/kelingking.jpg',
      ],
    },
  ];

  // ============================================================
  // DATA DESTINASI POPULER
  // ============================================================
  final List<Map<String, dynamic>> popularDestinations = const [
    {
      'image': 'assets/images/kelingking.jpg',
      'title': 'Pantai Kelingking',
      'location': 'Nusa Penida',
      'rating': '4.9',
      'reviews': '4.2k',
      'badge': 'TRENDING',
    },
    {
      'image': 'assets/images/tanahlot.jpg',
      'title': 'Tanah Lot',
      'location': 'Tabanan',
      'rating': '4.7',
      'reviews': '5.8k',
      'badge': 'POPULER',
    },
    {
      'image': 'assets/images/tegalalang.jpg',
      'title': 'Campuhan Ridge',
      'location': 'Ubud',
      'rating': '4.6',
      'reviews': '1.9k',
      'badge': 'HITS',
    },
  ];

  // ============================================================
  // DATA RESTORAN TERBAIK
  // ============================================================
  final List<Map<String, dynamic>> topRestaurants = const [
    {
      'image': 'assets/images/restoran1.jpg',
      'name': 'Warung Babi Guling Ibu Oka',
      'cuisine': 'Babi Guling • Bali',
      'distance': '0.8 km',
      'rating': '4.8',
      'priceRange': 'Rp 50-150k',
      'location': 'Jl. Raya Ubud No. 88, Gianyar, Bali',
      'description':
          'Warung Babi Guling Ibu Oka adalah restoran populer di Bali yang menyajikan hidangan khas Indonesia dengan cita rasa autentik.',
      'detailImages': [
        'assets/images/restoran1.jpg',
        'assets/images/restoran2.jpg',
        'assets/images/restoran3.jpg',
      ],
    },
    {
      'image': 'assets/images/restoran2.jpg',
      'name': 'Bebek Bengil Dirty Duck',
      'cuisine': 'Bebek • Indonesia',
      'distance': '1.2 km',
      'rating': '4.7',
      'priceRange': 'Rp 100-250k',
      'location': 'Jl. Hanoman, Ubud, Bali',
      'description':
          'Bebek Bengil Dirty Duck adalah restoran populer di Bali yang menyajikan hidangan bebek lezat dengan suasana sawah yang khas.',
      'detailImages': [
        'assets/images/restoran2.jpg',
        'assets/images/restoran1.jpg',
        'assets/images/restoran3.jpg',
      ],
    },
    {
      'image': 'assets/images/restoran3.jpg',
      'name': 'La Favela',
      'cuisine': 'Fusion • Barat',
      'distance': '2.1 km',
      'rating': '4.6',
      'priceRange': 'Rp 150-300k',
      'location': 'Jl. Kayu Aya, Seminyak, Bali',
      'description':
          'La Favela adalah restoran populer di Bali yang menyajikan hidangan fusion dengan dekorasi artistik dan suasana yang unik.',
      'detailImages': [
        'assets/images/restoran3.jpg',
        'assets/images/restoran1.jpg',
        'assets/images/restoran2.jpg',
      ],
    },
  ];

  void onSearchChanged(String value) {
    isSearching.value = value.isNotEmpty;
  }

  void clearSearch() {
    searchController.clear();
    isSearching.value = false;
  }

  void goToDetailWisata(Map<String, dynamic> data) {
    // Get.toNamed: wisata bisa di-back ke Home
    Get.toNamed(Routes.DETAIL_WISATA, arguments: data);
  }

  void goToDetailRestoran(Map<String, dynamic> data) {
    // Get.toNamed: restoran bisa di-back ke Home
    Get.toNamed(Routes.DETAIL_RESTORAN, arguments: data);
  }

  void goToDestinationCity(Map<String, dynamic> data) {
    // Get.toNamed: detail kota bisa di-back ke Home
    Get.toNamed(Routes.DESTINATION_CITY, arguments: data);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
