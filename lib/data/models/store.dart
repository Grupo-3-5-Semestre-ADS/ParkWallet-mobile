class Store {
  final String id;
  final String name;
  final String type;
  final String? image;
  final String? description;

  Store({
    required this.id,
    required this.name,
    required this.type,
    this.image,
    this.description,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      image: json['image'],
      description: json['description'],
    );
  }
}