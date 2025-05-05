import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/data/models/user_profile.dart';
import 'package:park_wallet/global/custom_exception.dart';
import 'package:park_wallet/services/auth_service.dart';

class ProfileRepository {
  AuthService authService = Get.find<AuthService>();

  Future<UserProfile> fetchUserProfile() async {
    final userId = authService.userId;
    if (userId == null) throw CustomException('Usuário não autenticado.');

    final url = Uri.parse(Endpoints.profileEndpoint.replaceFirst('{id}', userId));
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
      return UserProfile.fromJson(data);
    } else if (status == 401) {
      await authService.logout();
      throw CustomException('Sessão expirada. Faça login novamente.');
    } else {
      log('Erro $status ao buscar perfil: ${response.body}');
      throw CustomException('Erro ao buscar perfil: $status');
    }
  }

}