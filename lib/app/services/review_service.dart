import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// MODEL
// ============================================================

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String placeType; 
  final String? wisataId;
  final String? restaurantId;
  final String? placeName; 
  final String? placeImageUrl;
  final int rating;
  final String? title;
  final String comment;
  final int usefulCount;
  final List<String> imageUrls; 
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.placeType,
    this.wisataId,
    this.restaurantId,
    this.placeName,
    this.placeImageUrl,
    required this.rating,
    this.title,
    required this.comment,
    required this.usefulCount,
    required this.imageUrls,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    const supabaseUrl = 'https://exsafhemjamjrieqdarn.supabase.co';

    // Profil penulis review
    final profile = map['profiles'] as Map<String, dynamic>?;
    final userName = profile?['full_name'] as String? ?? 'Pengguna';
    final rawAvatar = profile?['avatar_url'] as String?;
    final avatarUrl = rawAvatar != null
        ? (rawAvatar.startsWith('http')
            ? rawAvatar
            : '$supabaseUrl/storage/v1/object/public/$rawAvatar')
        : null;

    // Gambar yang dilampirkan pada review ini
    final rawImages = map['review_images'] as List<dynamic>? ?? [];
    final imageUrls = rawImages.map((e) {
      final url = (e as Map<String, dynamic>)['image_url'] as String;
      return url.startsWith('http')
          ? url
          : '$supabaseUrl/storage/v1/object/public/review-images/$url';
    }).toList();

    // Nama & gambar tempat (ada saat fetch untuk halaman user profile)
    final wisataData = map['wisata'] as Map<String, dynamic>?;
    final restoData = map['restaurants'] as Map<String, dynamic>?;
    final placeName =
        wisataData?['title'] as String? ?? restoData?['name'] as String?;
    final rawPlaceImage =
        wisataData?['image_url'] as String? ?? restoData?['image_url'] as String?;
    String? placeImageUrl;
    if (rawPlaceImage != null && rawPlaceImage.isNotEmpty) {
      if (rawPlaceImage.startsWith('http')) {
        placeImageUrl = rawPlaceImage;
      } else {
        final bucket = map['place_type'] == 'wisata' ? 'place-images' : 'place-images';
        placeImageUrl =
            '$supabaseUrl/storage/v1/object/public/$bucket/$rawPlaceImage';
      }
    }

    return ReviewModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      userName: userName,
      userAvatarUrl: avatarUrl,
      placeType: map['place_type'] as String,
      wisataId: map['wisata_id'] as String?,
      restaurantId: map['restaurant_id'] as String?,
      placeName: placeName,
      placeImageUrl: placeImageUrl,
      rating: map['rating'] as int,
      title: map['title'] as String?,
      comment: map['comment'] as String? ?? '',
      usefulCount: map['useful_count'] as int? ?? 0,
      imageUrls: imageUrls,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Format tanggal: "Jan 2025"
  String get dateFormatted {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${months[createdAt.month]} ${createdAt.year}';
  }
}

class UserProfileModel {
  final String id;
  final String fullName;
  final String? bio;
  final String? location;
  final String? socialMedia;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserProfileModel({
    required this.id,
    required this.fullName,
    this.bio,
    this.location,
    this.socialMedia,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    const supabaseUrl = 'https://exsafhemjamjrieqdarn.supabase.co';
    final rawAvatar = map['avatar_url'] as String?;

    return UserProfileModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? 'Pengguna',
      bio: map['bio'] as String?,
      location: map['location'] as String?,
      socialMedia: map['social_media'] as String?,
      avatarUrl: rawAvatar != null
          ? (rawAvatar.startsWith('http')
              ? rawAvatar
              : '$supabaseUrl/storage/v1/object/public/$rawAvatar')
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String get initial =>
      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'P';

  /// Format: "Bergabung Jan 2025"
  String get memberSince {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${months[createdAt.month]} ${createdAt.year}';
  }
}

// ============================================================
// SERVICE
// ============================================================

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final SupabaseClient _db = Supabase.instance.client;

  // Query review lengkap: profil penulis + gambar lampiran + nama tempat
  static const _reviewSelect = '''
    id,
    user_id,
    place_type,
    wisata_id,
    restaurant_id,
    rating,
    title,
    comment,
    useful_count,
    created_at,
    profiles (
      full_name,
      avatar_url
    ),
    review_images (
      image_url
    )
  ''';

  // Query review + nama & gambar tempat (untuk halaman user profile)
  static const _reviewWithPlaceSelect = '''
    id,
    user_id,
    place_type,
    wisata_id,
    restaurant_id,
    rating,
    title,
    comment,
    useful_count,
    created_at,
    profiles (
      full_name,
      avatar_url
    ),
    review_images (
      image_url
    ),
    wisata (
      title,
      image_url
    ),
    restaurants (
      name,
      image_url
    )
  ''';

  // ── FETCH REVIEWS ───────────────────────────────────────────

  /// Review untuk satu wisata
  Future<List<ReviewModel>> fetchWisataReviews(String wisataId) async {
    final res = await _db
        .from('reviews')
        .select(_reviewSelect)
        .eq('place_type', 'wisata')
        .eq('wisata_id', wisataId)
        .order('created_at', ascending: false);

    return _toList(res);
  }

  /// Review untuk satu restoran
  Future<List<ReviewModel>> fetchRestaurantReviews(String restaurantId) async {
    final res = await _db
        .from('reviews')
        .select(_reviewSelect)
        .eq('place_type', 'restoran')
        .eq('restaurant_id', restaurantId)
        .order('created_at', ascending: false);

    return _toList(res);
  }

  /// Semua review milik satu user (untuk halaman user profile)
  Future<List<ReviewModel>> fetchUserReviews(String userId) async {
    final res = await _db
        .from('reviews')
        .select(_reviewWithPlaceSelect)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return _toList(res);
  }

  List<ReviewModel> _toList(List<dynamic> res) => res
      .map((e) => ReviewModel.fromMap(e as Map<String, dynamic>))
      .toList();

  // ── SUBMIT REVIEW ───────────────────────────────────────────

  /// Submit review beserta gambar (jika ada).
  /// Rating di tabel wisata/restoran diupdate otomatis oleh DB trigger.
  Future<void> submitReview({
    required String userId,
    required String placeType, // 'wisata' atau 'restoran'
    String? wisataId,
    String? restaurantId,
    required int rating,
    String? title,
    required String comment,
    List<File> images = const [],
  }) async {
    // 1. Simpan review ke tabel reviews
    final inserted = await _db
        .from('reviews')
        .insert({
          'user_id': userId,
          'place_type': placeType,
          if (wisataId != null) 'wisata_id': wisataId,
          if (restaurantId != null) 'restaurant_id': restaurantId,
          'rating': rating,
          if (title != null && title.isNotEmpty) 'title': title,
          'comment': comment,
        })
        .select('id')
        .single();

    final reviewId = inserted['id'] as String;

    // 2. Upload gambar ke bucket review-images dan simpan path ke review_images
    if (images.isNotEmpty) {
      await _uploadReviewImages(reviewId: reviewId, images: images);
    }
  }

  Future<void> _uploadReviewImages({
    required String reviewId,
    required List<File> images,
  }) async {
    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final ext = file.path.split('.').last.toLowerCase();
      // Path: review-images/{reviewId}/{timestamp}_{index}.jpg
      final path = '$reviewId/${DateTime.now().millisecondsSinceEpoch}_$i.$ext';

      await _db.storage.from('review-images').upload(path, file);

      // Simpan path ke tabel review_images
      await _db.from('review_images').insert({
        'review_id': reviewId,
        'image_url': path,
      });
    }
  }

  // ── USER PROFILE ────────────────────────────────────────────

  Future<UserProfileModel?> fetchUserProfile(String userId) async {
    final res = await _db
        .from('profiles')
        .select('id, full_name, bio, location, social_media, avatar_url, created_at')
        .eq('id', userId)
        .maybeSingle();

    return res != null ? UserProfileModel.fromMap(res) : null;
  }

  // ── USEFUL VOTES ────────────────────────────────────────────

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

  // ── UPDATE & DELETE REVIEW ─────────────────────────────────

  /// Mengekstraksi storage path relatif dari URL penuh Supabase Storage
  String? _extractStoragePath(String url) {
    const prefix = 'https://exsafhemjamjrieqdarn.supabase.co/storage/v1/object/public/review-images/';
    if (url.startsWith(prefix)) {
      return url.substring(prefix.length);
    }
    return null;
  }

  /// Menghapus ulasan secara aman
  Future<void> deleteReview({
    required String reviewId,
    required String userId,
  }) async {
    // 1. Ambil list gambar ulasan untuk dihapus dari storage fisiknya
    try {
      final images = await _db
          .from('review_images')
          .select('image_url')
          .eq('review_id', reviewId);
      
      if (images.isNotEmpty) {
        final List<String> paths = (images as List)
            .map((e) => e['image_url'] as String)
            .toList();
        await _db.storage.from('review-images').remove(paths);
      }
    } catch (e) {
      // Abaikan error storage agar tidak memblokir penghapusan database
      debugPrint('Gagal menghapus gambar ulasan dari storage: $e');
    }

    // 2. Hapus baris relasi gambar dari tabel review_images
    await _db.from('review_images').delete().eq('review_id', reviewId);

    // 3. Hapus ulasan dari tabel reviews dengan filter user_id agar aman
    await _db
        .from('reviews')
        .delete()
        .eq('id', reviewId)
        .eq('user_id', userId);
  }

  /// Memperbarui ulasan yang ada secara aman
  Future<void> updateReview({
    required String reviewId,
    required String userId,
    required int rating,
    String? title,
    required String comment,
    List<File> newImages = const [],
    List<String> imagesToDelete = const [],
  }) async {
    // 1. Update record di tabel reviews
    await _db.from('reviews').update({
      'rating': rating,
      'title': (title != null && title.isNotEmpty) ? title : null,
      'comment': comment,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', reviewId).eq('user_id', userId);

    // 2. Hapus gambar lama yang diminta oleh pengguna
    if (imagesToDelete.isNotEmpty) {
      final List<String> pathsToDelete = [];
      for (final imageUrl in imagesToDelete) {
        final path = _extractStoragePath(imageUrl);
        if (path != null) {
          pathsToDelete.add(path);
          // Hapus baris di tabel review_images
          await _db.from('review_images').delete().eq('image_url', path);
        }
      }
      if (pathsToDelete.isNotEmpty) {
        try {
          await _db.storage.from('review-images').remove(pathsToDelete);
        } catch (e) {
          debugPrint('Gagal menghapus beberapa file dari storage: $e');
        }
      }
    }

    // 3. Upload gambar baru jika ada
    if (newImages.isNotEmpty) {
      await _uploadReviewImages(reviewId: reviewId, images: newImages);
    }
  }
}