import 'package:flutter/material.dart';
import 'package:park_wallet/data/models/product.dart' as ui_model;

class ProductItemWidget extends StatelessWidget {
  final ui_model.Product product;

  const ProductItemWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, 
              height: 48, 
              decoration: BoxDecoration(
                color: Colors.grey[200], 
                borderRadius: BorderRadius.circular(10)
              ), 
              child: const Icon(Icons.fastfood, size: 28, color: Colors.grey)
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis
                  ),
                  if (product.description != null && product.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.description!, 
                      style: const TextStyle(fontSize: 13, color: Colors.black54), 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'R\$ ${product.price.toStringAsFixed(2)}', 
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.green)
            ),
          ],
        ),
      ),
    );
  }
}