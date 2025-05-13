import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:park_wallet/data/dto/transaction.dart';

class AddedBalanceTile extends StatelessWidget {
  final Transaction transaction;

  const AddedBalanceTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.parse(transaction.createdAt));

    return SizedBox(
      height: 70,
      child: Center(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: const Icon(Icons.attach_money, color: Colors.green),
          title: Text(
            "added_balance".tr,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            formattedDate,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Text(
            "+ R\$${transaction.totalValue.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.green, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
