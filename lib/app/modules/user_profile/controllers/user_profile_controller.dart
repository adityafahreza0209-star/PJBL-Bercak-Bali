import 'package:get/get.dart';

class UserProfileController extends GetxController {
  // Data user yang akan ditampilkan
  late Map<String, dynamic> userData;
  late List<Map<String, dynamic>> userReviews;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final userId = args?['userId'] ?? 'user_unknown';

    // Data dummy users (nanti dari Supabase)
    final Map<String, Map<String, dynamic>> users = {
      'user_made': {
        'id': 'user_made',
        'name': 'Made',
        'bio': 'Food enthusiast yang suka mencoba kuliner baru di Bali. Instagram: @made_foodie',
        'memberSince': 'Januari 2026',
        'location': 'Denpasar, Bali',
        'totalReviews': 3,
      },
      'user_ketut': {
        'id': 'user_ketut',
        'name': 'Ketut',
        'bio': 'Traveler & photographer. Capturing the beauty of Bali one click at a time.',
        'memberSince': 'Desember 2025',
        'location': 'Ubud, Bali',
        'totalReviews': 5,
      },
      'user_wayan': {
        'id': 'user_wayan',
        'name': 'Wayan',
        'bio': 'Local guide yang senang berbagi tempat-tempat tersembunyi di Bali.',
        'memberSince': 'November 2025',
        'location': 'Seminyak, Bali',
        'totalReviews': 8,
      },
      'user_wily': {
        'id': 'user_wily',
        'name': 'Wily',
        'bio': 'Backpacker dari Jakarta. Suka trekking dan pantai.',
        'memberSince': 'Oktober 2025',
        'location': 'Jakarta',
        'totalReviews': 12,
      },
      'user_yuri': {
        'id': 'user_yuri',
        'name': 'Yuri',
        'bio': 'Digital nomad yang sedang menjelajahi Bali selama 3 bulan.',
        'memberSince': 'Desember 2025',
        'location': 'Canggu, Bali',
        'totalReviews': 6,
      },
      'user_akbar': {
        'id': 'user_akbar',
        'name': 'Akbar',
        'bio': 'Suka traveling dan kuliner. Review jujur tanpa basa-basi!',
        'memberSince': 'September 2025',
        'location': 'Surabaya',
        'totalReviews': 15,
      },
      'user_unknown': {
        'id': 'user_unknown',
        'name': 'Pengguna Bercak',
        'bio': 'Penikmat wisata Bali',
        'memberSince': '2026',
        'location': 'Bali',
        'totalReviews': 0,
      },
    };

    // Reviews per user (nanti dari Supabase join)
    final Map<String, List<Map<String, dynamic>>> reviewsDb = {
      'user_made': [
        {
          'id': 'r_made_1',
          'placeName': 'Bebek Bengil Dirty Duck',
          'rating': 5,
          'date': 'Feb 2026',
          'review': 'Bebeknya crispy banget! Sambalnya mantap. Wajib coba!',
          'image': 'assets/images/restoran2.jpg',
        },
        {
          'id': 'r_made_2',
          'placeName': 'Warung Babi Guling Ibu Oka',
          'rating': 4,
          'date': 'Jan 2026',
          'review': 'Enak tapi antrian panjang. Datang pagi lebih baik.',
          'image': 'assets/images/restoran1.jpg',
        },
      ],
      'user_ketut': [
        {
          'id': 'r_ketut_1',
          'placeName': 'Pantai Kelingking',
          'rating': 5,
          'date': 'Jan 2026',
          'review': 'Sunset terbaik! Turun ke pantai cukup ekstrim tapi worth it.',
          'image': 'assets/images/kelingking.jpg',
        },
      ],
      'user_wayan': [
        {
          'id': 'r_wayan_1',
          'placeName': 'Tegalalang Rice Terrace',
          'rating': 5,
          'date': 'Des 2025',
          'review': 'Sawah terasering yang indah. Datang pagi untuk menghindari keramaian.',
          'image': 'assets/images/tegalalang.jpg',
        },
        {
          'id': 'r_wayan_2',
          'placeName': 'Tanah Lot',
          'rating': 5,
          'date': 'Nov 2025',
          'review': 'Pura di atas batu karang sangat ikonik. Sunset terbaik!',
          'image': 'assets/images/tanahlot.jpg',
        },
      ],
      'user_wily': [
        {
          'id': 'r_wily_1',
          'placeName': 'Pura Uluwatu',
          'rating': 5,
          'date': 'Jan 2025',
          'review': 'Pemandangan tebing lautnya spektakuler. Tari kecak recommended.',
          'image': 'assets/images/uluwatu.jpg',
        },
      ],
      'user_yuri': [
        {
          'id': 'r_yuri_1',
          'placeName': 'Pantai Kelingking',
          'rating': 4,
          'date': 'Des 2024',
          'review': 'Indah banget tapi aksesnya lumayan berat.',
          'image': 'assets/images/kelingking.jpg',
        },
      ],
      'user_akbar': [
        {
          'id': 'r_akbar_1',
          'placeName': 'La Favela',
          'rating': 5,
          'date': 'Feb 2026',
          'review': 'Dekorasi unik, live music seru. Harga reasonable.',
          'image': 'assets/images/restoran3.jpg',
        },
        {
          'id': 'r_akbar_2',
          'placeName': 'Tegalalang Rice Terrace',
          'rating': 4,
          'date': 'Jan 2026',
          'review': 'Bagus untuk foto, sayang cukup ramai turis.',
          'image': 'assets/images/tegalalang.jpg',
        },
      ],
    };

    // Assign data dengan pengecekan null yang aman
    userData = users[userId] ?? users['user_unknown']!;
    
    // Ambil reviews, jika tidak ada maka return list kosong
    if (reviewsDb.containsKey(userId)) {
      userReviews = reviewsDb[userId]!;
    } else {
      userReviews = [];
    }
  }

  String getInitial() {
    final name = userData['name'] as String? ?? '';
    if (name.isEmpty) return 'U';
    return name[0].toUpperCase();
  }

  void goBack() => Get.back();
}