import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme_constants.dart';

class MapsHelper {
  static Future<void> openGoogleMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedQuery');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak bisa membuka Google Maps';
      }
    } catch (e) {
      // Anda bisa menampilkan snackbar jika perlu, tapi biarkan saja atau log
      debugPrint('Error opening maps: $e');
    }
  }
}

class MapsPreviewTile extends StatelessWidget {
  final String location;
  final String address;

  const MapsPreviewTile({
    super.key,
    required this.location,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await MapsHelper.openGoogleMaps(location);
      },
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
              child: const Icon(Icons.map, color: AppColors.primaryColor, size: 32),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buka di Google Maps',
              style: TextStyle(
                color: AppColors.primaryColor,
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