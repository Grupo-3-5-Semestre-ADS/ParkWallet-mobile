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

  Future<double> rechargeCredit(double amount) async {
    final userId = authService.userId;
    if (userId == null) throw CustomException('Usuário não autenticado.');

    final url = Uri.parse(Endpoints.rechargeEndpoint.replaceFirst('{id}', userId));
    log('Tentando recarga. URL: $url, Valor: $amount, UserId: $userId');
    
    try {
      log('Token de autenticação: ${authService.token?.substring(0, 20)}...');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.token}',
        },
        body: jsonEncode({
          'amount': amount,
        }),
      );

      final status = response.statusCode;
      log('Resposta recebida. Status: $status');
      log('Corpo da resposta: ${response.body}');
      
      // Verificar se o corpo da resposta está vazio ou inválido
      if (response.body.isEmpty) {
        log('Resposta vazia, buscando saldo atualizado');
        return await fetchBalance();
      }
      
      try {
        final data = jsonDecode(response.body);

        if (status == 200) {
          if (data['transaction'] != null && data['transaction']['newBalance'] != null) {
            final newBalance = double.tryParse(data['transaction']['newBalance'].toString()) ?? 0.0;
            log('Novo saldo obtido: $newBalance');
            return newBalance;
          } else {
            log('Novo saldo não encontrado na resposta, buscando saldo atual');
            // Caso o novo saldo não seja retornado, buscar o saldo atualizado
            return await fetchBalance();
          }
        } else {
          final errorMessage = data['message'] ?? data['error'] ?? 'Erro ao processar recarga.';
          log('Erro na recarga: $errorMessage');
          throw CustomException(errorMessage);
        }
      } catch (parseError) {
        log('Erro ao processar JSON da resposta: $parseError');
        // Se a recarga foi processada mas houve erro no parse, buscar o saldo atualizado
        if (status == 200) {
          return await fetchBalance();
        } else {
          throw CustomException('Erro ao processar resposta do servidor');
        }
      }
    } catch (e) {
      if (e is CustomException) rethrow;
      log('Erro ao processar recarga: $e');
      throw CustomException('Falha na comunicação com o servidor.');
    }
  }
}