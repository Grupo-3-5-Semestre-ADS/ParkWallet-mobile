import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  String? get token => _token;

  bool get isLoggedIn => _token != null && !_isTokenExpired();

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

  bool _isTokenExpired() {

    return false;
  }
}
