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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      price: double.parse(json['price'].toString()),
      storeId: json['storeId']?.toString() ?? json['facilityId']?.toString() ?? '',
      image: json['image'],
      description: json['description'],
    );
  }
}