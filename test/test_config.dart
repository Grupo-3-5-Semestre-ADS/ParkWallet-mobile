import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Configuração global para testes unitários
class TestConfig {
  static void setupTestEnvironment() {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Configurar Get para testes
    Get.testMode = true;
    
    // Não atualizar locale durante testes para evitar conflitos
    // Get.updateLocale(const Locale('pt', 'BR'));
  }

  static void tearDownTestEnvironment() {
    // Limpa todas as instâncias do GetX
    Get.reset();
  }
}

/// Mixin para facilitar testes de controllers
mixin ControllerTestMixin {
  void setUpController() {
    TestConfig.setupTestEnvironment();
  }

  void tearDownController() {
    TestConfig.tearDownTestEnvironment();
  }
} 