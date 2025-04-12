import 'package:flutter/material.dart';
import 'package:park_wallet/data/models/store.dart';

class StoreItemTile extends StatelessWidget {
  final Store item;
  final VoidCallback? onTap;

  const StoreItemTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: item.image != null
          ? Image.asset(item.image!, width: 36, height: 36)
          : const Icon(Icons.store, size: 28),
      title: Text(
        item.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Text(
        item.type,
        style: const TextStyle(fontSize: 11),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}