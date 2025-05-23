import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:park_wallet/constants/endpoints.dart';
import 'package:get/get.dart';
import 'package:park_wallet/data/dto/product_response.dart';
import 'package:park_wallet/services/auth_service.dart';

class ProductRepository {
  final authService = Get.find<AuthService>();

  Future<ProductResponse> fetchProductById(int id) async {
    final url = Uri.parse(Endpoints.productsEndpoint.replaceFirst('{id}', id.toString()));
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${authService.token}',
      },
    );

    log('Status code: ${response.statusCode}');
    log('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProductResponse.fromJson(data);
    } else {
      log('Erro ao buscar produto $id: ${response.body}');
      throw Exception('Erro ao buscar produto $id');
    }
  }
}
