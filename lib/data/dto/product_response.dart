
class ProductResponse {
  final int id;
  final String name;
  final String description;
  final double price;
  final bool inactive;
  final String createdAt;
  final String updatedAt;
  final int facilityId;
  final Facility? facility;

  ProductResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.inactive,
    required this.createdAt,
    required this.updatedAt,
    required this.facilityId,
    this.facility,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0,
      inactive: json['inactive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      facilityId: json['facilityId'],
      facility: json['facility'] != null
          ? Facility.fromJson(json['facility'])
          : null,
    );
  }
}

class Facility {
  final int id;
  final String name;
  final String description;
  final String type;
  final String latitude;
  final String longitude;
  final bool inactive;
  final String createdAt;
  final String updatedAt;

  Facility({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.inactive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      inactive: json['inactive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
