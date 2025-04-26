import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/data/dto/login_request.dart';

class AuthRepository {

  Future<String> fetchLogin(LoginRequest requestBody) async {
    final url = Uri.parse(Endpoints.loginEndpoint);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody.toMap()),
    );

    int status = response.statusCode;

    if (status == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      log('Login bem-sucedido! Token: $token');
      return token;
    } if (status == 401) {
      throw Exception('invalid_credentials'.tr);
    } else {
      log('Erro ${response.statusCode} ao fazer login: ${response.body}');
      throw Exception('Erro ao fazer login: ${response.statusCode}');
    }
  }

  Future<String> fetchRegister(LoginRequest requestBody) async {
    final url = Uri.parse(Endpoints.loginEndpoint);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody.toMap()),
    );

    int status = response.statusCode;

    if (status == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      log('Login bem-sucedido! Token: $token');
      return token;
    } if (status == 401) {
      throw Exception('invalid_credentials'.tr);
    } else {
      log('Erro ${response.statusCode} ao fazer login: ${response.body}');
      throw Exception('Erro ao fazer login: ${response.statusCode}');
    }
  }

}