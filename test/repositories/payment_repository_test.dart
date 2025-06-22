import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/data/dto/product_payment_request.dart';
import 'package:park_wallet/data/models/user_profile.dart';
import 'package:park_wallet/global/custom_exception.dart';
import 'package:park_wallet/repositories/payment_repository.dart';
import 'package:park_wallet/services/auth_service.dart';

import 'payment_repository_test.mocks.dart';

@GenerateMocks([http.Client, AuthService])
void main() {
  group('PaymentRepository Tests', () {
    late PaymentRepository paymentRepository;
    late MockClient mockClient;
    late MockAuthService mockAuthService;

    setUp(() {
      Get.testMode = true;
      mockClient = MockClient();
      mockAuthService = MockAuthService();
      
      // Register mock AuthService with GetX
      Get.put<AuthService>(mockAuthService);
      
      paymentRepository = PaymentRepository();
    });

    tearDown(() {
      Get.reset();
    });

    group('processPayment Tests', () {
      test('should process payment successfully', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 2,
          totalAmount: 25.50,
        );
        
        final mockProfile = UserProfile(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          cpf: '12345678901',
          birthDate: '1990-01-01',
          balance: 100.0,
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        final mockResponse = http.Response(
          '{"success": true, "message": "Payment processed successfully"}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await paymentRepository.processPayment(paymentRequest);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], isTrue);
        expect(result['message'], equals('Payment processed successfully'));
        
        verify(mockClient.post(
          Uri.parse(Endpoints.paymentEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer valid_token',
          },
          body: anyNamed('body'),
        )).called(1);
      });

      test('should throw CustomException when payment fails with 400', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        final mockResponse = http.Response(
          '{"error": "Insufficient balance"}',
          400,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await paymentRepository.processPayment(paymentRequest),
          throwsA(isA<CustomException>().having(
            (e) => e.message,
            'message',
            contains('Insufficient balance'),
          )),
        );
      });

      test('should throw CustomException when unauthorized (401)', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );

        when(mockAuthService.token).thenReturn('invalid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        final mockResponse = http.Response(
          '{"error": "Unauthorized"}',
          401,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await paymentRepository.processPayment(paymentRequest),
          throwsA(isA<CustomException>().having(
            (e) => e.message,
            'message',
            contains('Unauthorized'),
          )),
        );
      });

      test('should throw CustomException when server error (500)', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        final mockResponse = http.Response(
          '{"error": "Internal server error"}',
          500,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await paymentRepository.processPayment(paymentRequest),
          throwsA(isA<CustomException>().having(
            (e) => e.message,
            'message',
            contains('Internal server error'),
          )),
        );
      });

      test('should handle network timeout', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(Exception('Network timeout'));

        // Act & Assert
        expect(
          () async => await paymentRepository.processPayment(paymentRequest),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle malformed JSON response', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        final mockResponse = http.Response(
          'Invalid JSON response',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await paymentRepository.processPayment(paymentRequest),
          throwsA(isA<FormatException>()),
        );
      });

      test('should include correct headers in request', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );

        when(mockAuthService.token).thenReturn('test_token_123');
        when(mockAuthService.userId).thenReturn('user_456');
        
        final mockResponse = http.Response(
          '{"success": true}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        await paymentRepository.processPayment(paymentRequest);

        // Assert
        verify(mockClient.post(
          Uri.parse(Endpoints.paymentEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer test_token_123',
          },
          body: anyNamed('body'),
        )).called(1);
      });

      test('should handle empty response body', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        final mockResponse = http.Response(
          '',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await paymentRepository.processPayment(paymentRequest),
          throwsA(isA<FormatException>()),
        );
      });

      test('should validate payment request data', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 0, // Invalid product ID
          quantity: -1, // Invalid quantity
          totalAmount: -10.0, // Invalid amount
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        final mockResponse = http.Response(
          '{"error": "Invalid payment data"}',
          400,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await paymentRepository.processPayment(paymentRequest),
          throwsA(isA<CustomException>()),
        );
      });

      test('should handle large payment amounts', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1000,
          totalAmount: 999999.99,
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        final mockResponse = http.Response(
          '{"success": true, "message": "Large payment processed"}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await paymentRepository.processPayment(paymentRequest);

        // Assert
        expect(result['success'], isTrue);
        expect(result['message'], contains('Large payment processed'));
      });

      test('should handle decimal precision in amounts', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 3,
          totalAmount: 33.333333, // High precision decimal
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        final mockResponse = http.Response(
          '{"success": true, "processedAmount": 33.33}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await paymentRepository.processPayment(paymentRequest);

        // Assert
        expect(result['success'], isTrue);
        expect(result['processedAmount'], equals(33.33));
      });
    });

    group('Error Handling Tests', () {
      test('should handle connection refused error', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(Exception('Connection refused'));

        // Act & Assert
        expect(
          () async => await paymentRepository.processPayment(paymentRequest),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Connection refused'),
          )),
        );
      });

      test('should handle DNS resolution error', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(Exception('Failed host lookup'));

        // Act & Assert
        expect(
          () async => await paymentRepository.processPayment(paymentRequest),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Authentication Tests', () {
      test('should handle missing token', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );

        when(mockAuthService.token).thenReturn(null);
        when(mockAuthService.userId).thenReturn('123');

        // Act & Assert
        expect(
          () async => await paymentRepository.processPayment(paymentRequest),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle empty token', () async {
        // Arrange
        final paymentRequest = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );

        when(mockAuthService.token).thenReturn('');
        when(mockAuthService.userId).thenReturn('123');

        // Act & Assert
        expect(
          () async => await paymentRepository.processPayment(paymentRequest),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Integration Tests', () {
      test('should handle concurrent payment requests', () async {
        // Arrange
        final paymentRequest1 = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
          totalAmount: 10.0,
        );
        
        final paymentRequest2 = ProductPaymentRequest(
          productId: 2,
          quantity: 2,
          totalAmount: 20.0,
        );

        when(mockAuthService.token).thenReturn('valid_token');
        when(mockAuthService.userId).thenReturn('123');
        
        final mockResponse = http.Response(
          '{"success": true}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final futures = [
          paymentRepository.processPayment(paymentRequest1),
          paymentRepository.processPayment(paymentRequest2),
        ];
        
        final results = await Future.wait(futures);

        // Assert
        expect(results.length, equals(2));
        expect(results[0]['success'], isTrue);
        expect(results[1]['success'], isTrue);
      });
    });
  });
}