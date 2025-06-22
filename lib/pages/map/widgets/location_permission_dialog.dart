import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/constants/app_colors.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllowPressed;
  final VoidCallback onDenyPressed;

  const LocationPermissionDialog({
    super.key,
    required this.onAllowPressed,
    required this.onDenyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.sapphire, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'allow_location'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'location_permission_rationale'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.near_me, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('find_nearby_stores'.tr)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.navigation, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('show_position_on_map'.tr)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.route, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('calculate_distances'.tr)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'location_permission_needed'.tr,
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: onDenyPressed,
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: Text('deny'.tr, style: const TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: onAllowPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sapphire,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('open_settings'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}