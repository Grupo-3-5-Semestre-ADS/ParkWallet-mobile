import 'transaction_item.dart';

class Transaction {
  final double totalValue;
  final String operation;
  final List<TransactionItem> items;
  final String createdAt;

  Transaction({
    required this.totalValue,
    required this.operation,
    required this.items,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      totalValue: double.tryParse(json['totalValue']?.toString() ?? '0') ?? 0,
      operation: json['operation'] ?? '',
      createdAt: json['createdAt'] ?? '',
      items: (json['itemsTransaction'] as List<dynamic>)
          .map((item) => TransactionItem.fromJson(item))
          .toList(),
    );
  }
}
