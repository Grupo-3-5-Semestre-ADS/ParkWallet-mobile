import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:park_wallet/repositories/login_repository.dart";
import "package:park_wallet/services/auth_service.dart";

class LoginController extends GetxController {

  final LoginRepository loginRepo = LoginRepository();

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  void login() {
    print("email: ${emailCtrl.text}");
    print("senha: ${passwordCtrl.text}");
    final authService = Get.find<AuthService>();
    authService.saveToken('token-jwt-falso');
    Get.offAllNamed('/home');
  }

  void register() {
    Get.toNamed('/register');
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

}
