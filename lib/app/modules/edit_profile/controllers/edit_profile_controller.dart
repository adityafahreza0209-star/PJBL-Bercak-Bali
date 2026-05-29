import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../widgets/theme_constants.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../services/profile_service.dart';
import '../../../services/auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL — representasi form edit profil
// ─────────────────────────────────────────────────────────────────────────────

class UserProfile {
  String name;
  String email;
  String phone;
  String bio;
  String location;
  String gender;
  String socialMedia;
  String? avatarUrl;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.location,
    required this.gender,
    required this.socialMedia,
    this.avatarUrl,
  });

  /// Buat dari ProfileData yang sudah di-fetch ProfileController
  factory UserProfile.fromProfileData(ProfileData data) => UserProfile(
        name:        data.fullName,
        email:       data.email,
        phone:       data.phone        ?? '',
        bio:         data.bio          ?? '',
        location:    data.location     ?? '',
        gender:      data.gender       ?? 'Laki-laki',
        socialMedia: data.socialMedia  ?? '',
        avatarUrl:   data.avatarUrl,
      );

  /// Payload untuk upsert ke tabel profiles
  Map<String, dynamic> toJson() => {
        'full_name':    name,
        'email':        email,
        'phone':        phone,
        'bio':          bio,
        'location':     location,
        'gender':       gender,
        'social_media': socialMedia,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────────────────────────────────────────

class EditProfileController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _picker   = ImagePicker();

  // ── TextEditingControllers ───────────────────────────────────
  final nameCtrl     = TextEditingController();
  final emailCtrl    = TextEditingController();
  final phoneCtrl    = TextEditingController();
  final bioCtrl      = TextEditingController();
  final locationCtrl = TextEditingController();
  final websiteCtrl  = TextEditingController();

  // ── Reactive state ───────────────────────────────────────────
  final isSaving       = false.obs;
  final isLoading      = false.obs;
  final hasChanges     = false.obs;
  final selectedGender = 'Laki-laki'.obs;
  final avatarUrl      = RxnString();
  final localAvatar    = Rxn<File>();

  final List<String> genderOptions = const [
    'Laki-laki',
    'Perempuan',
    'Tidak ingin menyebutkan',
  ];

  late UserProfile _originalProfile;

  @override
  void onInit() {
    super.onInit();
    _loadFromProfileController();
    _attachListeners();
  }

  // ── LOAD data dari ProfileController (sudah di-fetch, tidak perlu query baru) ─

  void _loadFromProfileController() {
    isLoading.value = true;
    try {
      final pc = Get.find<ProfileController>();
      final data = pc.profile.value;

      _originalProfile = data != null
          ? UserProfile.fromProfileData(data)
          : _fallbackProfile();

      _fillControllers(_originalProfile);
      avatarUrl.value = _originalProfile.avatarUrl;
    } catch (_) {
      // ProfileController belum teregister — fallback ke AuthService
      _originalProfile = _fallbackProfile();
      _fillControllers(_originalProfile);
    } finally {
      isLoading.value = false;
    }
  }

  UserProfile _fallbackProfile() => UserProfile(
        name:        AuthService.to.userFullName,
        email:       AuthService.to.userEmail,
        phone:       '',
        bio:         '',
        location:    '',
        gender:      'Laki-laki',
        socialMedia: '',
        avatarUrl:   AuthService.to.userAvatarUrl,
      );

  void _fillControllers(UserProfile p) {
    nameCtrl.text        = p.name;
    emailCtrl.text       = p.email;
    phoneCtrl.text       = p.phone;
    bioCtrl.text         = p.bio;
    locationCtrl.text    = p.location;
    websiteCtrl.text     = p.socialMedia;
    selectedGender.value = p.gender.isNotEmpty ? p.gender : 'Laki-laki';
  }

  // ── Listener perubahan field ─────────────────────────────────

  void _attachListeners() {
    for (final ctrl in _allControllers) {
      ctrl.addListener(_checkIfDataChanged);
    }
  }

  void _checkIfDataChanged() {
    final changed =
        nameCtrl.text        != _originalProfile.name        ||
        emailCtrl.text       != _originalProfile.email       ||
        phoneCtrl.text       != _originalProfile.phone       ||
        bioCtrl.text         != _originalProfile.bio         ||
        locationCtrl.text    != _originalProfile.location    ||
        websiteCtrl.text     != _originalProfile.socialMedia ||
        selectedGender.value != _originalProfile.gender      ||
        localAvatar.value    != null;

    if (hasChanges.value != changed) hasChanges.value = changed;
  }

  List<TextEditingController> get _allControllers =>
      [nameCtrl, emailCtrl, phoneCtrl, bioCtrl, locationCtrl, websiteCtrl];

  void selectGender(String gender) {
    selectedGender.value = gender;
    _checkIfDataChanged();
  }

  // ── PICK AVATAR ──────────────────────────────────────────────

  Future<void> pickAvatar() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked == null) return;
      localAvatar.value = File(picked.path);
      hasChanges.value  = true;
    } catch (_) {
      Get.snackbar('Gagal', 'Tidak bisa membuka galeri foto.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── UPLOAD AVATAR ke Supabase Storage ───────────────────────

  Future<String?> _uploadAvatar(File file) async {
    try {
      final userId = AuthService.to.userId;
      final ext    = file.path.split('.').last;
      final path   = '/$userId/avatar.$ext';
      final bytes  = await file.readAsBytes();

      await _supabase.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final url = _supabase.storage.from('avatars').getPublicUrl(path);
      // Cache-buster agar Image.network tidak pakai gambar lama
      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      Get.snackbar(
        'Perhatian', 'Foto profil gagal diupload: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // ── SIMPAN ke Supabase ───────────────────────────────────────

  Future<void> saveChanges() async {
    if (!_validate()) return;

    isSaving.value = true;
    try {
      final userId = AuthService.to.userId;

      // 1. Upload avatar baru jika ada
      String? newAvatarUrl = avatarUrl.value;
      if (localAvatar.value != null) {
        newAvatarUrl = await _uploadAvatar(localAvatar.value!);
        if (newAvatarUrl != null) avatarUrl.value = newAvatarUrl;
      }

      // 2. Upsert ke tabel profiles
      final payload = <String, dynamic>{
        'id': userId,
        ...UserProfile(
          name:        nameCtrl.text.trim(),
          email:       emailCtrl.text.trim(),
          phone:       phoneCtrl.text.trim(),
          bio:         bioCtrl.text.trim(),
          location:    locationCtrl.text.trim(),
          gender:      selectedGender.value,
          socialMedia: websiteCtrl.text.trim(),
        ).toJson(),
        'updated_at': DateTime.now().toIso8601String(),
        if (newAvatarUrl != null) 'avatar_url': newAvatarUrl,
      };

      await _supabase.from('profiles').upsert(payload);

      // 3. Update auth user metadata
      await _supabase.auth.updateUser(UserAttributes(
        data: {
          'full_name': nameCtrl.text.trim(),
          if (newAvatarUrl != null) 'avatar_url': newAvatarUrl,
        },
      ));

      // 4. Refresh ProfileController agar halaman Profil langsung update
      //    tanpa perlu reload app — cukup trigger fetch ulang
      try {
        await Get.find<ProfileController>().refresh();
      } catch (_) {}

      // 5. Reset dirty state
      _originalProfile = UserProfile(
        name:        nameCtrl.text.trim(),
        email:       emailCtrl.text.trim(),
        phone:       phoneCtrl.text.trim(),
        bio:         bioCtrl.text.trim(),
        location:    locationCtrl.text.trim(),
        gender:      selectedGender.value,
        socialMedia: websiteCtrl.text.trim(),
        avatarUrl:   newAvatarUrl,
      );
      localAvatar.value = null;
      hasChanges.value  = false;

      Get.back();
      Get.snackbar(
        'Berhasil disimpan', 'Profil kamu telah diperbarui',
        backgroundColor: AppColors.ratingColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    } on PostgrestException catch (e) {
      _showError('Gagal menyimpan profil: ${e.message}');
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // ── Validasi ─────────────────────────────────────────────────

  bool _validate() {
    if (nameCtrl.text.trim().isEmpty) {
      _showError('Nama tidak boleh kosong'); return false;
    }
    if (nameCtrl.text.trim().length < 2) {
      _showError('Nama terlalu pendek (minimal 2 karakter)'); return false;
    }
    if (!GetUtils.isEmail(emailCtrl.text.trim())) {
      _showError('Format email tidak valid'); return false;
    }
    if (phoneCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().length < 8) {
      _showError('Nomor telepon tidak valid'); return false;
    }
    return true;
  }

  void _showError(String msg) {
    Get.snackbar(
      'Perhatian', msg,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
    );
  }

  // ── Konfirmasi buang perubahan ────────────────────────────────

  void handleBack() {
    if (!hasChanges.value) { Get.back(); return; }
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Buang perubahan?',
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        content: const Text('Perubahan yang belum disimpan akan hilang.',
            style: TextStyle(color: AppColors.white70, fontSize: 14)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(children: [
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
                    localAvatar.value = null;
                    Get.back();
                    Get.back();
                  },
                  child: const Text('Buang'),
                ),
              ),
            ]),
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