class Product {
  final String id;
  final String name;
  final double price;
  final String? image;
  final String? description;
  final String storeId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.storeId,
    this.image,
    this.description,
  });
}