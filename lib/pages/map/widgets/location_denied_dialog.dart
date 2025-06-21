import 'package:flutter/material.dart';
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
            const Expanded(
              child: Text(
                'Localização Negada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O acesso à localização é obrigatório para usar o mapa do ParkWallet.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Sem a localização, você não poderá:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.close, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Ver sua posição no mapa', style: TextStyle(fontSize: 14))),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.close, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Encontrar lojas próximas', style: TextStyle(fontSize: 14))),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.close, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Calcular distâncias', style: TextStyle(fontSize: 14))),
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
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: onRetryPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sapphire,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}