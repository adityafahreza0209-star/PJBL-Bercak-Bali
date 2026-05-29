import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// MODEL
// ============================================================

/// Satu item riwayat kunjungan.
/// Bisa berisi wisata atau restoran — dibedakan via [placeType].
class VisitHistoryItem {
  final String id;
  final String placeType; // 'wisata' | 'restoran'
  final DateTime visitedAt;

  // Data tempat (salah satu pasti terisi)
  final String placeId;
  final String placeName;
  final String placeLocation;
  final String placeCategory;
  final double placeRating;
  final String placeImageUrl;

  const VisitHistoryItem({
    required this.id,
    required this.placeType,
    required this.visitedAt,
    required this.placeId,
    required this.placeName,
    required this.placeLocation,
    required this.placeCategory,
    required this.placeRating,
    required this.placeImageUrl,
  });

  factory VisitHistoryItem.fromMap(Map<String, dynamic> map) {
    const supabaseUrl = 'https://exsafhemjamjrieqdarn.supabase.co';

    final placeType = map['place_type'] as String;
    final isWisata = placeType == 'wisata';

    // Data tempat datang dari relasi (wisata atau restaurants)
    final place = (isWisata
            ? map['wisata']
            : map['restaurants']) as Map<String, dynamic>? ??
        {};

    final rawImage = place['image_url'] as String? ?? '';
    final imageUrl = rawImage.isNotEmpty
        ? (rawImage.startsWith('http')
            ? rawImage
            : '$supabaseUrl/storage/v1/object/public/place-images/$rawImage')
        : '';

    return VisitHistoryItem(
      id: map['id'] as String,
      placeType: placeType,
      visitedAt: DateTime.parse(map['visited_at'] as String),
      placeId: place['id'] as String? ?? '',
      placeName: isWisata
          ? place['title'] as String? ?? ''
          : place['name'] as String? ?? '',
      placeLocation: place['location'] as String? ?? '',
      placeCategory: isWisata
          ? place['category'] as String? ?? 'Wisata'
          : place['cuisine'] as String? ?? 'Restoran',
      placeRating: (place['rating'] as num?)?.toDouble() ?? 0.0,
      placeImageUrl: imageUrl,
    );
  }

  /// Format tanggal: "12 Februari 2026"
  String get visitDateFormatted {
    const months = [
      '',
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${visitedAt.day} ${months[visitedAt.month]} ${visitedAt.year}';
  }

  bool get isWisata => placeType == 'wisata';
}

// ============================================================
// SERVICE
// ============================================================

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final SupabaseClient _db = Supabase.instance.client;

  // Fetch visit history dengan join ke wisata/restaurants.
  // Diurutkan dari yang paling baru.
  Future<List<VisitHistoryItem>> fetchHistory(String userId) async {
    final res = await _db
        .from('visit_histories')
        .select('''
          id,
          place_type,
          visited_at,
          wisata (
            id,
            title,
            location,
            category,
            rating,
            image_url
          ),
          restaurants (
            id,
            name,
            location,
            cuisine,
            rating,
            image_url
          )
        ''')
        .eq('user_id', userId)
        .order('visited_at', ascending: false);

    return (res as List)
        .map((e) => VisitHistoryItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Hapus satu item riwayat berdasarkan ID.
  Future<void> deleteItem(String historyId) async {
    await _db
        .from('visit_histories')
        .delete()
        .eq('id', historyId);
  }

  /// Hapus seluruh riwayat milik user ini.
  Future<void> clearAll(String userId) async {
    await _db
        .from('visit_histories')
        .delete()
        .eq('user_id', userId);
  }
}