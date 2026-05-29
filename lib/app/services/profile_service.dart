import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// MODEL
// ============================================================

/// Data profil lengkap dari tabel `profiles`.
/// Sumber kebenaran utama — tidak bergantung pada JWT metadata.
class ProfileData {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final String? gender;
  final String? phone;
  final String? socialMedia;
  final String role; // 'user' | 'admin'

  const ProfileData({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.location,
    this.gender,
    this.phone,
    this.socialMedia,
    required this.role,
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    const supabaseUrl = 'https://exsafhemjamjrieqdarn.supabase.co';
    final rawAvatar = map['avatar_url'] as String?;

    return ProfileData(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? 'Pengguna',
      email: map['email'] as String? ?? '',
      avatarUrl: rawAvatar != null
          ? (rawAvatar.startsWith('http')
              ? rawAvatar
              : '$supabaseUrl/storage/v1/object/public/$rawAvatar')
          : null,
      bio: map['bio'] as String?,
      location: map['location'] as String?,
      gender: map['gender'] as String?,
      phone: map['phone'] as String?,
      socialMedia: map['social_media'] as String?,
      role: map['role'] as String? ?? 'user',
    );
  }

  String get initial =>
      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'P';

  String get roleLabel => role == 'admin' ? 'Admin' : 'Traveler';
}

/// Jumlah aktivitas user — diload sekali, ringan di server.
class ActivityCount {
  final int saved;
  final int visited;
  final int reviews;

  const ActivityCount({
    required this.saved,
    required this.visited,
    required this.reviews,
  });

  // Semua nol saat loading / error
  const ActivityCount.empty()
      : saved = 0,
        visited = 0,
        reviews = 0;
}

// ============================================================
// SERVICE
// ============================================================

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final SupabaseClient _db = Supabase.instance.client;

  // ── PROFIL ───────────────────────────────────────────────────

  /// Ambil data profil dari tabel `profiles` berdasarkan userId.
  /// Lebih akurat daripada JWT metadata karena mencerminkan
  /// perubahan terbaru dari halaman edit_profile.
  Future<ProfileData?> fetchProfile(String userId) async {
    final res = await _db
        .from('profiles')
        .select(
          'id, full_name, email, avatar_url, bio, location, '
          'gender, phone, social_media, role',
        )
        .eq('id', userId)
        .maybeSingle();

    return res != null ? ProfileData.fromMap(res) : null;
  }

  // ── ACTIVITY COUNTS ──────────────────────────────────────────
  // Masing-masing hanya fetch COUNT — tidak tarik seluruh baris.
  // Tiga query dijalankan paralel via Future.wait → efisien.

  Future<ActivityCount> fetchActivityCounts(String userId) async {
    final results = await Future.wait([
      _countSaved(userId),
      _countVisited(userId),
      _countReviews(userId),
    ]);

    return ActivityCount(
      saved: results[0],
      visited: results[1],
      reviews: results[2],
    );
  }

  Future<int> _countSaved(String userId) async {
    final res = await _db
        .from('saved_places')
        .select('id')
        .eq('user_id', userId)
        .count(CountOption.exact);
    return res.count;
  }

  Future<int> _countVisited(String userId) async {
    // Hitung tempat unik yang pernah dikunjungi
    final res = await _db
        .from('visit_histories')
        .select('id')
        .eq('user_id', userId)
        .count(CountOption.exact);
    return res.count;
  }

  Future<int> _countReviews(String userId) async {
    final res = await _db
        .from('reviews')
        .select('id')
        .eq('user_id', userId)
        .count(CountOption.exact);
    return res.count;
  }
}