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
}