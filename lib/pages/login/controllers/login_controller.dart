import "dart:developer";

import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:park_wallet/data/dto/login_request.dart";
import "package:park_wallet/repositories/auth_repository.dart";
import "package:park_wallet/services/auth_service.dart";

class LoginController extends GetxController {

  final AuthRepository authRepo = AuthRepository();

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  Future<void> login() async {
    String token;
    String email = emailCtrl.text;
    String password = passwordCtrl.text;
    LoginRequest loginRequest = LoginRequest(email: email, password: password);

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Erro", "Todos os campos devem ser preenchidos.");
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      Get.snackbar("Erro", "Formato de e-mail inválido.");
      return;
    }

    try {
      token = await authRepo.fetchLogin(loginRequest);
    } catch (e) {
      Get.snackbar("Error", e.toString());
      log(e.toString());
      return;
    }
    emailCtrl.text = "";
    passwordCtrl.text = "";
    Get.find<AuthService>().saveToken(token);
    Get.offAllNamed('/home');
  }

  void register() {
    cleanFields();
    Get.toNamed('/register');
  }

  void cleanFields() {
    emailCtrl.text = "";
    passwordCtrl.text = "";
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

}
