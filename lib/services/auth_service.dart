import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:park_wallet/services/profile_service.dart';

class AuthService extends GetxService {
  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  String? get token => _token;
  bool? get hasValidToken => _validateToken();

  String? get userId {
    if (_token == null) return null;

    try {
      final parts = _token!.split('.');
      if (parts.length != 3) return null;

      final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      return payload['id']?.toString();
    } catch (e) {
      log('[AuthService] Erro ao obter id do token: $e');
      return null;
    }
  }

  Future<AuthService> init() async {
    _token = await _storage.read(key: _tokenKey);
    log('[AuthService] ${_token != null ? 'Token carregado: $_token' : "Nenhum token encontrado."}');
    return this;
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
    log('[AuthService] Token salvo: $_token');
    Get.find<ProfileService>().refreshProfile();
  }

  Future<void> logout() async {
    Get.snackbar(
      "Sessão inválida",
      "Sua sessão expirou. Faça login novamente.",
    );
    _token = null;
    await _storage.delete(key: _tokenKey);
    Get.offAllNamed('/login');
  }

  bool _validateToken () {
    if(_isTokenExpired()) {
      return false;
    }

    return true;
  }

  bool _isTokenExpired() {
    if (_token == null) return true;

    try {
      final parts = _token!.split('.');
      if (parts.length != 3) return true;

      final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'];

      if (exp is int) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        return DateTime.now().isAfter(expiryDate);
      } else {
        return true;
      }
    } catch (e) {
      log('[AuthService] Erro ao verificar expiração do token: $e');
      return true;
    }
  }

}
