import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:park_wallet/data/models/transaction.dart';

class PurchaseItemTile extends StatelessWidget {
  final Transaction item;

  const PurchaseItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(item.dateTime);
    final formattedDateTime = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: item.image != null
          ? Image.asset(item.image!, width: 36, height: 36)
          : const Icon(Icons.fastfood, size: 28),
      title: Text(
        item.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Row(
        children: [
          Text(
            formattedDateTime,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.vendor,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Text(
        "- R\$${item.price.toStringAsFixed(2)}",
        style: const TextStyle(color: Colors.red, fontSize: 14),
      ),
    );
  }
}
