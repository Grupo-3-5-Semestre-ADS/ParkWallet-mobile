import 'package:flutter/material.dart';
import 'package:park_wallet/data/models/store.dart';
import 'package:park_wallet/constants/app_colors.dart';

class StoreItemTile extends StatelessWidget {
  final Store item;
  final VoidCallback? onTap;

  const StoreItemTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: item.image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.image!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                Icons.store,
                size: 24,
                color: Colors.grey[700],
              ),
      ),
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
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[700]),
      onTap: onTap,
    );
  }
}