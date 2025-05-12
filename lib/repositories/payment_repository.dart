import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/data/dto/product_payment_request.dart';
import 'package:park_wallet/data/models/user_profile.dart';
import 'package:park_wallet/global/custom_exception.dart';
import 'package:park_wallet/services/auth_service.dart';

class PaymentRepository {
  AuthService authService = Get.find<AuthService>();

  Future<String> fetchPayment(List<ProductPaymentRequest> products) async {
    final userId = authService.userId;
    if (userId == null) throw CustomException('Usuário não autenticado.');

    final url = Uri.parse(Endpoints.paymentEndpoint.replaceFirst('{id}', userId));
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authService.token}',
      },
      body: jsonEncode({
        'products': products.map((p) => p.toJson()).toList(),
      }),
    );

    final status = response.statusCode;

    if (status == 200) {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'Pagamento realizado.';
    } else if (status == 401) {
      await authService.logout();
      throw CustomException('Sessão expirada. Faça login novamente.');
    } else {
      final data = jsonDecode(response.body);
      final errorMessage = data['error'] ?? 'Erro desconhecido ao efetuar pagamento.';
      log('Erro $status ao efetuar pagamento: $errorMessage');
      throw CustomException(errorMessage);
    }
  }



}