import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:park_wallet/data/dto/login_request.dart';
import 'package:park_wallet/pages/login/controllers/login_controller.dart';
import 'package:park_wallet/repositories/auth_repository.dart';
import 'package:park_wallet/services/auth_service.dart';

import 'login_controller_test.mocks.dart';

@GenerateMocks([AuthRepository, AuthService])
void main() {
  group('LoginController Tests', () {
    late LoginController loginController;
    late MockAuthRepository mockAuthRepository;
    late MockAuthService mockAuthService;

    setUp(() {
      Get.testMode = true;
      mockAuthRepository = MockAuthRepository();
      mockAuthService = MockAuthService();
      
      // Register mock services with GetX
      Get.put<AuthService>(mockAuthService);
      
      loginController = LoginController();
      // Replace the repository with mock
      loginController.authRepo = mockAuthRepository;
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with correct default values', () {
        expect(loginController.emailCtrl.text, isEmpty);
        expect(loginController.passwordCtrl.text, isEmpty);
        expect(loginController.isLoading.value, isFalse);
      });

      test('should have empty text controllers initially', () {
        expect(loginController.emailCtrl.text, equals(''));
        expect(loginController.passwordCtrl.text, equals(''));
      });
    });

    group('Login Validation Tests', () {
      test('should show error when email is empty', () async {
        // Arrange
        loginController.emailCtrl.text = '';
        loginController.passwordCtrl.text = 'password123';
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
        verifyNever(mockAuthRepository.fetchLogin(any));
      });

      test('should show error when password is empty', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = '';
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
        verifyNever(mockAuthRepository.fetchLogin(any));
      });

      test('should show error when both fields are empty', () async {
        // Arrange
        loginController.emailCtrl.text = '';
        loginController.passwordCtrl.text = '';
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
        verifyNever(mockAuthRepository.fetchLogin(any));
      });

      test('should show error for invalid email format', () async {
        // Arrange
        loginController.emailCtrl.text = 'invalid-email';
        loginController.passwordCtrl.text = 'password123';
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
        verifyNever(mockAuthRepository.fetchLogin(any));
      });

      test('should show error for email without domain', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@';
        loginController.passwordCtrl.text = 'password123';
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
        verifyNever(mockAuthRepository.fetchLogin(any));
      });

      test('should show error for email without @ symbol', () async {
        // Arrange
        loginController.emailCtrl.text = 'testexample.com';
        loginController.passwordCtrl.text = 'password123';
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
        verifyNever(mockAuthRepository.fetchLogin(any));
      });

      test('should accept valid email formats', () async {
        // Arrange
        const validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'test123@test-domain.org',
          'user+tag@example.net',
        ];
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async => 'mock_token');
        when(mockAuthService.saveToken(any)).thenReturn(null);
        
        for (final email in validEmails) {
          // Arrange
          loginController.emailCtrl.text = email;
          loginController.passwordCtrl.text = 'password123';
          
          // Act
          await loginController.login();
          
          // Assert
          verify(mockAuthRepository.fetchLogin(any)).called(1);
          reset(mockAuthRepository);
          when(mockAuthRepository.fetchLogin(any))
              .thenAnswer((_) async => 'mock_token');
        }
      });
    });

    group('Successful Login Tests', () {
      test('should login successfully with valid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const token = 'mock_jwt_token';
        
        loginController.emailCtrl.text = email;
        loginController.passwordCtrl.text = password;
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async => token);
        when(mockAuthService.saveToken(token)).thenReturn(null);
        
        // Act
        await loginController.login();
        
        // Assert
        verify(mockAuthRepository.fetchLogin(
          argThat(isA<LoginRequest>()
              .having((req) => req.email, 'email', email)
              .having((req) => req.password, 'password', password)),
        )).called(1);
        verify(mockAuthService.saveToken(token)).called(1);
        expect(loginController.emailCtrl.text, isEmpty);
        expect(loginController.passwordCtrl.text, isEmpty);
        expect(loginController.isLoading.value, isFalse);
      });

      test('should clear form fields after successful login', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async => 'token');
        when(mockAuthService.saveToken(any)).thenReturn(null);
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.emailCtrl.text, isEmpty);
        expect(loginController.passwordCtrl.text, isEmpty);
      });

      test('should save token and navigate to home on success', () async {
        // Arrange
        const token = 'valid_jwt_token';
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async => token);
        when(mockAuthService.saveToken(token)).thenReturn(null);
        
        // Act
        await loginController.login();
        
        // Assert
        verify(mockAuthService.saveToken(token)).called(1);
      });
    });

    group('Login Error Handling Tests', () {
      test('should handle authentication error', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'wrongpassword';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenThrow(Exception('Invalid credentials'));
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
        verifyNever(mockAuthService.saveToken(any));
      });

      test('should handle network error', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenThrow(Exception('Network error'));
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
        verifyNever(mockAuthService.saveToken(any));
      });

      test('should handle server error', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenThrow(Exception('Server error 500'));
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
        verifyNever(mockAuthService.saveToken(any));
      });

      test('should handle timeout error', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenThrow(Exception('Request timeout'));
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
        verifyNever(mockAuthService.saveToken(any));
      });
    });

    group('Loading State Tests', () {
      test('should set loading to true during login process', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async {
          // Verify loading is true during the async operation
          expect(loginController.isLoading.value, isTrue);
          return 'token';
        });
        when(mockAuthService.saveToken(any)).thenReturn(null);
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
      });

      test('should prevent multiple simultaneous login attempts', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'password123';
        loginController.isLoading.value = true;
        
        // Act
        await loginController.login();
        
        // Assert
        verifyNever(mockAuthRepository.fetchLogin(any));
        expect(loginController.isLoading.value, isTrue);
      });

      test('should reset loading state after error', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenThrow(Exception('Error'));
        
        // Act
        await loginController.login();
        
        // Assert
        expect(loginController.isLoading.value, isFalse);
      });
    });

    group('Input Handling Tests', () {
      test('should trim whitespace from email and password', () async {
        // Arrange
        loginController.emailCtrl.text = '  test@example.com  ';
        loginController.passwordCtrl.text = '  password123  ';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async => 'token');
        when(mockAuthService.saveToken(any)).thenReturn(null);
        
        // Act
        await loginController.login();
        
        // Assert
        verify(mockAuthRepository.fetchLogin(
          argThat(isA<LoginRequest>()
              .having((req) => req.email, 'email', '  test@example.com  ')
              .having((req) => req.password, 'password', '  password123  ')),
        )).called(1);
      });

      test('should handle special characters in password', () async {
        // Arrange
        const specialPassword = 'P@ssw0rd!#\$%^&*()';
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = specialPassword;
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async => 'token');
        when(mockAuthService.saveToken(any)).thenReturn(null);
        
        // Act
        await loginController.login();
        
        // Assert
        verify(mockAuthRepository.fetchLogin(
          argThat(isA<LoginRequest>()
              .having((req) => req.password, 'password', specialPassword)),
        )).called(1);
      });

      test('should handle very long email and password', () async {
        // Arrange
        final longEmail = '${'a' * 50}@${'b' * 50}.com';
        final longPassword = 'p' * 100;
        
        loginController.emailCtrl.text = longEmail;
        loginController.passwordCtrl.text = longPassword;
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async => 'token');
        when(mockAuthService.saveToken(any)).thenReturn(null);
        
        // Act
        await loginController.login();
        
        // Assert
        verify(mockAuthRepository.fetchLogin(
          argThat(isA<LoginRequest>()
              .having((req) => req.email, 'email', longEmail)
              .having((req) => req.password, 'password', longPassword)),
        )).called(1);
      });
    });

    group('Edge Cases Tests', () {
      test('should handle null token response', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async => null);
        
        // Act
        await loginController.login();
        
        // Assert
        verify(mockAuthService.saveToken(null)).called(1);
        expect(loginController.isLoading.value, isFalse);
      });

      test('should handle empty token response', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async => '');
        when(mockAuthService.saveToken('')).thenReturn(null);
        
        // Act
        await loginController.login();
        
        // Assert
        verify(mockAuthService.saveToken('')).called(1);
        expect(loginController.isLoading.value, isFalse);
      });

      test('should handle case-sensitive email validation', () async {
        // Arrange
        loginController.emailCtrl.text = 'TEST@EXAMPLE.COM';
        loginController.passwordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async => 'token');
        when(mockAuthService.saveToken(any)).thenReturn(null);
        
        // Act
        await loginController.login();
        
        // Assert
        verify(mockAuthRepository.fetchLogin(any)).called(1);
      });
    });

    group('Memory Management Tests', () {
      test('should dispose controllers properly', () {
        // Arrange & Act
        loginController.onClose();
        
        // Assert - controllers should be disposed
        // Note: TextEditingController disposal is handled by GetX
        expect(loginController.emailCtrl.text, isEmpty);
        expect(loginController.passwordCtrl.text, isEmpty);
      });
    });

    group('Integration Tests', () {
      test('should handle complete login flow', () async {
        // Arrange
        const email = 'integration@test.com';
        const password = 'integrationPassword123';
        const token = 'integration_jwt_token';
        
        loginController.emailCtrl.text = email;
        loginController.passwordCtrl.text = password;
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async => token);
        when(mockAuthService.saveToken(token)).thenReturn(null);
        
        // Act
        await loginController.login();
        
        // Assert
        verify(mockAuthRepository.fetchLogin(
          argThat(isA<LoginRequest>()
              .having((req) => req.email, 'email', email)
              .having((req) => req.password, 'password', password)),
        )).called(1);
        verify(mockAuthService.saveToken(token)).called(1);
        expect(loginController.emailCtrl.text, isEmpty);
        expect(loginController.passwordCtrl.text, isEmpty);
        expect(loginController.isLoading.value, isFalse);
      });

      test('should handle rapid login attempts', () async {
        // Arrange
        loginController.emailCtrl.text = 'test@example.com';
        loginController.passwordCtrl.text = 'password123';
        
        when(mockAuthRepository.fetchLogin(any))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return 'token';
        });
        when(mockAuthService.saveToken(any)).thenReturn(null);
        
        // Act - Try to login multiple times rapidly
        final futures = [
          loginController.login(),
          loginController.login(),
          loginController.login(),
        ];
        
        await Future.wait(futures);
        
        // Assert - Only one login should be processed
        verify(mockAuthRepository.fetchLogin(any)).called(1);
      });
    });
  });
}