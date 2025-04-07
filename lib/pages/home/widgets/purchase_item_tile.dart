import 'package:flutter/material.dart';
import 'package:park_wallet/data/models/transaction.dart';

class PurchaseItemTile extends StatelessWidget {
  final Transaction item;

  const PurchaseItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Center(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: item.image != null
              ? Image.asset(item.image!, width: 40, height: 40)
              : const Icon(Icons.fastfood),
          title: Text(
            item.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            item.vendor,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Text(
            "- R\$${item.price.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

