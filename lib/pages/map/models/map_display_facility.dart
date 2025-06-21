import 'package:park_wallet/data/dto/product_response.dart' as dto;
import 'package:park_wallet/data/models/product.dart' as ui_model;

class MapDisplayFacility {
  final dto.Facility _facilityData;
  List<ui_model.Product> products;
  final String? image;
  final String? horario;

  MapDisplayFacility({
    required dto.Facility facilityData,
    this.products = const [],
    this.image,
    this.horario,
  }) : _facilityData = facilityData;

  String get id => _facilityData.id.toString();
  String get name => _facilityData.name;
  String get type => _facilityData.type;
  String get description => _facilityData.description;
  double? get latitude => _facilityData.latitude.isNotEmpty ? double.tryParse(_facilityData.latitude) : null;
  double? get longitude => _facilityData.longitude.isNotEmpty ? double.tryParse(_facilityData.longitude) : null;
  bool get inactive => !_facilityData.active;

  factory MapDisplayFacility.fromJson(Map<String, dynamic> json) {
    final facilityDto = dto.Facility.fromJson(json);
    final String? imageFromJson = json['image'] as String?;
    final String? horarioFromJson = json['horario'] as String?;
    return MapDisplayFacility(
      facilityData: facilityDto,
      image: imageFromJson,
      horario: horarioFromJson,
      products: [],
    );
  }
}