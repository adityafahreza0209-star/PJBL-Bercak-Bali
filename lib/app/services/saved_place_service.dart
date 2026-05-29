import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/wisata_service.dart';
import '../services/restaurant_service.dart';

/// Model ringan untuk satu item tersimpan dari tabel saved_places.
class SavedPlaceItem {
  final String savedId;   // id di tabel saved_places
  final String placeType; // 'wisata' | 'restoran'
  final DateTime savedAt;
  final WisataModel? wisata;
  final RestaurantModel? restaurant;

  const SavedPlaceItem({
    required this.savedId,
    required this.placeType,
    required this.savedAt,
    this.wisata,
    this.restaurant,
  });

  // ── Convenience getters ─────────────────────────────────────

  String get title => wisata?.title ?? restaurant?.name ?? '';
  String get location => wisata?.location ?? restaurant?.location ?? '';
  double get rating => wisata?.rating ?? restaurant?.rating ?? 0;
  String get imageUrl => wisata?.imageUrl ?? restaurant?.imageUrl ?? '';

  String get categoryLabel {
    if (placeType == 'restoran') return 'Restoran';
    return wisata?.category.isNotEmpty == true ? wisata!.category : 'Wisata';
  }
}

class SavedPlaceService {
  final _db = Supabase.instance.client;

  /// Ambil semua tempat tersimpan milik [userId].
  /// Dua query paralel agar lebih cepat.
  Future<List<SavedPlaceItem>> fetchSavedPlaces(String userId) async {
    final results = await Future.wait([
      _fetchSavedWisata(userId),
      _fetchSavedRestoran(userId),
    ]);

    final all = [...results[0], ...results[1]];
    all.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return all;
  }

  Future<List<SavedPlaceItem>> _fetchSavedWisata(String userId) async {
    // Kolom eksplisit tanpa place_images — fromMap sudah handle null → []
    final rows = await _db
        .from('saved_places')
        .select('''
          id,
          created_at,
          wisata (
            id, city_id, title, location, category, description,
            ticket_price, open_hours, duration,
            latitude, longitude, rating, total_reviews,
            image_url, is_featured
          )
        ''')
        .eq('place_type', 'wisata')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows
        .where((row) => row['wisata'] != null)
        .map((row) => SavedPlaceItem(
              savedId: row['id'] as String,
              placeType: 'wisata',
              savedAt: DateTime.parse(row['created_at'] as String),
              wisata: WisataModel.fromMap(
                Map<String, dynamic>.from(row['wisata'] as Map),
              ),
            ))
        .toList();
  }

  Future<List<SavedPlaceItem>> _fetchSavedRestoran(String userId) async {
    final rows = await _db
        .from('saved_places')
        .select('''
          id,
          created_at,
          restaurants (
            id, city_id, name, location, cuisine, description,
            price_range, distance, phone_number,
            latitude, longitude, rating, total_reviews,
            image_url, is_featured
          )
        ''')
        .eq('place_type', 'restoran')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows
        .where((row) => row['restaurants'] != null)
        .map((row) => SavedPlaceItem(
              savedId: row['id'] as String,
              placeType: 'restoran',
              savedAt: DateTime.parse(row['created_at'] as String),
              restaurant: RestaurantModel.fromMap(
                Map<String, dynamic>.from(row['restaurants'] as Map),
              ),
            ))
        .toList();
  }

  /// Hapus satu item berdasarkan primary key saved_places.id
  Future<void> unsave(String savedId) async {
    await _db.from('saved_places').delete().eq('id', savedId);
  }
}