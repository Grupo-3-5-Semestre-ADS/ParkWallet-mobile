import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:park_wallet/services/AuthService.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    return null; // segue para rota original
  }
}