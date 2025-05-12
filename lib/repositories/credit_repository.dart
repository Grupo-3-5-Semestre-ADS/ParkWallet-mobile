import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/data/dto/product_payment_request.dart';
import 'package:park_wallet/data/models/user_profile.dart';
import 'package:park_wallet/global/custom_exception.dart';
import 'package:park_wallet/services/auth_service.dart';

class CreditRepository {
  AuthService authService = Get.find<AuthService>();

  Future<double> fetchBalance() async {
    final userId = authService.userId;
    if (userId == null) throw CustomException('Usuário não autenticado.');

    final url = Uri.parse(Endpoints.balanceEndpoint.replaceFirst('{id}', userId));

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authService.token}',
      },
    );

    final status = response.statusCode;

    if (status == 200) {
      final data = jsonDecode(response.body);
      final balanceStr = data['balance'];

      if (balanceStr != null) {
        return double.tryParse(balanceStr) ?? 0.0;
      } else {
        throw CustomException('Saldo não encontrado na resposta.');
      }
    } else if (status == 401) {
      await authService.logout();
      throw CustomException('Sessão expirada. Faça login novamente.');
    } else {
      final data = jsonDecode(response.body);
      final errorMessage = data['message'] ?? 'Erro desconhecido ao buscar saldo.';
      log('Erro $status ao buscar saldo: $errorMessage');
      throw CustomException(errorMessage);
    }
  }



}