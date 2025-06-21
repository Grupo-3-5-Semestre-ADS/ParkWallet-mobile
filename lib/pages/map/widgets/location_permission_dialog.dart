import 'package:flutter/material.dart';
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
            const Expanded(
              child: Text(
                'Permitir localização',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O ParkWallet precisa acessar sua localização para:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.near_me, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Encontrar lojas próximas a você')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.navigation, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Mostrar sua posição no mapa')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.route, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Calcular distâncias')),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Esta permissão é necessária para o funcionamento completo do aplicativo.',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: onDenyPressed,
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: const Text('Negar', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: onAllowPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sapphire,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Abrir configurações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}