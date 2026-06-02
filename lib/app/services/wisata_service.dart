import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// KONSTANTA
// ============================================================

const _supabaseUrl = 'https://exsafhemjamjrieqdarn.supabase.co';
const _storageBucket = 'place-images';

/// Mengubah path relatif (misal: "cities/ubud.jpg")
/// menjadi public URL Supabase Storage.
String buildStorageUrl(String path) {
  if (path.startsWith('http')) return path;
  return '$_supabaseUrl/storage/v1/object/public/$_storageBucket/$path';
}

String? _nullableString(dynamic value) {
  final text = value as String?;
  final trimmed = text?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

// ============================================================
// MODEL: CityModel
// ============================================================

class CityModel {
  final String id;
  final String cityName;
  final String region;
  final String description;
  final String imageUrl; // sudah jadi full URL

  const CityModel({
    required this.id,
    required this.cityName,
    required this.region,
    required this.description,
    required this.imageUrl,
  });

  factory CityModel.fromMap(Map<String, dynamic> map) {
    final rawImage = map['image_url'] as String? ?? '';

    return CityModel(
      id: map['id'] as String,
      cityName: map['city_name'] as String,
      region: map['region'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: rawImage.isNotEmpty ? buildStorageUrl(rawImage) : '',
    );
  }

  /// Argumen yang dikirim ke DestinationCityView via Get.toNamed
  Map<String, dynamic> toArguments() => {
    'cityId': id,
    'cityName': cityName,
    'region': region,
    'description': description,
    'imageUrl': imageUrl,
  };
}

// ============================================================
// MODEL: WisataModel
// ============================================================

class WisataModel {
  final String id;
  final String? cityId;
  final String title;
  final String location;
  final String category;
  final String description;
  final String ticketPrice;
  final String openHours;
  final String duration;
  final String? googleMapsUrl;
  final double rating;
  final int totalReviews;
  final String imageUrl; // cover image, sudah full URL
  final List<String> images; // semua gambar (cover + place_images)
  final bool isFeatured;

  const WisataModel({
    required this.id,
    this.cityId,
    required this.title,
    required this.location,
    required this.category,
    required this.description,
    required this.ticketPrice,
    required this.openHours,
    required this.duration,
    this.googleMapsUrl,
    required this.rating,
    required this.totalReviews,
    required this.imageUrl,
    required this.images,
    this.isFeatured = false,
  });

  factory WisataModel.fromMap(Map<String, dynamic> map) {
    // ── Gambar tambahan dari tabel place_images ──────────────
    final rawExtraImages = map['place_images'] as List<dynamic>? ?? [];
    final extraImages = rawExtraImages.map((e) {
      final url = (e as Map<String, dynamic>)['image_url'] as String;
      return buildStorageUrl(url);
    }).toList();

    // ── Cover image dari kolom image_url ─────────────────────
    final rawCover = map['image_url'] as String? ?? '';
    final cover = rawCover.isNotEmpty ? buildStorageUrl(rawCover) : '';

    // ── Gabungkan: cover dulu, lalu sisanya tanpa duplikat ────
    final allImages = [
      if (cover.isNotEmpty) cover,
      ...extraImages.where((url) => url != cover),
    ];

    return WisataModel(
      id: map['id'] as String,
      cityId: map['city_id'] as String?,
      title: map['title'] as String,
      location: map['location'] as String? ?? '',
      category: map['category'] as String? ?? '',
      description: map['description'] as String? ?? '',
      ticketPrice: map['ticket_price'] as String? ?? '',
      openHours: map['open_hours'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      googleMapsUrl: _nullableString(map['google_maps_url']),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: map['total_reviews'] as int? ?? 0,
      imageUrl: cover,
      images: allImages.isNotEmpty ? allImages : [],
      isFeatured: map['is_featured'] as bool? ?? false,
    );
  }

  /// Argumen yang dikirim ke DetailWisataView via Get.toNamed
  Map<String, dynamic> toArguments() => {'wisataId': id};
}

// ============================================================
// SERVICE: WisataService
// ============================================================

class WisataService {
  // Singleton
  static final WisataService _instance = WisataService._internal();
  factory WisataService() => _instance;
  WisataService._internal();

  final SupabaseClient _db = Supabase.instance.client;

  // Query wisata lengkap termasuk gambar tambahan
  static const _wisataSelect = '''
    id,
    city_id,
    title,
    location,
    category,
    description,
    ticket_price,
    open_hours,
    duration,
    google_maps_url,
    rating,
    total_reviews,
    image_url,
    is_featured,
    place_images (
      image_url,
      sort_order
    )
  ''';

  // ── CITIES ─────────────────────────────────────────────────

  /// Ambil semua kota, diurutkan berdasarkan nama.
  Future<List<CityModel>> fetchAllCities() async {
    final res = await _db
        .from('cities')
        .select('id, city_name, region, description, image_url')
        .order('city_name');

    return (res as List)
        .map((e) => CityModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Ambil satu kota berdasarkan ID.
  Future<CityModel?> fetchCityById(String cityId) async {
    final res = await _db
        .from('cities')
        .select('id, city_name, region, description, image_url')
        .eq('id', cityId)
        .maybeSingle();

    return res != null ? CityModel.fromMap(res) : null;
  }

  // ── WISATA ─────────────────────────────────────────────────

  /// Ambil wisata unggulan (is_featured = true), diurutkan rating.
  Future<List<WisataModel>> fetchFeaturedWisata() async {
    final res = await _db
        .from('wisata')
        .select(_wisataSelect)
        .eq('is_featured', true)
        .order('rating', ascending: false);

    return _toWisataList(res);
  }

  /// Ambil semua wisata, diurutkan rating.
  Future<List<WisataModel>> fetchAllWisata() async {
    final res = await _db
        .from('wisata')
        .select(_wisataSelect)
        .order('rating', ascending: false);

    return _toWisataList(res);
  }

  /// Ambil wisata berdasarkan city_id.
  Future<List<WisataModel>> fetchWisataByCityId(String cityId) async {
    final res = await _db
        .from('wisata')
        .select(_wisataSelect)
        .eq('city_id', cityId)
        .order('rating', ascending: false);

    return _toWisataList(res);
  }

  /// Ambil detail satu wisata berdasarkan ID.
  Future<WisataModel?> fetchWisataById(String wisataId) async {
    final res = await _db
        .from('wisata')
        .select(_wisataSelect)
        .eq('id', wisataId)
        .maybeSingle();

    return res != null ? WisataModel.fromMap(res) : null;
  }

  List<WisataModel> _toWisataList(List<dynamic> res) {
    return res
        .map((e) => WisataModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ── REVIEWS (wisata) ────────────────────────────────────────

  /// Ambil semua review untuk wisata tertentu.
  Future<List<Map<String, dynamic>>> fetchReviews(String wisataId) async {
    final res = await _db
        .from('reviews')
        .select('''
          id,
          user_id,
          rating,
          title,
          comment,
          useful_count,
          created_at,
          profiles (
            full_name,
            avatar_url
          )
        ''')
        .eq('place_type', 'wisata')
        .eq('wisata_id', wisataId)
        .order('created_at', ascending: false);

    return (res as List).cast<Map<String, dynamic>>();
  }

  /// Tambah review baru untuk wisata.
  Future<void> addReview({
    required String wisataId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    await _db.from('reviews').insert({
      'place_type': 'wisata',
      'wisata_id': wisataId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    });
  }

  // ── USEFUL VOTES ────────────────────────────────────────────

  /// Ambil semua review_id yang sudah di-vote oleh user ini.
  Future<Set<String>> fetchUserVotes(String userId) async {
    final res = await _db
        .from('review_useful_votes')
        .select('review_id')
        .eq('user_id', userId);

    return (res as List).map((e) => e['review_id'] as String).toSet();
  }

  Future<void> addVote({
    required String reviewId,
    required String userId,
  }) async {
    await _db.from('review_useful_votes').insert({
      'review_id': reviewId,
      'user_id': userId,
    });
  }

  Future<void> removeVote({
    required String reviewId,
    required String userId,
  }) async {
    await _db
        .from('review_useful_votes')
        .delete()
        .eq('review_id', reviewId)
        .eq('user_id', userId);
  }

  // ── SAVED PLACES ────────────────────────────────────────────

  Future<bool> isSaved({
    required String wisataId,
    required String userId,
  }) async {
    final res = await _db
        .from('saved_places')
        .select('id')
        .eq('place_type', 'wisata')
        .eq('wisata_id', wisataId)
        .eq('user_id', userId)
        .maybeSingle();

    return res != null;
  }

  Future<void> savePlace({
    required String wisataId,
    required String userId,
  }) async {
    await _db.from('saved_places').insert({
      'place_type': 'wisata',
      'wisata_id': wisataId,
      'user_id': userId,
    });
  }

  Future<void> unsavePlace({
    required String wisataId,
    required String userId,
  }) async {
    await _db
        .from('saved_places')
        .delete()
        .eq('place_type', 'wisata')
        .eq('wisata_id', wisataId)
        .eq('user_id', userId);
  }

  // ── VISIT HISTORY ───────────────────────────────────────────

  Future<void> recordVisit({
    required String wisataId,
    required String userId,
  }) async {
    await _db.from('visit_histories').insert({
      'place_type': 'wisata',
      'wisata_id': wisataId,
      'user_id': userId,
      'visited_at': DateTime.now().toIso8601String(),
    });
  }
}
