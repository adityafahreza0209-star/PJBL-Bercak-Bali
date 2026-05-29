import 'package:supabase_flutter/supabase_flutter.dart';
import 'review_service.dart'; // <--- Memastikan sinkronisasi model review terpusat

// ============================================================
// MODEL
// ============================================================

class RestaurantModel {
  final String id;
  final String name;
  final String location;
  final String cuisine;
  final String description;
  final double rating;
  final int totalReviews;
  final String priceRange;
  final String distance;
  final String phoneNumber;
  final double? latitude;
  final double? longitude;
  final String? cityId;
  final String imageUrl;
  final List<String> images;
  final bool isFeatured;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.location,
    required this.cuisine,
    required this.description,
    required this.rating,
    required this.totalReviews,
    required this.priceRange,
    required this.distance,
    required this.phoneNumber,
    this.latitude,
    this.longitude,
    this.cityId,
    required this.imageUrl,
    required this.images,
    this.isFeatured = false,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    const supabaseUrl = 'https://exsafhemjamjrieqdarn.supabase.co'; 

    final rawImages = map['place_images'] as List<dynamic>? ?? [];

    final imageList = rawImages.map((e) {
      final url = (e as Map<String, dynamic>)['image_url'] as String;
      if (url.startsWith('http')) return url;
      return '$supabaseUrl/storage/v1/object/public/$url';
    }).toList();

    final rawCover = map['image_url'] as String? ?? '';
    String cover = '';

    if (rawCover.isNotEmpty) {
      if (rawCover.startsWith('http')) {
        cover = rawCover;
      } else {
        cover = '$supabaseUrl/storage/v1/object/public/restaurants/$rawCover';
      }
    }

    final allImages = [
      if (cover.isNotEmpty) cover,
      ...imageList.where((url) => url != cover),
    ];

    return RestaurantModel(
      id: map['id'] as String,
      name: map['name'] as String,
      location: map['location'] as String? ?? '',
      cuisine: map['cuisine'] as String? ?? '',
      description: map['description'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: map['total_reviews'] as int? ?? 0,
      priceRange: map['price_range'] as String? ?? '',
      distance: map['distance'] as String? ?? '',
      phoneNumber: map['phone_number'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      cityId: map['city_id'] as String?,
      imageUrl: cover,
      images: allImages.isNotEmpty ? allImages : ['assets/images/restoran1.jpg'], 
      isFeatured: map['is_featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toArguments() => {
        'restaurantId': id,
        'images': images,
        'name': name,
        'location': location,
        'cuisine': cuisine,
        'rating': rating.toStringAsFixed(1),
        'priceRange': priceRange,
        'distance': distance,
        'description': description,
        'phone': phoneNumber,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class MenuItemModel {
  final String id;
  final String name;
  final String? price;
  final String? category;
  final bool isPopular;

  const MenuItemModel({
    required this.id,
    required this.name,
    this.price,
    this.category,
    this.isPopular = false,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) => MenuItemModel(
        id: map['id'] as String,
        name: map['name'] as String,
        price: map['price'] as String?,
        category: map['category'] as String?,
        isPopular: map['is_popular'] as bool? ?? false,
      );
}

// ============================================================
// SERVICE
// ============================================================

class RestaurantService {
  static final RestaurantService _instance = RestaurantService._internal();

  factory RestaurantService() => _instance;

  RestaurantService._internal();

  final SupabaseClient _db = Supabase.instance.client;

  static const String _restaurantSelect = '''
    id,
    name,
    location,
    cuisine,
    description,
    rating,
    total_reviews,
    price_range,
    distance,
    phone_number,
    latitude,
    longitude,
    city_id,
    image_url,
    is_featured,
    place_images (
      image_url,
      sort_order
    )
  ''';

  // ============================================================
  // CITIES
  // ============================================================

  Future<String?> findCityIdByName(String cityName) async {
    final res = await _db
        .from('cities')
        .select('id')
        .ilike('city_name', cityName)
        .maybeSingle();

    return res?['id'] as String?;
  }

  // ============================================================
  // RESTAURANTS
  // ============================================================

  Future<List<RestaurantModel>> fetchFeaturedRestaurants() async {
    final res = await _db
        .from('restaurants')
        .select(_restaurantSelect)
        .eq('is_featured', true)
        .order('rating', ascending: false);

    return _toRestaurantList(res);
  }

  Future<List<RestaurantModel>> fetchAllRestaurants() async {
    final res = await _db
        .from('restaurants')
        .select(_restaurantSelect)
        .order('rating', ascending: false);

    return _toRestaurantList(res);
  }

  Future<List<RestaurantModel>> fetchRestaurantsByCityId(String cityId) async {
    final res = await _db
        .from('restaurants')
        .select(_restaurantSelect)
        .eq('city_id', cityId)
        .order('rating', ascending: false);

    return _toRestaurantList(res);
  }

  Future<RestaurantModel?> fetchRestaurantById(String restaurantId) async {
    final res = await _db
        .from('restaurants')
        .select(_restaurantSelect)
        .eq('id', restaurantId)
        .maybeSingle();
 
    return res != null ? RestaurantModel.fromMap(res) : null;
  }

  List<RestaurantModel> _toRestaurantList(List<dynamic> res) {
    return res
        .map((e) => RestaurantModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ============================================================
  // REVIEWS
  // ============================================================

  Future<List<ReviewModel>> fetchReviews(String restaurantId) async {
    final res = await _db
        .from('reviews')
        .select('''
          id,
          user_id,
          rating,
          comment,
          useful_count,
          created_at,
          profiles (
            full_name,
            avatar_url
          )
        ''')
        .eq('place_type', 'restoran')
        .eq('restaurant_id', restaurantId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => ReviewModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addReview({
    required String restaurantId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    await _db.from('reviews').insert({
      'place_type': 'restoran',
      'restaurant_id': restaurantId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    });
  }

  // ============================================================
  // REVIEW USEFUL VOTES
  // ============================================================

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

  // ============================================================
  // SAVED PLACES
  // ============================================================

  Future<bool> isSaved({
    required String restaurantId,
    required String userId,
  }) async {
    final res = await _db
        .from('saved_places')
        .select('id')
        .eq('place_type', 'restoran')
        .eq('restaurant_id', restaurantId)
        .eq('user_id', userId)
        .maybeSingle();

    return res != null;
  }

  Future<void> savePlace({
    required String restaurantId,
    required String userId,
  }) async {
    await _db.from('saved_places').insert({
      'place_type': 'restoran',
      'restaurant_id': restaurantId,
      'user_id': userId,
    });
  }

  Future<void> unsavePlace({
    required String restaurantId,
    required String userId,
  }) async {
    await _db
        .from('saved_places')
        .delete()
        .eq('place_type', 'restoran')
        .eq('restaurant_id', restaurantId)
        .eq('user_id', userId);
  }

  // ============================================================
  // VISIT HISTORIES
  // ============================================================

  Future<void> recordVisit({
    required String restaurantId,
    required String userId,
  }) async {
    await _db.from('visit_histories').insert({
      'place_type': 'restoran',
      'restaurant_id': restaurantId,
      'user_id': userId,
      'visited_at': DateTime.now().toIso8601String(),
    });
  }

  // ============================================================
  // MENUS
  // ============================================================

  Future<List<MenuItemModel>> fetchMenus(String restaurantId) async {
    final res = await _db
        .from('restaurant_menus')
        .select()
        .eq('restaurant_id', restaurantId)
        .order('category')
        .order('name');

    return (res as List)
        .map((e) => MenuItemModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}