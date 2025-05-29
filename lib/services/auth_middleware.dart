import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:park_wallet/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    final hasValidToken = authService.hasValidToken ?? false;
    if (!hasValidToken) {
      return const RouteSettings(name: '/login');
    }
    return null; // segue para rota original
  }
}