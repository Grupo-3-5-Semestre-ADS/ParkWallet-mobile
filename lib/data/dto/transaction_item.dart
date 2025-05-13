class TransactionItem {
  final int productId;
  final int quantity;
  final double totalValue;

  TransactionItem({
    required this.productId,
    required this.quantity,
    required this.totalValue,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      productId: json['productId'],
      quantity: json['quantity'],
      totalValue: double.tryParse(json['totalValue']?.toString() ?? '0') ?? 0,
    );
  }
}
