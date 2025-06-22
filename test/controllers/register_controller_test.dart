import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:park_wallet/data/dto/user_register_request.dart';
import 'package:park_wallet/pages/register/controllers/register_controller.dart';
import 'package:park_wallet/repositories/auth_repository.dart';

import 'register_controller_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('RegisterController Tests', () {
    late RegisterController registerController;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      Get.testMode = true;
      mockAuthRepository = MockAuthRepository();
      
      registerController = RegisterController();
      registerController.authRepository = mockAuthRepository;
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with correct default values', () {
        expect(registerController.currentPage.value, equals(0));
        expect(registerController.nameCtrl.text, isEmpty);
        expect(registerController.cpfCtrl.text, isEmpty);
        expect(registerController.emailCtrl.text, isEmpty);
        expect(registerController.passwordCtrl.text, isEmpty);
        expect(registerController.repeatPasswordCtrl.text, isEmpty);
        expect(registerController.dateCtrl.text, isEmpty);
        expect(registerController.selectedDate.value, isA<DateTime>());
      });

      test('should have PageController initialized', () {
        expect(registerController.pageController, isA<PageController>());
      });
    });

    group('Page Navigation Tests', () {
      test('should navigate to next page when first page is valid', () {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        
        // Act
        registerController.nextPage();
        
        // Assert
        expect(registerController.currentPage.value, equals(1));
      });

      test('should not navigate to next page when first page is invalid', () {
        // Arrange
        registerController.nameCtrl.text = '';
        registerController.cpfCtrl.text = '';
        registerController.dateCtrl.text = '';
        
        // Act
        registerController.nextPage();
        
        // Assert
        expect(registerController.currentPage.value, equals(0));
      });

      test('should navigate to previous page', () {
        // Arrange
        registerController.currentPage.value = 1;
        
        // Act
        registerController.prevPage();
        
        // Assert
        expect(registerController.currentPage.value, equals(0));
      });
    });

    group('First Page Validation Tests', () {
      test('should validate first page with all required fields', () {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isTrue);
      });

      test('should fail validation when name is empty', () {
        // Arrange
        registerController.nameCtrl.text = '';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should fail validation when CPF is empty', () {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '';
        registerController.dateCtrl.text = '01/01/1990';
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should fail validation when date is empty', () {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '';
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should fail validation with invalid CPF format', () {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123';
        registerController.dateCtrl.text = '01/01/1990';
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should fail validation with invalid date format', () {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = 'invalid-date';
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should validate name with minimum length', () {
        // Arrange
        registerController.nameCtrl.text = 'Jo';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should accept valid name with special characters', () {
        // Arrange
        registerController.nameCtrl.text = 'José da Silva-Santos';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isTrue);
      });
    });

    group('Second Page Validation Tests', () {
      test('should validate second page with all required fields', () {
        // Arrange
        registerController.emailCtrl.text = 'test@example.com';
        registerController.passwordCtrl.text = 'password123';
        registerController.repeatPasswordCtrl.text = 'password123';
        
        // Act
        final isValid = registerController.validateSecondPage();
        
        // Assert
        expect(isValid, isTrue);
      });

      test('should fail validation when email is empty', () {
        // Arrange
        registerController.emailCtrl.text = '';
        registerController.passwordCtrl.text = 'password123';
        registerController.repeatPasswordCtrl.text = 'password123';
        
        // Act
        final isValid = registerController.validateSecondPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should fail validation when password is empty', () {
        // Arrange
        registerController.emailCtrl.text = 'test@example.com';
        registerController.passwordCtrl.text = '';
        registerController.repeatPasswordCtrl.text = 'password123';
        
        // Act
        final isValid = registerController.validateSecondPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should fail validation when passwords do not match', () {
        // Arrange
        registerController.emailCtrl.text = 'test@example.com';
        registerController.passwordCtrl.text = 'password123';
        registerController.repeatPasswordCtrl.text = 'different123';
        
        // Act
        final isValid = registerController.validateSecondPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should fail validation with invalid email format', () {
        // Arrange
        registerController.emailCtrl.text = 'invalid-email';
        registerController.passwordCtrl.text = 'password123';
        registerController.repeatPasswordCtrl.text = 'password123';
        
        // Act
        final isValid = registerController.validateSecondPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should fail validation with weak password', () {
        // Arrange
        registerController.emailCtrl.text = 'test@example.com';
        registerController.passwordCtrl.text = '123';
        registerController.repeatPasswordCtrl.text = '123';
        
        // Act
        final isValid = registerController.validateSecondPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should accept strong password', () {
        // Arrange
        registerController.emailCtrl.text = 'test@example.com';
        registerController.passwordCtrl.text = 'StrongP@ssw0rd123';
        registerController.repeatPasswordCtrl.text = 'StrongP@ssw0rd123';
        
        // Act
        final isValid = registerController.validateSecondPage();
        
        // Assert
        expect(isValid, isTrue);
      });
    });

    group('Registration Tests', () {
      test('should register successfully with valid data', () async {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        registerController.emailCtrl.text = 'test@example.com';
        registerController.passwordCtrl.text = 'password123';
        registerController.repeatPasswordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchRegister(any))
            .thenAnswer((_) async => {});
        
        // Act
        await registerController.register();
        
        // Assert
        verify(mockAuthRepository.fetchRegister(
          argThat(isA<UserRegisterRequest>()
              .having((req) => req.name, 'name', 'João Silva')
              .having((req) => req.cpf, 'cpf', '12345678900')
              .having((req) => req.email, 'email', 'test@example.com')
              .having((req) => req.password, 'password', 'password123')),
        )).called(1);
      });

      test('should not register when second page validation fails', () async {
        // Arrange
        registerController.emailCtrl.text = '';
        registerController.passwordCtrl.text = 'password123';
        registerController.repeatPasswordCtrl.text = 'different123';
        
        // Act
        await registerController.register();
        
        // Assert
        verifyNever(mockAuthRepository.fetchRegister(any));
      });

      test('should handle registration error', () async {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        registerController.emailCtrl.text = 'test@example.com';
        registerController.passwordCtrl.text = 'password123';
        registerController.repeatPasswordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchRegister(any))
            .thenThrow(Exception('Registration failed'));
        
        // Act
        await registerController.register();
        
        // Assert
        verify(mockAuthRepository.fetchRegister(any)).called(1);
      });

      test('should format CPF correctly by removing non-digits', () async {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        registerController.emailCtrl.text = 'test@example.com';
        registerController.passwordCtrl.text = 'password123';
        registerController.repeatPasswordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchRegister(any))
            .thenAnswer((_) async => {});
        
        // Act
        await registerController.register();
        
        // Assert
        verify(mockAuthRepository.fetchRegister(
          argThat(isA<UserRegisterRequest>()
              .having((req) => req.cpf, 'cpf', '12345678900')),
        )).called(1);
      });

      test('should trim whitespace from name and email', () async {
        // Arrange
        registerController.nameCtrl.text = '  João Silva  ';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        registerController.emailCtrl.text = '  test@example.com  ';
        registerController.passwordCtrl.text = 'password123';
        registerController.repeatPasswordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchRegister(any))
            .thenAnswer((_) async => {});
        
        // Act
        await registerController.register();
        
        // Assert
        verify(mockAuthRepository.fetchRegister(
          argThat(isA<UserRegisterRequest>()
              .having((req) => req.name, 'name', 'João Silva')
              .having((req) => req.email, 'email', 'test@example.com')),
        )).called(1);
      });
    });

    group('Date Formatting Tests', () {
      test('should format birthdate correctly from DD/MM/YYYY to YYYY-MM-DD', () async {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '15/06/1990';
        registerController.emailCtrl.text = 'test@example.com';
        registerController.passwordCtrl.text = 'password123';
        registerController.repeatPasswordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchRegister(any))
            .thenAnswer((_) async => {});
        
        // Act
        await registerController.register();
        
        // Assert
        verify(mockAuthRepository.fetchRegister(
          argThat(isA<UserRegisterRequest>()
              .having((req) => req.birthDate, 'birthDate', '1990-06-15')),
        )).called(1);
      });

      test('should handle single digit day and month in date', () async {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '5/3/1990';
        registerController.emailCtrl.text = 'test@example.com';
        registerController.passwordCtrl.text = 'password123';
        registerController.repeatPasswordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchRegister(any))
            .thenAnswer((_) async => {});
        
        // Act
        await registerController.register();
        
        // Assert
        verify(mockAuthRepository.fetchRegister(
          argThat(isA<UserRegisterRequest>()
              .having((req) => req.birthDate, 'birthDate', '1990-03-05')),
        )).called(1);
      });
    });

    group('Input Validation Edge Cases', () {
      test('should handle very long name', () {
        // Arrange
        final longName = 'A' * 100;
        registerController.nameCtrl.text = longName;
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should handle name with numbers', () {
        // Arrange
        registerController.nameCtrl.text = 'João123';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should handle future birth date', () {
        // Arrange
        final futureDate = DateTime.now().add(const Duration(days: 365));
        final futureDateStr = '${futureDate.day.toString().padLeft(2, '0')}/${futureDate.month.toString().padLeft(2, '0')}/${futureDate.year}';
        
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = futureDateStr;
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should handle very old birth date', () {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1900';
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isFalse);
      });

      test('should handle underage birth date', () {
        // Arrange
        final underageDate = DateTime.now().subtract(const Duration(days: 365 * 10)); // 10 years old
        final underageDateStr = '${underageDate.day.toString().padLeft(2, '0')}/${underageDate.month.toString().padLeft(2, '0')}/${underageDate.year}';
        
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = underageDateStr;
        
        // Act
        final isValid = registerController.validateFirstPage();
        
        // Assert
        expect(isValid, isFalse);
      });
    });

    group('Memory Management Tests', () {
      test('should dispose controllers properly', () {
        // Act
        registerController.onClose();
        
        // Assert - controllers should be disposed
        expect(registerController.nameCtrl.text, isEmpty);
        expect(registerController.cpfCtrl.text, isEmpty);
        expect(registerController.emailCtrl.text, isEmpty);
        expect(registerController.passwordCtrl.text, isEmpty);
        expect(registerController.repeatPasswordCtrl.text, isEmpty);
        expect(registerController.dateCtrl.text, isEmpty);
      });
    });

    group('Integration Tests', () {
      test('should handle complete registration flow', () async {
        // Arrange
        registerController.nameCtrl.text = 'Maria Santos';
        registerController.cpfCtrl.text = '987.654.321-00';
        registerController.dateCtrl.text = '25/12/1985';
        registerController.emailCtrl.text = 'maria@example.com';
        registerController.passwordCtrl.text = 'SecurePass123';
        registerController.repeatPasswordCtrl.text = 'SecurePass123';
        
        when(mockAuthRepository.fetchRegister(any))
            .thenAnswer((_) async => {});
        
        // Act - Navigate through pages and register
        registerController.nextPage();
        expect(registerController.currentPage.value, equals(1));
        
        await registerController.register();
        
        // Assert
        verify(mockAuthRepository.fetchRegister(
          argThat(isA<UserRegisterRequest>()
              .having((req) => req.name, 'name', 'Maria Santos')
              .having((req) => req.cpf, 'cpf', '98765432100')
              .having((req) => req.birthDate, 'birthDate', '1985-12-25')
              .having((req) => req.email, 'email', 'maria@example.com')
              .having((req) => req.password, 'password', 'SecurePass123')),
        )).called(1);
      });

      test('should handle navigation back and forth', () {
        // Arrange
        registerController.nameCtrl.text = 'João Silva';
        registerController.cpfCtrl.text = '123.456.789-00';
        registerController.dateCtrl.text = '01/01/1990';
        
        // Act & Assert
        expect(registerController.currentPage.value, equals(0));
        
        registerController.nextPage();
        expect(registerController.currentPage.value, equals(1));
        
        registerController.prevPage();
        expect(registerController.currentPage.value, equals(0));
        
        registerController.nextPage();
        expect(registerController.currentPage.value, equals(1));
      });
    });
  });
}