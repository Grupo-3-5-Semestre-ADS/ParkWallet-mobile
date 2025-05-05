import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:park_wallet/data/dto/user_register_request.dart';
import 'package:park_wallet/repositories/auth_repository.dart';

class RegisterController extends GetxController {
  final PageController pageController = PageController();
  AuthRepository authRepository = AuthRepository();
  RxInt currentPage = 0.obs;
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController cpfCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  TextEditingController repeatPasswordCtrl = TextEditingController();
  TextEditingController dateCtrl = TextEditingController();
  Rx<DateTime> selectedDate = DateTime.now().obs;

  void nextPage() {
    if (validateFirstPage()) {
      currentPage.value = 1;
      pageController.nextPage(duration: 300.milliseconds, curve: Curves.ease);
    }
  }

  void prevPage() {
    currentPage.value = 0;
    pageController.previousPage(duration: 300.milliseconds, curve: Curves.ease);
  }

  void register() async {
    if (validateSecondPage()) {
      final request = UserRegisterRequest(
        name: nameCtrl.text.trim(),
        cpf: cpfCtrl.text.replaceAll(RegExp(r'\D'), ''),
        birthDate: _formatBirthdate(dateCtrl.text.trim()),
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );

      try {
        await authRepository.fetchRegister(request);
        Get.snackbar('Sucesso', 'Conta criada com sucesso!');
        Get.offNamed('/login');
      } catch (e) {
        Get.snackbar('Erro', 'Não foi possível criar a conta: $e');
        log('Erro no register(): $e');
      }
    }
  }

  void cancel(){
    Get.offNamed('/login');

  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  bool validateFirstPage() {
    if (nameCtrl.text.trim().isEmpty ||
        cpfCtrl.text.trim().isEmpty ||
        dateCtrl.text.trim().isEmpty) {
      Get.snackbar('Erro', 'Preencha todos os campos');
      return false;
    }

    final cpfClean = cpfCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (cpfClean.length != 11) {
      Get.snackbar('CPF inválido', 'Digite um CPF válido com 11 dígitos');
      return false;
    }

    if (dateCtrl.text.length != 10) {
      Get.snackbar('Data inválida', 'Digite a data de nascimento corretamente');
      return false;
    }

    return true;
  }

  bool validateSecondPage() {
    if (emailCtrl.text.trim().isEmpty ||
        passwordCtrl.text.isEmpty ||
        repeatPasswordCtrl.text.isEmpty) {
      Get.snackbar('Erro', 'Preencha todos os campos');
      return false;
    }

    if (!GetUtils.isEmail(emailCtrl.text.trim())) {
      Get.snackbar('Email inválido', 'Digite um email válido');
      return false;
    }

    final password = passwordCtrl.text;

    final hasMinLength = password.length >= 8;
    final hasLetters = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);

    if (!hasMinLength || !hasLetters || !hasNumbers) {
      Get.snackbar(
        'Senha inválida',
        'A senha deve ter no mínimo 8 caracteres e conter letras e números',
      );
      return false;
    }

    if (password != repeatPasswordCtrl.text) {
      Get.snackbar('Erro', 'As senhas não coincidem');
      return false;
    }

    return true;
  }

  String _formatBirthdate(String date) {
    final parts = date.split('/');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }


  @override
  void onInit() {
    super.onInit();
    dateCtrl.text = formatDate(selectedDate.value);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
