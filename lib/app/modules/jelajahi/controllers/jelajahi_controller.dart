import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class JelajahiController extends GetxController {
  final searchController = TextEditingController();
  final searchFocus = FocusNode();
  final searchFocusNode = FocusNode();
  final selectedCategory = 'Semua'.obs;

  final List<Map<String, dynamic>> categories = const [ 
    {'name': 'Semua', 'icon': Icons.apps},
    {'name': 'Pantai', 'icon': Icons.beach_access},
    {'name': 'Gunung', 'icon': Icons.landscape},
    {'name': 'Kuliner', 'icon': Icons.restaurant},
    {'name': 'Budaya', 'icon': Icons.temple_buddhist},
    {'name': 'Hotel', 'icon': Icons.hotel},
  ];

  final List<Map<String, dynamic>> destinations = const [
    {
      'title': 'Pantai Kuta',
      'location': 'Badung, Bali',
      'image':
          'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
      'category': 'Pantai',
      'rating': 4.8,
      'reviews': 1250,
    },
    {
      'title': 'Pura Tanah Lot',
      'location': 'Tabanan, Bali',
      'image':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
      'category': 'Budaya',
      'rating': 4.9,
      'reviews': 2100,
    },
    {
      'title': 'Gunung Batur',
      'location': 'Kintamani, Bali',
      'image':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      'category': 'Gunung',
      'rating': 4.7,
      'reviews': 890,
    },
    {
      'title': 'Bebek Bengil',
      'location': 'Ubud, Bali',
      'image':
          'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=800',
      'category': 'Kuliner',
      'rating': 4.6,
      'reviews': 750,
    },
    {
      'title': 'Tegalalang Rice Terrace',
      'location': 'Ubud, Bali',
      'image':
          'https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=800',
      'category': 'Budaya',
      'rating': 4.8,
      'reviews': 1560,
    },
    {
      'title': 'Nusa Dua Beach',
      'location': 'Nusa Dua, Bali',
      'image':
          'https://images.unsplash.com/photo-1590523741831-ab7e8b8f9c7f?w=800',
      'category': 'Pantai',
      'rating': 4.7,
      'reviews': 980,
    },
  ];

  List<Map<String, dynamic>> get filteredDestinations {
    if (selectedCategory.value == 'Semua') return destinations;
    return destinations
        .where((d) => d['category'] == selectedCategory.value)
        .toList();
  }

  void selectCategory(String name) {
    selectedCategory.value = name;
  }

  void activateSearch() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (searchFocusNode.hasFocus == false) {
        searchFocusNode.requestFocus();
      }
    });
  }

  void goToDetailWisata(Map<String, dynamic> data) {
    Get.toNamed(Routes.DETAIL_WISATA, arguments: data);
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocus.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
}