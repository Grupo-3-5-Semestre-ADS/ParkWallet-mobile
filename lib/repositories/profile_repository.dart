import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/data/dto/user_profile_update_request.dart';
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

  Future<void> updateUserProfile(UserProfileUpdateRequest request) async {
    final userId = authService.userId;
    if (userId == null) throw CustomException('Usuário não autenticado.');
    final url = Endpoints.profileEndpoint.replaceFirst('{id}', userId);
    final uri = Uri.parse(url);

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.token}',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception("Erro ao atualizar perfil: ${response.body}");
      }

      log('[ProfileRepository] Profile update successful.');
    } catch (e) {
      log('[ProfileRepository] Error: $e');
      rethrow;
    }
  }
}