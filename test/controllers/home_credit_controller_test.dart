import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:park_wallet/data/dto/product_payment_request.dart';
import 'package:park_wallet/pages/home/controllers/home_credit_controller.dart';
import 'package:park_wallet/repositories/user_repository.dart';
import 'package:park_wallet/services/auth_service.dart';

import 'home_credit_controller_test.mocks.dart';

@GenerateMocks([UserRepository, AuthService])
void main() {
  group('HomeCreditController Tests', () {
    late HomeCreditController homeCreditController;
    late MockUserRepository mockUserRepository;
    late MockAuthService mockAuthService;

    setUp(() {
      Get.testMode = true;
      mockUserRepository = MockUserRepository();
      mockAuthService = MockAuthService();
      
      homeCreditController = HomeCreditController();
      homeCreditController.userRepository = mockUserRepository;
      homeCreditController.authService = mockAuthService;
    });

    tearDown(() {
      Get.reset();
    });

    group('Initialization Tests', () {
      test('should initialize with default values', () {
        expect(homeCreditController.userCredit.value, equals(0.0));
        expect(homeCreditController.isLoading.value, isFalse);
        expect(homeCreditController.isRecharging.value, isFalse);
        expect(homeCreditController.isPaymentProcessing.value, isFalse);
      });

      test('should load user credit on init', () async {
        // Arrange
        when(mockUserRepository.getUserCredit())
            .thenAnswer((_) async => 150.75);
        
        // Act
        homeCreditController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockUserRepository.getUserCredit()).called(1);
        expect(homeCreditController.userCredit.value, equals(150.75));
        expect(homeCreditController.isLoading.value, isFalse);
      });

      test('should handle zero credit on init', () async {
        // Arrange
        when(mockUserRepository.getUserCredit())
            .thenAnswer((_) async => 0.0);
        
        // Act
        homeCreditController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockUserRepository.getUserCredit()).called(1);
        expect(homeCreditController.userCredit.value, equals(0.0));
        expect(homeCreditController.isLoading.value, isFalse);
      });

      test('should handle large credit amounts on init', () async {
        // Arrange
        when(mockUserRepository.getUserCredit())
            .thenAnswer((_) async => 999999.99);
        
        // Act
        homeCreditController.onInit();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        verify(mockUserRepository.getUserCredit()).called(1);
        expect(homeCreditController.userCredit.value, equals(999999.99));
        expect(homeCreditController.isLoading.value, isFalse);
      });
    });

    group('Load User Credit Tests', () {
      test('should load user credit successfully', () async {
        // Arrange
        when(mockUserRepository.getUserCredit())
            .thenAnswer((_) async => 250.50);
        
        // Act
        await homeCreditController.loadUserCredit();
        
        // Assert
        verify(mockUserRepository.getUserCredit()).called(1);
        expect(homeCreditController.userCredit.value, equals(250.50));
        expect(homeCreditController.isLoading.value, isFalse);
      });

      test('should handle loading state correctly', () async {
        // Arrange
        when(mockUserRepository.getUserCredit())
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return 100.0;
        });
        
        // Act
        final future = homeCreditController.loadUserCredit();
        
        // Assert loading state
        expect(homeCreditController.isLoading.value, isTrue);
        
        await future;
        
        // Assert final state
        expect(homeCreditController.isLoading.value, isFalse);
        expect(homeCreditController.userCredit.value, equals(100.0));
      });

      test('should handle network error when loading credit', () async {
        // Arrange
        when(mockUserRepository.getUserCredit())
            .thenThrow(Exception('Network error'));
        
        // Act
        await homeCreditController.loadUserCredit();
        
        // Assert
        verify(mockUserRepository.getUserCredit()).called(1);
        expect(homeCreditController.isLoading.value, isFalse);
        // Credit should remain unchanged on error
        expect(homeCreditController.userCredit.value, equals(0.0));
      });

      test('should handle timeout error when loading credit', () async {
        // Arrange
        when(mockUserRepository.getUserCredit())
            .thenThrow(Exception('Request timeout'));
        
        // Act
        await homeCreditController.loadUserCredit();
        
        // Assert
        verify(mockUserRepository.getUserCredit()).called(1);
        expect(homeCreditController.isLoading.value, isFalse);
        expect(homeCreditController.userCredit.value, equals(0.0));
      });

      test('should handle server error when loading credit', () async {
        // Arrange
        when(mockUserRepository.getUserCredit())
            .thenThrow(Exception('Server error 500'));
        
        // Act
        await homeCreditController.loadUserCredit();
        
        // Assert
        verify(mockUserRepository.getUserCredit()).called(1);
        expect(homeCreditController.isLoading.value, isFalse);
        expect(homeCreditController.userCredit.value, equals(0.0));
      });
    });

    group('Recharge Credit Tests', () {
      test('should recharge credit successfully', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        when(mockUserRepository.rechargeCredit(50.0))
            .thenAnswer((_) async => 150.0);
        
        // Act
        await homeCreditController.rechargeCredit(50.0);
        
        // Assert
        verify(mockUserRepository.rechargeCredit(50.0)).called(1);
        expect(homeCreditController.userCredit.value, equals(150.0));
        expect(homeCreditController.isRecharging.value, isFalse);
      });

      test('should handle recharging state correctly', () async {
        // Arrange
        when(mockUserRepository.rechargeCredit(25.0))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return 125.0;
        });
        
        // Act
        final future = homeCreditController.rechargeCredit(25.0);
        
        // Assert recharging state
        expect(homeCreditController.isRecharging.value, isTrue);
        
        await future;
        
        // Assert final state
        expect(homeCreditController.isRecharging.value, isFalse);
        expect(homeCreditController.userCredit.value, equals(125.0));
      });

      test('should handle zero recharge amount', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        when(mockUserRepository.rechargeCredit(0.0))
            .thenAnswer((_) async => 100.0);
        
        // Act
        await homeCreditController.rechargeCredit(0.0);
        
        // Assert
        verify(mockUserRepository.rechargeCredit(0.0)).called(1);
        expect(homeCreditController.userCredit.value, equals(100.0));
        expect(homeCreditController.isRecharging.value, isFalse);
      });

      test('should handle large recharge amount', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        when(mockUserRepository.rechargeCredit(10000.0))
            .thenAnswer((_) async => 10100.0);
        
        // Act
        await homeCreditController.rechargeCredit(10000.0);
        
        // Assert
        verify(mockUserRepository.rechargeCredit(10000.0)).called(1);
        expect(homeCreditController.userCredit.value, equals(10100.0));
        expect(homeCreditController.isRecharging.value, isFalse);
      });

      test('should handle decimal recharge amounts', () async {
        // Arrange
        homeCreditController.userCredit.value = 50.25;
        when(mockUserRepository.rechargeCredit(25.75))
            .thenAnswer((_) async => 76.0);
        
        // Act
        await homeCreditController.rechargeCredit(25.75);
        
        // Assert
        verify(mockUserRepository.rechargeCredit(25.75)).called(1);
        expect(homeCreditController.userCredit.value, equals(76.0));
        expect(homeCreditController.isRecharging.value, isFalse);
      });

      test('should handle recharge error', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        when(mockUserRepository.rechargeCredit(50.0))
            .thenThrow(Exception('Recharge failed'));
        
        // Act
        await homeCreditController.rechargeCredit(50.0);
        
        // Assert
        verify(mockUserRepository.rechargeCredit(50.0)).called(1);
        expect(homeCreditController.isRecharging.value, isFalse);
        // Credit should remain unchanged on error
        expect(homeCreditController.userCredit.value, equals(100.0));
      });

      test('should handle payment processing error during recharge', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        when(mockUserRepository.rechargeCredit(50.0))
            .thenThrow(Exception('Payment processing failed'));
        
        // Act
        await homeCreditController.rechargeCredit(50.0);
        
        // Assert
        verify(mockUserRepository.rechargeCredit(50.0)).called(1);
        expect(homeCreditController.isRecharging.value, isFalse);
        expect(homeCreditController.userCredit.value, equals(100.0));
      });

      test('should handle insufficient funds error during recharge', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        when(mockUserRepository.rechargeCredit(50.0))
            .thenThrow(Exception('Insufficient funds in payment method'));
        
        // Act
        await homeCreditController.rechargeCredit(50.0);
        
        // Assert
        verify(mockUserRepository.rechargeCredit(50.0)).called(1);
        expect(homeCreditController.isRecharging.value, isFalse);
        expect(homeCreditController.userCredit.value, equals(100.0));
      });
    });

    group('Initiate Payment Tests', () {
      test('should initiate payment successfully', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        final paymentRequest = ProductPaymentRequest(productId: 1, quantity: 2);
        
        when(mockUserRepository.initiatePayment(paymentRequest))
            .thenAnswer((_) async => true);
        when(mockUserRepository.getUserCredit())
            .thenAnswer((_) async => 80.0); // After payment
        
        // Act
        final result = await homeCreditController.initiatePayment(paymentRequest);
        
        // Assert
        verify(mockUserRepository.initiatePayment(paymentRequest)).called(1);
        verify(mockUserRepository.getUserCredit()).called(1);
        expect(result, isTrue);
        expect(homeCreditController.userCredit.value, equals(80.0));
        expect(homeCreditController.isPaymentProcessing.value, isFalse);
      });

      test('should handle payment processing state correctly', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(productId: 1, quantity: 1);
        
        when(mockUserRepository.initiatePayment(paymentRequest))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return true;
        });
        when(mockUserRepository.getUserCredit())
            .thenAnswer((_) async => 90.0);
        
        // Act
        final future = homeCreditController.initiatePayment(paymentRequest);
        
        // Assert processing state
        expect(homeCreditController.isPaymentProcessing.value, isTrue);
        
        final result = await future;
        
        // Assert final state
        expect(homeCreditController.isPaymentProcessing.value, isFalse);
        expect(result, isTrue);
      });

      test('should handle payment failure', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        final paymentRequest = ProductPaymentRequest(productId: 1, quantity: 1);
        
        when(mockUserRepository.initiatePayment(paymentRequest))
            .thenAnswer((_) async => false);
        
        // Act
        final result = await homeCreditController.initiatePayment(paymentRequest);
        
        // Assert
        verify(mockUserRepository.initiatePayment(paymentRequest)).called(1);
        verifyNever(mockUserRepository.getUserCredit());
        expect(result, isFalse);
        expect(homeCreditController.isPaymentProcessing.value, isFalse);
        // Credit should remain unchanged on payment failure
        expect(homeCreditController.userCredit.value, equals(100.0));
      });

      test('should handle payment error', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        final paymentRequest = ProductPaymentRequest(productId: 1, quantity: 1);
        
        when(mockUserRepository.initiatePayment(paymentRequest))
            .thenThrow(Exception('Payment error'));
        
        // Act
        final result = await homeCreditController.initiatePayment(paymentRequest);
        
        // Assert
        verify(mockUserRepository.initiatePayment(paymentRequest)).called(1);
        verifyNever(mockUserRepository.getUserCredit());
        expect(result, isFalse);
        expect(homeCreditController.isPaymentProcessing.value, isFalse);
        expect(homeCreditController.userCredit.value, equals(100.0));
      });

      test('should handle insufficient credit error', () async {
        // Arrange
        homeCreditController.userCredit.value = 10.0;
        final paymentRequest = ProductPaymentRequest(productId: 1, quantity: 5);
        
        when(mockUserRepository.initiatePayment(paymentRequest))
            .thenThrow(Exception('Insufficient credit'));
        
        // Act
        final result = await homeCreditController.initiatePayment(paymentRequest);
        
        // Assert
        verify(mockUserRepository.initiatePayment(paymentRequest)).called(1);
        verifyNever(mockUserRepository.getUserCredit());
        expect(result, isFalse);
        expect(homeCreditController.isPaymentProcessing.value, isFalse);
        expect(homeCreditController.userCredit.value, equals(10.0));
      });

      test('should handle network error during payment', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        final paymentRequest = ProductPaymentRequest(productId: 1, quantity: 1);
        
        when(mockUserRepository.initiatePayment(paymentRequest))
            .thenThrow(Exception('Network error'));
        
        // Act
        final result = await homeCreditController.initiatePayment(paymentRequest);
        
        // Assert
        verify(mockUserRepository.initiatePayment(paymentRequest)).called(1);
        verifyNever(mockUserRepository.getUserCredit());
        expect(result, isFalse);
        expect(homeCreditController.isPaymentProcessing.value, isFalse);
        expect(homeCreditController.userCredit.value, equals(100.0));
      });

      test('should handle multiple quantity payment', () async {
        // Arrange
        homeCreditController.userCredit.value = 200.0;
        final paymentRequest = ProductPaymentRequest(productId: 2, quantity: 10);
        
        when(mockUserRepository.initiatePayment(paymentRequest))
            .thenAnswer((_) async => true);
        when(mockUserRepository.getUserCredit())
            .thenAnswer((_) async => 50.0); // After large payment
        
        // Act
        final result = await homeCreditController.initiatePayment(paymentRequest);
        
        // Assert
        verify(mockUserRepository.initiatePayment(paymentRequest)).called(1);
        verify(mockUserRepository.getUserCredit()).called(1);
        expect(result, isTrue);
        expect(homeCreditController.userCredit.value, equals(50.0));
        expect(homeCreditController.isPaymentProcessing.value, isFalse);
      });

      test('should handle zero quantity payment', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        final paymentRequest = ProductPaymentRequest(productId: 1, quantity: 0);
        
        when(mockUserRepository.initiatePayment(paymentRequest))
            .thenAnswer((_) async => true);
        when(mockUserRepository.getUserCredit())
            .thenAnswer((_) async => 100.0); // No change
        
        // Act
        final result = await homeCreditController.initiatePayment(paymentRequest);
        
        // Assert
        verify(mockUserRepository.initiatePayment(paymentRequest)).called(1);
        verify(mockUserRepository.getUserCredit()).called(1);
        expect(result, isTrue);
        expect(homeCreditController.userCredit.value, equals(100.0));
        expect(homeCreditController.isPaymentProcessing.value, isFalse);
      });
    });

    group('Edge Cases and Integration Tests', () {
      test('should handle concurrent operations', () async {
        // Arrange
        when(mockUserRepository.getUserCredit())
            .thenAnswer((_) async => 100.0);
        when(mockUserRepository.rechargeCredit(50.0))
            .thenAnswer((_) async => 150.0);
        
        // Act
        final futures = [
          homeCreditController.loadUserCredit(),
          homeCreditController.rechargeCredit(50.0),
        ];
        
        await Future.wait(futures);
        
        // Assert
        verify(mockUserRepository.getUserCredit()).called(1);
        verify(mockUserRepository.rechargeCredit(50.0)).called(1);
        expect(homeCreditController.isLoading.value, isFalse);
        expect(homeCreditController.isRecharging.value, isFalse);
      });

      test('should handle rapid successive operations', () async {
        // Arrange
        when(mockUserRepository.rechargeCredit(any))
            .thenAnswer((_) async => 200.0);
        
        // Act
        final futures = [
          homeCreditController.rechargeCredit(25.0),
          homeCreditController.rechargeCredit(25.0),
          homeCreditController.rechargeCredit(25.0),
        ];
        
        await Future.wait(futures);
        
        // Assert
        verify(mockUserRepository.rechargeCredit(25.0)).called(3);
        expect(homeCreditController.isRecharging.value, isFalse);
      });

      test('should handle memory management correctly', () {
        // Arrange
        final controller = HomeCreditController();
        controller.userRepository = mockUserRepository;
        controller.authService = mockAuthService;
        
        // Act
        controller.onInit();
        controller.onClose();
        
        // Assert - no memory leaks or exceptions
        expect(controller.isClosed, isTrue);
      });

      test('should handle state consistency after errors', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        
        when(mockUserRepository.rechargeCredit(50.0))
            .thenThrow(Exception('First error'));
        when(mockUserRepository.rechargeCredit(25.0))
            .thenAnswer((_) async => 125.0);
        
        // Act
        await homeCreditController.rechargeCredit(50.0); // Should fail
        await homeCreditController.rechargeCredit(25.0); // Should succeed
        
        // Assert
        expect(homeCreditController.userCredit.value, equals(125.0));
        expect(homeCreditController.isRecharging.value, isFalse);
      });

      test('should handle very small decimal amounts', () async {
        // Arrange
        homeCreditController.userCredit.value = 0.01;
        when(mockUserRepository.rechargeCredit(0.01))
            .thenAnswer((_) async => 0.02);
        
        // Act
        await homeCreditController.rechargeCredit(0.01);
        
        // Assert
        verify(mockUserRepository.rechargeCredit(0.01)).called(1);
        expect(homeCreditController.userCredit.value, equals(0.02));
      });

      test('should handle negative amounts gracefully', () async {
        // Arrange
        homeCreditController.userCredit.value = 100.0;
        when(mockUserRepository.rechargeCredit(-50.0))
            .thenThrow(Exception('Invalid amount'));
        
        // Act
        await homeCreditController.rechargeCredit(-50.0);
        
        // Assert
        verify(mockUserRepository.rechargeCredit(-50.0)).called(1);
        expect(homeCreditController.userCredit.value, equals(100.0));
        expect(homeCreditController.isRecharging.value, isFalse);
      });
    });
  });
}