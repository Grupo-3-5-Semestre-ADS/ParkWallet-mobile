import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/data/models/store.dart';
import 'package:park_wallet/global/custom_exception.dart';
import 'package:park_wallet/services/auth_service.dart';
import 'package:park_wallet/data/models/product.dart';

class StoreRepository {
  final AuthService authService = Get.find<AuthService>();

  Future<List<Store>> fetchStores() async {
    final url = Uri.parse(Endpoints.storesEndpoint);
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authService.token}',
      },
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded is List ? decoded : decoded['data'];
      return data.map((json) => Store.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      await authService.logout();
      throw CustomException('Sessão expirada. Faça login novamente.');
    } else {
      log('Erro ${response.statusCode} ao buscar lojas: ${response.body}');
      throw CustomException('Erro ao buscar lojas: ${response.statusCode}');
    }
  }

  Future<Store> fetchStoreById(String id) async {
    final url = Uri.parse(Endpoints.storeDetailEndpoint.replaceFirst('{id}', id));
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authService.token}',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Store.fromJson(data);
    } else if (response.statusCode == 401) {
      await authService.logout();
      throw CustomException('Sessão expirada. Faça login novamente.');
    } else {
      log('Erro ${response.statusCode} ao buscar loja: ${response.body}');
      throw CustomException('Erro ao buscar loja: ${response.statusCode}');
    }
  }

  Future<List<Product>> fetchStoreProducts(String storeId) async {
    final url = Uri.parse(Endpoints.storeProductsEndpoint.replaceFirst('{id}', storeId));
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authService.token}',
      },
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded is List ? decoded : decoded['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      await authService.logout();
      throw CustomException('Sessão expirada. Faça login novamente.');
    } else {
      log('Erro ${response.statusCode} ao buscar produtos da loja: ${response.body}');
      throw CustomException('Erro ao buscar produtos da loja: ${response.statusCode}');
    }
  }
}