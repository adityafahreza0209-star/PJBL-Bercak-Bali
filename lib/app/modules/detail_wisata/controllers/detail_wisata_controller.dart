import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailWisataController extends GetxController {
  // Data diterima via Get.toNamed arguments
  late List<String> images;
  late String title;
  late String location;

  final currentImage = 0.obs;
  final isFavorite = false.obs;

  // Koordinat dummy – siap migrasi ke Supabase
  final double dummyLat = -8.409518;
  final double dummyLng = 115.188919;

  // Info operasional dummy – siap migrasi ke Supabase
  final String openHours = '08.00 – 18.00 WITA';
  final String ticketPrice = 'Rp 30.000 / orang';
  final String duration = '2 – 3 jam';
  final String category = 'Pantai • Wisata Alam';
  final String rating = '4.8';
  final int totalUlasan = 1245;

  final String description =
      'Salah satu destinasi ikonik di Bali yang menawarkan pemandangan alam yang memukau. '
      'Tempat ini selalu ramai dikunjungi wisatawan domestik maupun mancanegara, '
      'terutama saat pagi dan sore hari ketika cahaya matahari menciptakan panorama yang luar biasa indah.';

  // ========== DATA REVIEWS DENGAN USEFUL COUNT ==========
  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Wily',
      'userId': 'user_wily',
      'rating': 5,
      'date': 'Jan 2025',
      'comment': 'Tempatnya sangat indah dan bersih. Wajib dikunjungi!',
      'usefulCount': 24,
    },
    {
      'name': 'Yuri',
      'userId': 'user_yuri',
      'rating': 4,
      'date': 'Des 2024',
      'comment': 'Bagus dan nyaman, tapi cukup ramai saat akhir pekan.',
      'usefulCount': 7,
    },
    {
      'name': 'Akbar',
      'userId': 'user_akbar',
      'rating': 5,
      'date': 'Feb 2026',
      'comment': 'Pengalaman yang sangat seru, terutama saat pagi hari. Pemandangan matahari terbitnya luar biasa!',
      'usefulCount': 19,
    },
  ];

  // ========== STATE UNTUK TOMBOL BERGUNA ==========
  final usefulCounts = <int, int>{}.obs;  // index -> jumlah useful
  final userUseful = <int, bool>{}.obs;   // index -> apakah user sudah klik

  @override
  void onInit() {
    super.onInit();
    
    // Ambil arguments dari navigasi
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      images = (args['detailImages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['assets/images/kelingking.jpg'];
      title = args['title'] ?? '';
      location = args['location'] ?? '';
    } else {
      images = ['assets/images/kelingking.jpg'];
      title = '';
      location = '';
    }
    
    // Inisialisasi useful counts dari data reviews
    for (int i = 0; i < reviews.length; i++) {
      usefulCounts[i] = reviews[i]['usefulCount'] ?? 0;
      userUseful[i] = false;
    }
  }

  void onPageChanged(int index) => currentImage.value = index;
  void toggleFavorite() => isFavorite.value = !isFavorite.value;

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
    final Uri url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
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

  Future<void> sharePlace() async =>
      Get.snackbar('Bagikan', 'Fitur bagikan segera hadir');

  void goBack() => Get.back();
}