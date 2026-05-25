import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../../profile/controllers/profile_controller.dart';

/// Model data profil.
class UserProfile {
  String name;
  String email;
  String phone;
  String bio;
  String location;
  String gender;
  String socialMedia; // Diubah dari website -> socialMedia agar sinkron dengan UI

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.location,
    required this.gender,
    required this.socialMedia,
  });

  // ── TODO Supabase: uncomment saat sudah ada tabel profiles ──
  // factory UserProfile.fromJson(Map<String, dynamic> json) {
  //   return UserProfile(
  //     name        : json['full_name']  ?? '',
  //     email       : json['email']      ?? '',
  //     phone       : json['phone']      ?? '',
  //     bio         : json['bio']        ?? '',
  //     location    : json['location']   ?? '',
  //     gender      : json['gender']     ?? '',
  //     socialMedia : json['social_media'] ?? '',
  //   );
  // }
  //
  // Map<String, dynamic> toJson() => {
  //   'full_name'    : name,
  //   'email'        : email,
  //   'phone'        : phone,
  //   'bio'          : bio,
  //   'location'     : location,
  //   'gender'       : gender,
  //   'social_media' : socialMedia,
  // };
}

class EditProfileController extends GetxController {
  // ── TextEditingControllers ─────────────────────────────────
  final nameCtrl     = TextEditingController();
  final emailCtrl    = TextEditingController();
  final phoneCtrl    = TextEditingController();
  final bioCtrl      = TextEditingController();
  final locationCtrl = TextEditingController();
  final websiteCtrl  = TextEditingController(); // Tetap menggunakan nama websiteCtrl agar tidak merusak binding View lama, namun mengarah ke data Sosial Media

  // ── Reactive state ─────────────────────────────────────────
  final isSaving = false.obs;
  final hasChanges = false.obs;
  final selectedGender = 'Laki-laki'.obs;

  final List<String> genderOptions = const [
    'Laki-laki',
    'Perempuan',
    'Tidak ingin disebutkan',
  ];

  // ── Data asli untuk komparasi smart check ──────────────────
  late UserProfile _originalProfile;

  @override
  void onInit() {
    super.onInit();
    _loadStaticData();
    _attachListeners();
  }

  // ── Load data awal ─────────────────────────────────────────
  void _loadStaticData() {
    String existingName  = 'Budi Santoso';
    String existingEmail = 'budi@example.com';
    try {
      final pc = Get.find<ProfileController>();
      existingName  = pc.userName.value;
      existingEmail = pc.userEmail.value;
    } catch (_) {}

    _originalProfile = UserProfile(
      name: existingName,
      email: existingEmail,
      phone: '+62 812-3456-7890',
      bio: 'Pecinta wisata dan kuliner Bali. Selalu mencari pengalaman baru di setiap sudut pulau dewata.',
      location: 'Denpasar, Bali',
      gender: 'Laki-laki',
      socialMedia: '@budisantoso', // Diperbarui menjadi format username sosial media
    );

    _fillControllers(_originalProfile);
  }

  void _fillControllers(UserProfile p) {
    nameCtrl.text        = p.name;
    emailCtrl.text       = p.email;
    phoneCtrl.text       = p.phone;
    bioCtrl.text         = p.bio;
    locationCtrl.text    = p.location;
    websiteCtrl.text     = p.socialMedia;
    selectedGender.value = p.gender;
  }

  // ── TODO Supabase: fetch profil dari database ──────────────
  // Future<void> _fetchFromSupabase() async {
  //   try {
  //     final user = Supabase.instance.client.auth.currentUser;
  //     if (user == null) return;
  //     final data = await Supabase.instance.client
  //         .from('profiles')
  //         .select()
  //         .eq('id', user.id)
  //         .single();
  //     _originalProfile = UserProfile.fromJson(data);
  //     _fillControllers(_originalProfile);
  //   } catch (e) {
  //     Get.snackbar('Error', 'Gagal memuat profil: $e');
  //   }
  // }

  // ── Listener perubahan field ───────────────────────────────
  void _attachListeners() {
    for (final ctrl in _allControllers) {
      ctrl.addListener(_checkIfDataChanged);
    }
  }

  // SOLUSI: Fungsi pembanding pintar (Smart Dirty Checking)
  // Memastikan status 'hasChanges' akurat berdasarkan isi teks asli vs saat ini
  void _checkIfDataChanged() {
    final changed = nameCtrl.text != _originalProfile.name ||
        emailCtrl.text != _originalProfile.email ||
        phoneCtrl.text != _originalProfile.phone ||
        bioCtrl.text != _originalProfile.bio ||
        locationCtrl.text != _originalProfile.location ||
        websiteCtrl.text != _originalProfile.socialMedia ||
        selectedGender.value != _originalProfile.gender;

    if (hasChanges.value != changed) {
      hasChanges.value = changed;
    }
  }

  List<TextEditingController> get _allControllers => [
        nameCtrl,
        emailCtrl,
        phoneCtrl,
        bioCtrl,
        locationCtrl,
        websiteCtrl,
      ];

  void selectGender(String gender) {
    selectedGender.value = gender;
    _checkIfDataChanged(); // Trigger pengecekan saat gender diubah
  }

  // ── Avatar picker ──────────────────────────────────────────
  void pickAvatar() {
    Get.snackbar(
      'Ganti Foto',
      'Fitur upload foto akan segera hadir',
      backgroundColor: AppColors.primaryColor,
      colorText: AppColors.cardColor,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.camera_alt, color: AppColors.cardColor),
      duration: const Duration(seconds: 2),
    );
  }

  // ── Simpan perubahan ───────────────────────────────────────
  Future<void> saveChanges() async {
    if (!_validate()) return;

    isSaving.value = true;

    // ── TODO Supabase: ganti blok ini dengan upsert ──────────
    // try {
    //   final user = Supabase.instance.client.auth.currentUser;
    //   final updated = UserProfile(
    //     name        : nameCtrl.text.trim(),
    //     email       : emailCtrl.text.trim(),
    //     phone       : phoneCtrl.text.trim(),
    //     bio         : bioCtrl.text.trim(),
    //     location    : locationCtrl.text.trim(),
    //     gender      : selectedGender.value,
    //     socialMedia : websiteCtrl.text.trim(),
    //   );
    //   await Supabase.instance.client
    //       .from('profiles')
    //       .upsert({'id': user!.id, ...updated.toJson()});
    // } catch (e) {
    //   isSaving.value = false;
    //   _showError('Gagal menyimpan: $e');
    //   return;
    // }
    // ── Akhir blok Supabase ───────────────────────────────────

    await Future.delayed(const Duration(milliseconds: 800));

    // Sync ke ProfileController
    try {
      final pc = Get.find<ProfileController>();
      pc.userName.value    = nameCtrl.text.trim();
      pc.userEmail.value   = emailCtrl.text.trim();
      pc.userInitial.value = nameCtrl.text.trim().isNotEmpty
          ? nameCtrl.text.trim()[0].toUpperCase()
          : 'U';
    } catch (_) {}

    isSaving.value   = false;
    hasChanges.value = false;

    Get.back();

    Get.snackbar(
      'Berhasil disimpan',
      'Profil kamu telah diperbarui',
      backgroundColor: AppColors.ratingColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

  // ── Validasi form ──────────────────────────────────────────
  bool _validate() {
    if (nameCtrl.text.trim().isEmpty) {
      _showError('Nama tidak boleh kosong');
      return false;
    }
    if (nameCtrl.text.trim().length < 2) {
      _showError('Nama terlalu pendek (minimal 2 karakter)');
      return false;
    }
    if (!GetUtils.isEmail(emailCtrl.text.trim())) {
      _showError('Format email tidak valid');
      return false;
    }
    if (phoneCtrl.text.trim().isNotEmpty &&
        phoneCtrl.text.trim().length < 8) {
      _showError('Nomor telepon tidak valid');
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    Get.snackbar(
      'Perhatian',
      msg,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
    );
  }

  // ── Konfirmasi buang perubahan saat back ───────────────────
  void handleBack() {
    if (!hasChanges.value) {
      Get.back();
      return;
    }
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Buang perubahan?',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Perubahan yang belum disimpan akan hilang.',
          style: TextStyle(color: AppColors.white70, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white70,
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: Get.back,
                    child: const Text('Lanjut Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Get.back(); // Tutup dialog
                      Get.back(); // Kembali ke profil tanpa simpan
                    },
                    child: const Text('Buang'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    for (final ctrl in _allControllers) {
      ctrl.removeListener(_checkIfDataChanged);
      ctrl.dispose();
    }
    super.onClose();
  }
}