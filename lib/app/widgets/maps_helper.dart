import 'package:flutter/material.dart';
import 'theme_constants.dart';

class MapsPreviewTile extends StatelessWidget {
  final String address;
  final VoidCallback onTap;
  final bool hasLink;

  const MapsPreviewTile({
    super.key,
    required this.address,
    required this.onTap,
    this.hasLink = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasLink ? Icons.map : Icons.location_off_outlined,
                color: AppColors.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasLink ? 'Buka di Google Maps' : 'Link lokasi belum tersedia',
              style: TextStyle(
                color: hasLink ? AppColors.primaryColor : AppColors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                address,
                style: const TextStyle(color: AppColors.white70, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
