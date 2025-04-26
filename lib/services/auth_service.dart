import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  String? get token => _token;
  bool? get hasValidToken => _validateToken();

  Future<AuthService> init() async {
    _token = await _storage.read(key: _tokenKey);
    print('[AuthService] Token carregado: $_token'); // 👈 debug aqui
    return this;
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
    print('[AuthService] Token salvo: $_token');
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
    Get.offAllNamed('/login');
  }

  bool _validateToken () {
    if(_isTokenExpired())
      return false;

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
