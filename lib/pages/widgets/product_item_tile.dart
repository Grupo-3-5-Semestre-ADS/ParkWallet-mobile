import 'package:flutter/material.dart';
import 'package:park_wallet/data/models/product.dart';

class ProductItemTile extends StatelessWidget {
  final Product item;
  final VoidCallback? onTap;

  const ProductItemTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: item.image != null
          ? Image.asset(item.image!, width: 36, height: 36)
          : Icon(Icons.fastfood, size: 28, color: Colors.grey[700]),
      title: Text(
        item.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Text(
        'R\$ ${item.price.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onTap != null
          ? Icon(Icons.add_shopping_cart, size: 20, color: Colors.grey[700])
          : null,
      onTap: onTap,
    );
  }
}