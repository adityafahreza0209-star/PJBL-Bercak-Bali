import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailRestoranController extends GetxController {
  // Data diterima via Get.toNamed arguments
  late List<String> images;
  late String name;
  late String location;
  late String cuisine;
  late String rating;
  late String priceRange;
  late String distance;
  late String description;

  final currentImage = 0.obs;
  final isFavorite = false.obs;

  final double dummyLat = -8.530337;
  final double dummyLng = 115.271665;
  final String phoneNumber = '+62-8123-8309-927';

  // ========== DATA REVIEWS DENGAN USEFUL COUNT ==========
  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Made',
      'userId': 'user_made',
      'rating': 5,
      'date': 'Feb 2026',
      'comment': 'Makanannya enak banget! Pelayanan cepat dan ramah. Wajib coba bebek gulainya!',
      'usefulCount': 12,
    },
    {
      'name': 'Ketut',
      'userId': 'user_ketut',
      'rating': 4,
      'date': 'Jan 2026',
      'comment': 'Suasananya nyaman, cocok untuk dinner romantis. Harga sedikit mahal tapi sesuai kualitas.',
      'usefulCount': 8,
    },
    {
      'name': 'Wayan',
      'userId': 'user_wayan',
      'rating': 5,
      'date': 'Des 2025',
      'comment': 'Sate lilitnya juara! View sawahnya bikin makan makin nikmat.',
      'usefulCount': 15,
    },
  ];

  // ========== STATE UNTUK TOMBOL BERGUNA ==========
  final usefulCounts = <int, int>{}.obs;  // index -> jumlah useful
  final userUseful = <int, bool>{}.obs;   // index -> apakah user sudah klik

  // Data menu
  final List<Map<String, dynamic>> menuItems = const [
    {
      'name': 'Bebek Goreng',
      'price': 'Rp 85.000',
      'category': 'Makanan',
      'popular': true,
    },
    {
      'name': 'Sate Lilit',
      'price': 'Rp 65.000',
      'category': 'Makanan',
      'popular': true,
    },
    {
      'name': 'Nasi Campur',
      'price': 'Rp 75.000',
      'category': 'Makanan',
      'popular': false,
    },
    {
      'name': 'Es Jeruk',
      'price': 'Rp 25.000',
      'category': 'Minuman',
      'popular': false,
    },
    {
      'name': 'Kelapa Muda',
      'price': 'Rp 35.000',
      'category': 'Minuman',
      'popular': true,
    },
  ];

  List<Map<String, dynamic>> get menuMakanan =>
      menuItems.where((item) => item['category'] == 'Makanan').toList();

  List<Map<String, dynamic>> get menuMinuman =>
      menuItems.where((item) => item['category'] == 'Minuman').toList();

  @override
  void onInit() {
    super.onInit();
    
    // Ambil arguments dari navigasi
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      images = (args['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['assets/images/restoran1.jpg'];
      name = args['name'] ?? '';
      location = args['location'] ?? '';
      cuisine = args['cuisine'] ?? '';
      rating = args['rating'] ?? '0';
      priceRange = args['priceRange'] ?? '';
      distance = args['distance'] ?? '';
      description = args['description'] ?? '';
    } else {
      images = ['assets/images/restoran1.jpg'];
      name = '';
      location = '';
      cuisine = '';
      rating = '0';
      priceRange = '';
      distance = '';
      description = '';
    }
    
    // Inisialisasi useful counts dari data reviews
    for (int i = 0; i < reviews.length; i++) {
      usefulCounts[i] = reviews[i]['usefulCount'] ?? 0;
      userUseful[i] = false;
    }
  }

  void onPageChanged(int index) {
    currentImage.value = index;
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  // ========== FUNGSI TOMBOL BERGUNA ==========
  void toggleUseful(int index) {
    if (userUseful[index] == true) {
      // Jika sudah klik, kurangi
      usefulCounts[index] = (usefulCounts[index] ?? 0) - 1;
      userUseful[index] = false;
    } else {
      // Jika belum klik, tambah
      usefulCounts[index] = (usefulCounts[index] ?? 0) + 1;
      userUseful[index] = true;
    }
    // Nanti panggil API untuk update ke Supabase
  }

  Future<void> openGoogleMaps(double lat, double lng) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak bisa membuka Google Maps';
      }
    } catch (e) {
      Get.snackbar('Error', 'Tidak bisa membuka Google Maps: $e');
    }
  }

  Future<void> callRestoran() async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Tidak bisa melakukan panggilan';
      }
    } catch (e) {
      Get.snackbar('Error', 'Tidak bisa melakukan panggilan: $e');
    }
  }

  Future<void> sharePlace() async {
    Get.snackbar('Bagikan', 'Fitur bagikan segera hadir');
  }

  void goBack() => Get.back();
}