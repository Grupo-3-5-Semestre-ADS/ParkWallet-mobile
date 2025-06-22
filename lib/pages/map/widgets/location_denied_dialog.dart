import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';

class LocationDeniedDialog extends StatelessWidget {
  final VoidCallback onRetryPressed;

  const LocationDeniedDialog({
    super.key,
    required this.onRetryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.red[600], size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'location_denied'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'location_access_required'.tr,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'without_location_you_cannot'.tr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.close, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('see_position_on_map'.tr, style: const TextStyle(fontSize: 14))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.close, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('find_nearby'.tr, style: const TextStyle(fontSize: 14))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.close, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('calculate_distances'.tr, style: const TextStyle(fontSize: 14))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: Text('go_back'.tr),
          ),
          ElevatedButton(
            onPressed: onRetryPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sapphire,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('try_again'.tr),
          ),
        ],
      ),
    );
  }
}