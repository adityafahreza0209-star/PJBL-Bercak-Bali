// lib/app/widgets/custom_navbar.dart
//
// Perubahan:
//  • Tab "Simpan" → cek login dulu, jika belum → redirect ke Login
//  • Tab "Profil" → cek login dulu, jika belum → redirect ke Login

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme_constants.dart';
import 'navigation_controller.dart';
import '../../app/routes/app_pages.dart';
import '../../app/services/auth_service.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomNavBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NavigationController>()) {
      Get.put(NavigationController());
    }
    final navController = Get.find<NavigationController>();

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_filled,
            label: 'Beranda',
            isActive: selectedIndex == 0,
            onTap: () {
              if (selectedIndex != 0) {
                navController.changeTo(0);
                Get.offAllNamed(Routes.HOME);
              }
            },
          ),
          _NavItem(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore,
            label: 'Jelajahi',
            isActive: selectedIndex == 1,
            onTap: () {
              if (selectedIndex != 1) {
                navController.changeTo(1);
                Get.offAllNamed(Routes.JELAJAHI);
              }
            },
          ),
          _NavItem(
            icon: Icons.bookmark_outline,
            activeIcon: Icons.bookmark,
            label: 'Simpan',
            isActive: selectedIndex == 2,
            onTap: () {
              // ── Auth guard: Simpan wajib login ──
              if (!AuthService.to.isLoggedIn.value) {
                AuthService.to.requireLogin(
                  message: 'Login terlebih dahulu untuk melihat simpanan.',
                );
                return;
              }
              if (selectedIndex != 2) {
                navController.changeTo(2);
                Get.offAllNamed(Routes.SIMPAN);
              }
            },
          ),
          _NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
            isActive: selectedIndex == 3,
            onTap: () {
              // ── Auth guard: Profil wajib login ──
              if (!AuthService.to.isLoggedIn.value) {
                AuthService.to.requireLogin(
                  message: 'Login terlebih dahulu untuk melihat profil.',
                );
                return;
              }
              if (selectedIndex != 3) {
                navController.changeTo(3);
                Get.offAllNamed(Routes.PROFILE);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isActive)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? AppColors.primaryColor
                      : Colors.white.withOpacity(0.5),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? AppColors.primaryColor
                        : Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}