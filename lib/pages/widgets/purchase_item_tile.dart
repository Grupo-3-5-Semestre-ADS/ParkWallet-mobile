import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:park_wallet/data/dto/product_response.dart';
import 'package:park_wallet/data/dto/transaction.dart';
import 'package:park_wallet/repositories/product_repository.dart';
import 'package:get/get.dart';


void showTransactionDetailsModal(BuildContext context, Transaction transaction) {
  final productRepo = ProductRepository();

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Detalhes da Transação"),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait(
            transaction.items.map((item) async {
              final product = await productRepo.fetchProductById(item.productId);
              return {
                "product": product,
                "quantity": item.quantity,
                "total": item.totalValue,
              };
            }),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return Text("Erro: ${snapshot.error}");
            } else {
              final items = snapshot.data!;
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final entry = items[index];
                    final ProductResponse product = entry['product'];
                    final int quantity = entry['quantity'];
                    final double total = entry['total'];

                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        "Quantidade: $quantity\n"
                            "Instalação: ${product.facility?.name ?? 'N/A'}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        "R\$ ${total.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
        actions: [
          TextButton(
            child: const Text("Fechar"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      );
    },
  );
}


class PurchaseItemTile extends StatelessWidget {
  final Transaction transaction;

  const PurchaseItemTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(transaction.createdAt);
    final formattedDateTime = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading:const Icon(Icons.fastfood, size: 28),
      title: Text(
        "purchase_completed".tr,
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
        ],
      ),
      trailing: Text(
        "- R\$${transaction.totalValue.toStringAsFixed(2)}",
        style: const TextStyle(color: Colors.red, fontSize: 14),
      ),
      onTap: () {
        showTransactionDetailsModal(context, transaction);
      },
    );
  }
}
