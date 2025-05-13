import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/data/dto/transaction.dart';
import 'package:park_wallet/global/custom_exception.dart';
import 'package:park_wallet/services/auth_service.dart';

class HistoryRepository {
  final AuthService authService = Get.find<AuthService>();

  Future<List<Transaction>> fetchHistory({int page = 1, int size = 10}) async {
    final userId = authService.userId;
    if (userId == null) throw CustomException('Usuário não autenticado.');

    final uri = Uri.parse(
      Endpoints.historyEndpoint.replaceFirst('{id}', userId),
    ).replace(queryParameters: {
      '_page': page.toString(),
      '_size': size.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${authService.token}',
      },
    );

    final status = response.statusCode;

    if (status == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];

      return data.map((json) => Transaction.fromJson(json)).toList();
    } else if (status == 401) {
      await authService.logout();
      throw CustomException('Sessão expirada. Faça login novamente.');
    } else {
      final data = jsonDecode(response.body);
      final errorMessage = data['error'] ?? 'Erro desconhecido ao buscar transações.';
      log('Erro $status ao buscar transações: $errorMessage');
      throw CustomException(errorMessage);
    }
  }
}

