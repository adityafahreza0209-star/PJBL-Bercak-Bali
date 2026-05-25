import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/theme_constants.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          controller.handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          _TopBar(controller: controller),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _AvatarSection(controller: controller),
                  const SizedBox(height: 32),
                  _FormSection(controller: controller),
                  const SizedBox(height: 32),
                  _SaveButton(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final EditProfileController controller;
  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bgColor,
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.07)),
          ),
        ),
        child: Row(
          children: [
            Obx(() => IconButton(
                  onPressed: controller.handleBack,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: controller.hasChanges.value
                        ? AppColors.primaryColor
                        : Colors.white,
                    size: 20,
                  ),
                )),
            const Expanded(
              child: Text(
                'Edit Profil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Obx(() => TextButton(
                  onPressed: controller.hasChanges.value && !controller.isSaving.value
                      ? controller.saveChanges
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    disabledForegroundColor: Colors.white24,
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// AVATAR SECTION
// ═══════════════════════════════════════════════════════════
class _AvatarSection extends StatelessWidget {
  final EditProfileController controller;
  const _AvatarSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withOpacity(0.15),
              border: Border.all(color: AppColors.primaryColor, width: 2.5),
            ),
            // SOLUSI: Mengganti Obx dengan ValueListenableBuilder bawaan TextEditingController
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller.nameCtrl,
              builder: (context, value, child) {
                final name = value.text;
                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
                return Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -2,
            right: -2,
            child: GestureDetector(
              onTap: controller.pickAvatar,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgColor, width: 2.5),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.cardColor,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FORM SECTION
// ═══════════════════════════════════════════════════════════
class _FormSection extends StatelessWidget {
  final EditProfileController controller;
  const _FormSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Informasi Dasar ────────────────────────────────
        const _SectionLabel('INFORMASI DASAR'),
        const SizedBox(height: 12),
        _FormCard(children: [
          _InputField(
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap',
            controller: controller.nameCtrl,
            icon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
          ),
          _FieldDivider(),
          _InputField(
            label: 'Email',
            hint: 'Masukkan email',
            controller: controller.emailCtrl,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          _FieldDivider(),
          _InputField(
            label: 'Nomor Telepon',
            hint: '+62 xxx-xxxx-xxxx',
            controller: controller.phoneCtrl,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ]),
        const SizedBox(height: 24),

        // ── Tentang Saya ───────────────────────────────────
        const _SectionLabel('TENTANG SAYA'),
        const SizedBox(height: 12),
        _FormCard(children: [
          _InputField(
            label: 'Bio',
            hint: 'Ceritakan sedikit tentang dirimu...',
            controller: controller.bioCtrl,
            icon: Icons.notes_rounded,
            maxLines: 3,
          ),
          _FieldDivider(),
          _InputField(
            label: 'Lokasi',
            hint: 'Kota, Provinsi',
            controller: controller.locationCtrl,
            icon: Icons.location_on_outlined,
          ),
          _FieldDivider(),
          // PERUBAHAN: Mengubah Website menjadi Sosial Media
          _InputField(
            label: 'Sosial Media',
            hint: '@username atau link profil',
            controller: controller.websiteCtrl, // Tetap menggunakan controller yang sama agar tidak break sebelum file controller diupdate
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.text,
          ),
        ]),
        const SizedBox(height: 24),

        // ── Gender ─────────────────────────────────────────
        const _SectionLabel('GENDER'),
        const SizedBox(height: 12),
        Obx(() => _GenderPicker(
              options: controller.genderOptions,
              selected: controller.selectedGender.value,
              onSelect: controller.selectGender,
            )),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SAVE BUTTON
// ═══════════════════════════════════════════════════════════
class _SaveButton extends StatelessWidget {
  final EditProfileController controller;
  const _SaveButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final saving = controller.isSaving.value;
      return GestureDetector(
        onTap: saving ? null : controller.saveChanges,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: saving
                ? AppColors.primaryColor.withOpacity(0.5)
                : AppColors.primaryColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: saving
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.cardColor,
                    ),
                  )
                : const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      color: AppColors.cardColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════
// GENDER PICKER
// ═══════════════════════════════════════════════════════════
class _GenderPicker extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _GenderPicker({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withOpacity(0.12)
                  : AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.white.withOpacity(0.08),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.primaryColor : AppColors.white54,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Text(
                  opt,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.white70,
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ═══════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: children),
    );
  }
}

class _FieldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Colors.white.withOpacity(0.07),
      indent: 52,
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: 36,
              child: Icon(icon, color: AppColors.primaryColor, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  maxLines: maxLines,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  cursorColor: AppColors.primaryColor,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                        color: AppColors.white54, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 10),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}