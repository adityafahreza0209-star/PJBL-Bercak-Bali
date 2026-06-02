import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// MODEL: BookingStatus
// ============================================================

enum BookingStatus {
  pending,
  confirmed,
  rejected,
  cancelled,
  completed;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BookingStatus.pending,
    );
  }

  /// Label yang ditampilkan di UI
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Menunggu Konfirmasi';
      case BookingStatus.confirmed:
        return 'Dikonfirmasi';
      case BookingStatus.rejected:
        return 'Ditolak';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
      case BookingStatus.completed:
        return 'Selesai';
    }
  }
}

// ============================================================
// MODEL: BookingWisataModel
// ============================================================

class BookingWisataModel {
  final String id;
  final String userId;
  final String wisataId;
  final String fullName;
  final String phoneNumber;
  final DateTime visitDate;
  final int ticketCount;
  final double totalPrice;
  final BookingStatus status;
  final String? cancellationReason;
  final String? adminNote;
  final DateTime createdAt;

  // Data relasi (join)
  final String? wisataTitle;
  final String? wisataImageUrl;

  const BookingWisataModel({
    required this.id,
    required this.userId,
    required this.wisataId,
    required this.fullName,
    required this.phoneNumber,
    required this.visitDate,
    required this.ticketCount,
    required this.totalPrice,
    required this.status,
    this.cancellationReason,
    this.adminNote,
    required this.createdAt,
    this.wisataTitle,
    this.wisataImageUrl,
  });

  factory BookingWisataModel.fromMap(Map<String, dynamic> map) {
    // Data relasi dari join dengan tabel wisata
    final wisataData = map['wisata'] as Map<String, dynamic>?;

    return BookingWisataModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      wisataId: map['wisata_id'] as String,
      fullName: map['full_name'] as String,
      phoneNumber: map['phone_number'] as String,
      visitDate: DateTime.parse(map['visit_date'] as String),
      ticketCount: map['ticket_count'] as int,
      totalPrice: (map['total_price'] as num).toDouble(),
      status: BookingStatus.fromString(map['status'] as String? ?? 'pending'),
      cancellationReason: map['cancellation_reason'] as String?,
      adminNote: map['admin_note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      wisataTitle: wisataData?['title'] as String?,
      wisataImageUrl: wisataData != null
          ? _buildImageUrl(wisataData['image_url'] as String? ?? '')
          : null,
    );
  }

  static const _supabaseUrl = 'https://exsafhemjamjrieqdarn.supabase.co';
  static const _storageBucket = 'place-images';

  static String _buildImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$_supabaseUrl/storage/v1/object/public/$_storageBucket/$path';
  }

  bool get canBeCancelled =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;
}

// ============================================================
// MODEL: ReservasiRestoranModel
// ============================================================

class ReservasiRestoranModel {
  final String id;
  final String userId;
  final String restaurantId;
  final String fullName;
  final String phoneNumber;
  final DateTime reservationDate;
  final String reservationTime; // format "HH:mm"
  final int guestCount;
  final String? notes;
  final BookingStatus status;
  final String? cancellationReason;
  final String? adminNote;
  final DateTime createdAt;

  // Data relasi (join)
  final String? restaurantName;
  final String? restaurantImageUrl;

  const ReservasiRestoranModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.fullName,
    required this.phoneNumber,
    required this.reservationDate,
    required this.reservationTime,
    required this.guestCount,
    this.notes,
    required this.status,
    this.cancellationReason,
    this.adminNote,
    required this.createdAt,
    this.restaurantName,
    this.restaurantImageUrl,
  });

  factory ReservasiRestoranModel.fromMap(Map<String, dynamic> map) {
    final restaurantData = map['restaurants'] as Map<String, dynamic>?;

    return ReservasiRestoranModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      restaurantId: map['restaurant_id'] as String,
      fullName: map['full_name'] as String,
      phoneNumber: map['phone_number'] as String,
      reservationDate: DateTime.parse(map['reservation_date'] as String),
      reservationTime: map['reservation_time'] as String,
      guestCount: map['guest_count'] as int,
      notes: map['notes'] as String?,
      status: BookingStatus.fromString(map['status'] as String? ?? 'pending'),
      cancellationReason: map['cancellation_reason'] as String?,
      adminNote: map['admin_note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      restaurantName: restaurantData?['name'] as String?,
      restaurantImageUrl: restaurantData != null
          ? _buildImageUrl(restaurantData['image_url'] as String? ?? '')
          : null,
    );
  }

  static const _supabaseUrl = 'https://exsafhemjamjrieqdarn.supabase.co';
  static const _storageBucket = 'place-images';

  static String _buildImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$_supabaseUrl/storage/v1/object/public/$_storageBucket/$path';
  }

  bool get canBeCancelled =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;
}

// ============================================================
// SERVICE: BookingService
// ============================================================

class BookingService {
  // Singleton
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final SupabaseClient _db = Supabase.instance.client;

  // ── SELECT query dengan join ─────────────────────────────

  static const _bookingWisataSelect = '''
    id,
    user_id,
    wisata_id,
    full_name,
    phone_number,
    visit_date,
    ticket_count,
    total_price,
    status,
    cancellation_reason,
    admin_note,
    created_at,
    wisata (
      title,
      image_url
    )
  ''';

  static const _reservasiRestoranSelect = '''
    id,
    user_id,
    restaurant_id,
    full_name,
    phone_number,
    reservation_date,
    reservation_time,
    guest_count,
    notes,
    status,
    cancellation_reason,
    admin_note,
    created_at,
    restaurants (
      name,
      image_url
    )
  ''';

  // ── BOOKING WISATA ───────────────────────────────────────

  /// Buat booking tiket wisata baru.
  Future<BookingWisataModel> createBookingWisata({
    required String userId,
    required String wisataId,
    required String fullName,
    required String phoneNumber,
    required DateTime visitDate,
    required int ticketCount,
    required double totalPrice,
  }) async {
    final inserted = await _db
        .from('booking_wisata')
        .insert({
          'user_id': userId,
          'wisata_id': wisataId,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'visit_date': visitDate.toIso8601String().substring(0, 10),
          'ticket_count': ticketCount,
          'total_price': totalPrice,
          'status': 'pending',
        })
        .select(_bookingWisataSelect)
        .single();

    return BookingWisataModel.fromMap(inserted);
  }

  /// Ambil semua booking wisata milik user, diurutkan terbaru.
  Future<List<BookingWisataModel>> fetchMyBookingWisata(String userId) async {
    final res = await _db
        .from('booking_wisata')
        .select(_bookingWisataSelect)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => BookingWisataModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Batalkan booking wisata (ubah status ke 'cancelled').
  Future<void> cancelBookingWisata({
    required String bookingId,
    required String userId,
    String? reason,
  }) async {
    await _db
        .from('booking_wisata')
        .update({
          'status': 'cancelled',
          if (reason != null && reason.isNotEmpty)
            'cancellation_reason': reason,
        })
        .eq('id', bookingId)
        .eq('user_id', userId); // double-check ownership (RLS juga menjaga ini)
  }

  // ── RESERVASI RESTORAN ────────────────────────────────────

  /// Buat reservasi restoran baru.
  Future<ReservasiRestoranModel> createReservasiRestoran({
    required String userId,
    required String restaurantId,
    required String fullName,
    required String phoneNumber,
    required DateTime reservationDate,
    required String reservationTime,
    required int guestCount,
    String? notes,
  }) async {
    final inserted = await _db
        .from('reservasi_restoran')
        .insert({
          'user_id': userId,
          'restaurant_id': restaurantId,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'reservation_date':
              reservationDate.toIso8601String().substring(0, 10),
          'reservation_time': reservationTime,
          'guest_count': guestCount,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          'status': 'pending',
        })
        .select(_reservasiRestoranSelect)
        .single();

    return ReservasiRestoranModel.fromMap(inserted);
  }

  /// Ambil semua reservasi restoran milik user.
  Future<List<ReservasiRestoranModel>> fetchMyReservasiRestoran(
    String userId,
  ) async {
    final res = await _db
        .from('reservasi_restoran')
        .select(_reservasiRestoranSelect)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (res as List)
        .map(
          (e) => ReservasiRestoranModel.fromMap(e as Map<String, dynamic>),
        )
        .toList();
  }

  /// Batalkan reservasi restoran.
  Future<void> cancelReservasiRestoran({
    required String reservasiId,
    required String userId,
    String? reason,
  }) async {
    await _db
        .from('reservasi_restoran')
        .update({
          'status': 'cancelled',
          if (reason != null && reason.isNotEmpty)
            'cancellation_reason': reason,
        })
        .eq('id', reservasiId)
        .eq('user_id', userId);
  }
}
