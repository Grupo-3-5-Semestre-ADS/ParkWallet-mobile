import "dart:developer";

import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:park_wallet/data/dto/login_request.dart";
import "package:park_wallet/repositories/auth_repository.dart";
import "package:park_wallet/services/auth_service.dart";
import "package:url_launcher/url_launcher.dart";
class LoginController extends GetxController {
  final AuthRepository authRepo = AuthRepository();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  final RxBool isLoading = false.obs;

  Future<void> login() async {
    if (isLoading.value) return;
    isLoading.value = true;

    final email = emailCtrl.text;
    final password = passwordCtrl.text;
    final loginRequest = LoginRequest(email: email, password: password);
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Erro", "Todos os campos devem ser preenchidos.");
      isLoading.value = false;
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      Get.snackbar("Erro", "Formato de e-mail inválido.");
      isLoading.value = false;
      return;
    }

    try {
      final token = await authRepo.fetchLogin(loginRequest);
      emailCtrl.clear();
      passwordCtrl.clear();
      Get.find<AuthService>().saveToken(token);
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar("Erro", e.toString());
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void register() {
    cleanFields();
    Get.toNamed('/register');
  }

  void cleanFields() {
    emailCtrl.clear();
    passwordCtrl.clear();
  }

  void contactSupportViaWhatsApp() async {
    final phoneNumber = '554599388327';
    final message = Uri.encodeComponent("Olá! Esqueci minha senha, podem me ajudar?");
    final urlString = "https://wa.me/$phoneNumber?text=$message";
    final url = Uri.parse(urlString);

    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        Get.snackbar("Erro", "Não foi possível abrir o WhatsApp.");
      }
    } catch (e) {
      Get.snackbar("Erro", "Erro ao abrir o WhatsApp: $e");
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }
}
