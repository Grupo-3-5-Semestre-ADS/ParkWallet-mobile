// Arquivo: facility_model.dart

import 'dart:convert'; // Necessário para jsonEncode em toJson se for usar

class Product {
  final String id;
  final String name;
  final double price;
  final String storeId; // ID da facility/loja a que este produto pertence
  final String? image;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.storeId,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'storeId': storeId,
      'image': image,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // A API de produtos pode enviar ID como int ou String, convertendo para String garante consistência.
      id: json['id'].toString(),
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      // A API de produtos pode enviar storeId como int ou String
      storeId: json['storeId'].toString(),
      image: json['image'] as String?,
    );
  }
}

class Facility { // Renomeado de Store para Facility
  final String id;
  final String name;
  final String type; // "store", "attraction", "other"
  final String? image;
  final String description;
  final double? latitude;
  final double? longitude;
  final String? horario;
  final bool inactive;
  final List<Product> products; // Lista de produtos associados a esta facility

  Facility({
    required this.id,
    required this.name,
    required this.type,
    this.image,
    required this.description,
    this.latitude,
    this.longitude,
    this.horario,
    this.inactive = false,
    this.products = const [], // Default para lista vazia
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      // A API /api/facilities envia 'id' como int. Convertendo para String.
      id: json['id'].toString(),
      name: json['name'] as String,
      type: json['type'] as String, // Ex: "store", "attraction", "other"
      description: json['description'] as String,
      image: json['image'] as String?,
      latitude: (json['latitude'] != null)
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: (json['longitude'] != null)
          ? double.tryParse(json['longitude'].toString())
          : null,
      horario: json['horario'] as String?,
      inactive: json['inactive'] as bool? ?? false,
      // Se a API /api/facilities retornar uma lista de 'products' aninhada,
      // ela será parseada aqui. Caso contrário, será uma lista vazia.
      products: (json['products'] as List<dynamic>?)
              ?.map((pJson) => Product.fromJson(pJson as Map<String, dynamic>))
              .toList() ??
          const [], // Se 'products' não existir ou for null, usa lista vazia
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'image': image,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'horario': horario,
      'inactive': inactive,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}