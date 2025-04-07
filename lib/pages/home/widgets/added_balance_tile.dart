import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:park_wallet/data/models/transaction.dart';

class AddedBalanceTile extends StatelessWidget {
  final Transaction item;

  const AddedBalanceTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Center(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: const Icon(Icons.attach_money, color: Colors.green),
          title: Text(
            "added_balance".tr,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
          ),
          trailing: Text(
            "+ R\$${item.price.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.green, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
