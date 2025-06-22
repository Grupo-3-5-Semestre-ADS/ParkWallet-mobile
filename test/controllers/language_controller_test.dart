import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:park_wallet/global/language_controller.dart';

void main() {
  group('LanguageController Tests', () {
    late LanguageController languageController;

    setUp(() {
      Get.testMode = true;
      languageController = LanguageController();
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with correct flag constants', () {
        expect(languageController.BRASIL_FLAG, equals("assets/images/brasil-circle-flag.png"));
        expect(languageController.UK_FLAG, equals("assets/images/uk-circle-flag.png"));
        expect(languageController.SPAIN_FLAG, equals("assets/images/spain-circle-flag.png"));
      });

      test('should initialize with empty flag image path', () {
        expect(languageController.flagImagePath.value, isEmpty);
      });

      test('should set Brazilian flag for Portuguese locale on init', () {
        // Arrange
        Get.locale = const Locale('pt', 'BR');
        
        // Act
        languageController.onInit();
        
        // Assert
        expect(languageController.flagImagePath.value, equals(languageController.BRASIL_FLAG));
        expect(Get.locale?.languageCode, equals('pt'));
        expect(Get.locale?.countryCode, equals('BR'));
      });

      test('should set UK flag for English locale on init', () {
        // Arrange
        Get.locale = const Locale('en', 'US');
        
        // Act
        languageController.onInit();
        
        // Assert
        expect(languageController.flagImagePath.value, equals(languageController.UK_FLAG));
        expect(Get.locale?.languageCode, equals('en'));
      });

      test('should set Spanish flag for Spanish locale on init', () {
        // Arrange
        Get.locale = const Locale('es', 'ES');
        
        // Act
        languageController.onInit();
        
        // Assert
        expect(languageController.flagImagePath.value, equals(languageController.SPAIN_FLAG));
        expect(Get.locale?.languageCode, equals('es'));
      });

      test('should default to Brazilian flag for unknown locale on init', () {
        // Arrange
        Get.locale = const Locale('fr', 'FR'); // French locale
        
        // Act
        languageController.onInit();
        
        // Assert
        expect(languageController.flagImagePath.value, equals(languageController.BRASIL_FLAG));
      });

      test('should default to Brazilian flag when no locale is set', () {
        // Arrange
        Get.locale = null;
        
        // Act
        languageController.onInit();
        
        // Assert
        expect(languageController.flagImagePath.value, equals(languageController.BRASIL_FLAG));
        expect(Get.locale?.languageCode, equals('pt'));
        expect(Get.locale?.countryCode, equals('BR'));
      });
    });

    group('Language Change Tests', () {
      setUp(() {
        languageController.onInit();
      });

      test('should change to Portuguese correctly', () {
        // Act
        languageController.changeLanguage('pt', 'BR', languageController.BRASIL_FLAG);
        
        // Assert
        expect(languageController.flagImagePath.value, equals(languageController.BRASIL_FLAG));
        expect(Get.locale?.languageCode, equals('pt'));
        expect(Get.locale?.countryCode, equals('BR'));
      });

      test('should change to English correctly', () {
        // Act
        languageController.changeLanguage('en', 'US', languageController.UK_FLAG);
        
        // Assert
        expect(languageController.flagImagePath.value, equals(languageController.UK_FLAG));
        expect(Get.locale?.languageCode, equals('en'));
        expect(Get.locale?.countryCode, equals('US'));
      });

      test('should change to Spanish correctly', () {
        // Act
        languageController.changeLanguage('es', 'ES', languageController.SPAIN_FLAG);
        
        // Assert
        expect(languageController.flagImagePath.value, equals(languageController.SPAIN_FLAG));
        expect(Get.locale?.languageCode, equals('es'));
        expect(Get.locale?.countryCode, equals('ES'));
      });

      test('should handle custom language and flag', () {
        // Arrange
        const customFlag = 'assets/images/custom-flag.png';
        
        // Act
        languageController.changeLanguage('fr', 'FR', customFlag);
        
        // Assert
        expect(languageController.flagImagePath.value, equals(customFlag));
        expect(Get.locale?.languageCode, equals('fr'));
        expect(Get.locale?.countryCode, equals('FR'));
      });

      test('should update flag image path immediately', () {
        // Arrange
        const initialFlag = languageController.BRASIL_FLAG;
        languageController.flagImagePath.value = initialFlag;
        
        // Act
        languageController.changeLanguage('en', 'US', languageController.UK_FLAG);
        
        // Assert
        expect(languageController.flagImagePath.value, equals(languageController.UK_FLAG));
        expect(languageController.flagImagePath.value, isNot(equals(initialFlag)));
      });

      test('should handle multiple language changes', () {
        // Act & Assert - Change to English
        languageController.changeLanguage('en', 'US', languageController.UK_FLAG);
        expect(languageController.flagImagePath.value, equals(languageController.UK_FLAG));
        expect(Get.locale?.languageCode, equals('en'));
        
        // Act & Assert - Change to Spanish
        languageController.changeLanguage('es', 'ES', languageController.SPAIN_FLAG);
        expect(languageController.flagImagePath.value, equals(languageController.SPAIN_FLAG));
        expect(Get.locale?.languageCode, equals('es'));
        
        // Act & Assert - Change back to Portuguese
        languageController.changeLanguage('pt', 'BR', languageController.BRASIL_FLAG);
        expect(languageController.flagImagePath.value, equals(languageController.BRASIL_FLAG));
        expect(Get.locale?.languageCode, equals('pt'));
      });
    });

    group('Flag Path Management Tests', () {
      test('should maintain correct flag paths as constants', () {
        expect(languageController.BRASIL_FLAG, contains('brasil'));
        expect(languageController.BRASIL_FLAG, contains('circle-flag'));
        expect(languageController.BRASIL_FLAG, endsWith('.png'));
        
        expect(languageController.UK_FLAG, contains('uk'));
        expect(languageController.UK_FLAG, contains('circle-flag'));
        expect(languageController.UK_FLAG, endsWith('.png'));
        
        expect(languageController.SPAIN_FLAG, contains('spain'));
        expect(languageController.SPAIN_FLAG, contains('circle-flag'));
        expect(languageController.SPAIN_FLAG, endsWith('.png'));
      });

      test('should have unique flag paths for each language', () {
        expect(languageController.BRASIL_FLAG, isNot(equals(languageController.UK_FLAG)));
        expect(languageController.BRASIL_FLAG, isNot(equals(languageController.SPAIN_FLAG)));
        expect(languageController.UK_FLAG, isNot(equals(languageController.SPAIN_FLAG)));
      });

      test('should update flag image path reactively', () {
        // Arrange
        bool flagChanged = false;
        languageController.flagImagePath.listen((_) {
          flagChanged = true;
        });
        
        // Act
        languageController.changeLanguage('en', 'US', languageController.UK_FLAG);
        
        // Assert
        expect(flagChanged, isTrue);
      });
    });

    group('Locale Handling Tests', () {
      test('should handle different country codes for same language', () {
        // Test English with different countries
        languageController.changeLanguage('en', 'GB', languageController.UK_FLAG);
        expect(Get.locale?.languageCode, equals('en'));
        expect(Get.locale?.countryCode, equals('GB'));
        
        languageController.changeLanguage('en', 'AU', languageController.UK_FLAG);
        expect(Get.locale?.languageCode, equals('en'));
        expect(Get.locale?.countryCode, equals('AU'));
      });

      test('should handle Portuguese with different countries', () {
        // Test Portuguese Brazil vs Portugal
        languageController.changeLanguage('pt', 'BR', languageController.BRASIL_FLAG);
        expect(Get.locale?.languageCode, equals('pt'));
        expect(Get.locale?.countryCode, equals('BR'));
        
        languageController.changeLanguage('pt', 'PT', languageController.BRASIL_FLAG);
        expect(Get.locale?.languageCode, equals('pt'));
        expect(Get.locale?.countryCode, equals('PT'));
      });

      test('should handle Spanish with different countries', () {
        // Test Spanish Spain vs Mexico
        languageController.changeLanguage('es', 'ES', languageController.SPAIN_FLAG);
        expect(Get.locale?.languageCode, equals('es'));
        expect(Get.locale?.countryCode, equals('ES'));
        
        languageController.changeLanguage('es', 'MX', languageController.SPAIN_FLAG);
        expect(Get.locale?.languageCode, equals('es'));
        expect(Get.locale?.countryCode, equals('MX'));
      });

      test('should handle empty or null language codes gracefully', () {
        // Test with empty strings
        languageController.changeLanguage('', '', languageController.BRASIL_FLAG);
        expect(languageController.flagImagePath.value, equals(languageController.BRASIL_FLAG));
        
        // The locale might be set to empty, but the flag should still update
        expect(Get.locale?.languageCode, equals(''));
      });
    });

    group('Edge Cases and Integration Tests', () {
      test('should handle rapid language changes', () {
        // Perform multiple rapid changes
        for (int i = 0; i < 10; i++) {
          if (i % 3 == 0) {
            languageController.changeLanguage('pt', 'BR', languageController.BRASIL_FLAG);
          } else if (i % 3 == 1) {
            languageController.changeLanguage('en', 'US', languageController.UK_FLAG);
          } else {
            languageController.changeLanguage('es', 'ES', languageController.SPAIN_FLAG);
          }
        }
        
        // Should end with Spanish
        expect(Get.locale?.languageCode, equals('es'));
        expect(languageController.flagImagePath.value, equals(languageController.SPAIN_FLAG));
      });

      test('should maintain state consistency', () {
        // Change language and verify both locale and flag are consistent
        languageController.changeLanguage('en', 'US', languageController.UK_FLAG);
        
        expect(Get.locale?.languageCode, equals('en'));
        expect(Get.locale?.countryCode, equals('US'));
        expect(languageController.flagImagePath.value, equals(languageController.UK_FLAG));
        
        // Change again
        languageController.changeLanguage('pt', 'BR', languageController.BRASIL_FLAG);
        
        expect(Get.locale?.languageCode, equals('pt'));
        expect(Get.locale?.countryCode, equals('BR'));
        expect(languageController.flagImagePath.value, equals(languageController.BRASIL_FLAG));
      });

      test('should handle special characters in language codes', () {
        // Test with language codes that might have special characters
        const customFlag = 'assets/images/custom.png';
        
        languageController.changeLanguage('zh-CN', 'CN', customFlag);
        expect(Get.locale?.languageCode, equals('zh-CN'));
        expect(languageController.flagImagePath.value, equals(customFlag));
      });

      test('should handle very long flag paths', () {
        // Test with a very long flag path
        const longFlagPath = 'assets/images/very/long/path/to/a/flag/image/that/might/be/used/in/some/cases/flag.png';
        
        languageController.changeLanguage('en', 'US', longFlagPath);
        expect(languageController.flagImagePath.value, equals(longFlagPath));
      });

      test('should handle memory management correctly', () {
        // Create and dispose controller
        final controller = LanguageController();
        controller.onInit();
        controller.onClose();
        
        // Should not throw any exceptions
        expect(controller.isClosed, isTrue);
      });

      test('should handle initialization with various locale combinations', () {
        // Test different locale combinations during initialization
        final testCases = [
          {'locale': const Locale('pt', 'BR'), 'expectedFlag': languageController.BRASIL_FLAG},
          {'locale': const Locale('en', 'US'), 'expectedFlag': languageController.UK_FLAG},
          {'locale': const Locale('es', 'ES'), 'expectedFlag': languageController.SPAIN_FLAG},
          {'locale': const Locale('de', 'DE'), 'expectedFlag': languageController.BRASIL_FLAG}, // Default
        ];
        
        for (final testCase in testCases) {
          final controller = LanguageController();
          Get.locale = testCase['locale'] as Locale;
          
          controller.onInit();
          
          expect(controller.flagImagePath.value, equals(testCase['expectedFlag']));
          
          controller.onClose();
        }
      });

      test('should preserve flag image path across controller lifecycle', () {
        // Set a specific language
        languageController.changeLanguage('es', 'ES', languageController.SPAIN_FLAG);
        final flagBeforeClose = languageController.flagImagePath.value;
        
        // Close and recreate
        languageController.onClose();
        
        final newController = LanguageController();
        Get.locale = const Locale('es', 'ES');
        newController.onInit();
        
        // Should initialize with the same flag for the same locale
        expect(newController.flagImagePath.value, equals(flagBeforeClose));
        
        newController.onClose();
      });
    });
  });
}