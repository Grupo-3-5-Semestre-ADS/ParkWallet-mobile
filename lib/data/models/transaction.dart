class Transaction {
  final String name;
  final String vendor;
  final double price;
  final String? image;
  final String operation; // "purchase" ou "recharge"

  Transaction({
    required this.name,
    required this.vendor,
    required this.price,
    required this.operation,
    this.image,
  });
}
