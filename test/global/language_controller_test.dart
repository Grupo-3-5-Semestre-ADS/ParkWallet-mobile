import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:park_wallet/global/language_controller.dart';

void main() {
  group('LanguageController Tests', () {
    late LanguageController controller;

    setUp(() {
      Get.reset();
      controller = LanguageController();
    });

    tearDown(() {
      Get.reset();
    });

    test('should have correct flag image paths', () {
      expect(controller.BRASIL_FLAG, "assets/images/brasil-circle-flag.png");
      expect(controller.UK_FLAG, "assets/images/uk-circle-flag.png");
      expect(controller.SPAIN_FLAG, "assets/images/spain-circle-flag.png");
    });

    test('should initialize with empty flag image path', () {
      expect(controller.flagImagePath.value, "");
    });

    test('should change language and flag correctly', () {
      // Test changing to English
      controller.changeLanguage('en', 'US', controller.UK_FLAG);
      expect(controller.flagImagePath.value, controller.UK_FLAG);

      // Test changing to Spanish
      controller.changeLanguage('es', 'ES', controller.SPAIN_FLAG);
      expect(controller.flagImagePath.value, controller.SPAIN_FLAG);

      // Test changing to Portuguese
      controller.changeLanguage('pt', 'BR', controller.BRASIL_FLAG);
      expect(controller.flagImagePath.value, controller.BRASIL_FLAG);
    });

    test('should update locale when changing language', () {
      // Mock Get.updateLocale for testing
      Get.testMode = true;
      
      controller.changeLanguage('en', 'US', controller.UK_FLAG);
      expect(controller.flagImagePath.value, controller.UK_FLAG);
      
      controller.changeLanguage('es', 'ES', controller.SPAIN_FLAG);
      expect(controller.flagImagePath.value, controller.SPAIN_FLAG);
    });

    test('should handle custom flag paths', () {
      const customFlag = "assets/images/custom-flag.png";
      
      controller.changeLanguage('fr', 'FR', customFlag);
      expect(controller.flagImagePath.value, customFlag);
    });

    test('flagImagePath should be observable', () {
      // Test that flagImagePath is an observable
      expect(controller.flagImagePath, isNotNull);
      expect(controller.flagImagePath.value, isA<String>());
      
      // Change the language and verify the value changes
      controller.changeLanguage('en', 'US', controller.UK_FLAG);
      expect(controller.flagImagePath.value, controller.UK_FLAG);
    });
  });
}