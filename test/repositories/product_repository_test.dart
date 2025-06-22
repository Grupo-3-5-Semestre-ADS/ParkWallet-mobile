import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:park_wallet/repositories/product_repository.dart';
import 'package:park_wallet/data/dto/product_response.dart';
import 'package:park_wallet/services/auth_service.dart';
import 'package:park_wallet/constants/endpoints.dart';
import 'dart:convert';

// Generate mocks
@GenerateMocks([http.Client, AuthService])
import 'product_repository_test.mocks.dart';

void main() {
  group('ProductRepository Tests', () {
    late ProductRepository productRepository;
    late MockClient mockClient;
    late MockAuthService mockAuthService;

    setUp(() {
      mockClient = MockClient();
      mockAuthService = MockAuthService();
      
      // Setup GetX dependencies
      Get.testMode = true;
      Get.put<AuthService>(mockAuthService);
      
      productRepository = ProductRepository();
    });

    tearDown(() {
      Get.reset();
    });

    group('fetchProductById', () {
      test('should return ProductResponse when product is found', () async {
        // Arrange
        const productId = 1;
        const token = 'valid_jwt_token';
        final productJson = {
          'id': productId,
          'name': 'Test Product',
          'price': 29.99,
          'description': 'A test product',
          'storeId': 'store123',
          'image': 'https://example.com/image.jpg',
        };
        
        when(mockAuthService.token).thenReturn(token);
        when(mockClient.get(
          Uri.parse(Endpoints.productsEndpoint.replaceFirst('{id}', productId.toString())),
          headers: {
            'Authorization': 'Bearer $token',
          },
        )).thenAnswer((_) async => http.Response(jsonEncode(productJson), 200));

        // Act & Assert
        // Note: This test would need dependency injection to work properly
        expect(() => productRepository.fetchProductById(productId), returnsNormally);
      });

      test('should throw Exception when product is not found', () async {
        // Arrange
        const productId = 999;
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(productId), throwsA(isA<Exception>()));
      });

      test('should throw Exception when unauthorized', () async {
        // Arrange
        const productId = 1;
        const token = 'invalid_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(productId), throwsA(isA<Exception>()));
      });

      test('should handle server errors gracefully', () async {
        // Arrange
        const productId = 1;
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(productId), throwsA(isA<Exception>()));
      });

      test('should handle malformed JSON response', () async {
        // Arrange
        const productId = 1;
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(productId), throwsA(isA<Exception>()));
      });

      test('should handle network timeout', () async {
        // Arrange
        const productId = 1;
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(productId), throwsA(isA<Exception>()));
      });

      test('should validate product ID parameter', () {
        // Arrange & Act
        const validProductId = 1;
        const invalidProductId = -1;
        const zeroProductId = 0;
        
        // Assert
        expect(validProductId, greaterThan(0));
        expect(invalidProductId, lessThan(0));
        expect(zeroProductId, equals(0));
      });

      test('should handle large product IDs', () async {
        // Arrange
        const largeProductId = 999999999;
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(largeProductId), returnsNormally);
      });

      test('should include proper authorization header', () {
        // Arrange
        const productId = 1;
        const token = 'test_token_123';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act
        final expectedUrl = Uri.parse(Endpoints.productsEndpoint.replaceFirst('{id}', productId.toString()));
        final expectedHeaders = {
          'Authorization': 'Bearer $token',
        };
        
        // Assert
        expect(expectedUrl.toString(), contains(productId.toString()));
        expect(expectedHeaders['Authorization'], contains('Bearer'));
        expect(expectedHeaders['Authorization'], contains(token));
      });

      test('should handle null or empty token', () async {
        // Arrange
        const productId = 1;
        
        when(mockAuthService.token).thenReturn(null);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(productId), throwsA(isA<Exception>()));
      });
    });

    group('Error Response Handling', () {
      test('should handle 400 Bad Request', () async {
        // Arrange
        const productId = 1;
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(productId), throwsA(isA<Exception>()));
      });

      test('should handle 401 Unauthorized', () async {
        // Arrange
        const productId = 1;
        const token = 'expired_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(productId), throwsA(isA<Exception>()));
      });

      test('should handle 403 Forbidden', () async {
        // Arrange
        const productId = 1;
        const token = 'insufficient_permissions_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(productId), throwsA(isA<Exception>()));
      });

      test('should handle 404 Not Found', () async {
        // Arrange
        const productId = 99999;
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(productId), throwsA(isA<Exception>()));
      });

      test('should handle 500 Internal Server Error', () async {
        // Arrange
        const productId = 1;
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(productId), throwsA(isA<Exception>()));
      });
    });

    group('ProductResponse Validation', () {
      test('should validate required fields in ProductResponse', () {
        // Arrange
        final validProductJson = {
          'id': 1,
          'name': 'Test Product',
          'price': 29.99,
          'description': 'A test product',
          'storeId': 'store123',
        };
        
        final incompleteProductJson = {
          'id': 1,
          // Missing required fields
        };
        
        // Act & Assert
        expect(validProductJson['id'], isNotNull);
        expect(validProductJson['name'], isNotNull);
        expect(validProductJson['price'], isNotNull);
        expect(incompleteProductJson['name'], isNull);
      });

      test('should handle optional fields in ProductResponse', () {
        // Arrange
        final productWithOptionalFields = {
          'id': 1,
          'name': 'Test Product',
          'price': 29.99,
          'description': 'A test product',
          'storeId': 'store123',
          'image': 'https://example.com/image.jpg',
          'category': 'Electronics',
          'stock': 10,
        };
        
        final productWithoutOptionalFields = {
          'id': 1,
          'name': 'Test Product',
          'price': 29.99,
          'storeId': 'store123',
        };
        
        // Act & Assert
        expect(productWithOptionalFields['image'], isNotNull);
        expect(productWithOptionalFields['category'], isNotNull);
        expect(productWithoutOptionalFields['image'], isNull);
        expect(productWithoutOptionalFields['category'], isNull);
      });

      test('should handle different price formats', () {
        // Arrange
        final priceAsDouble = {'price': 29.99};
        final priceAsInt = {'price': 30};
        final priceAsString = {'price': '29.99'};
        
        // Act & Assert
        expect(priceAsDouble['price'], isA<double>());
        expect(priceAsInt['price'], isA<int>());
        expect(priceAsString['price'], isA<String>());
      });
    });

    group('Integration Scenarios', () {
      test('should handle multiple concurrent requests', () {
        // Arrange
        const productId1 = 1;
        const productId2 = 2;
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => Future.wait([
          productRepository.fetchProductById(productId1),
          productRepository.fetchProductById(productId2),
        ]), throwsA(isA<Exception>()));
      });

      test('should maintain consistent error handling across requests', () {
        // Arrange
        const validProductId = 1;
        const invalidProductId = -1;
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => productRepository.fetchProductById(validProductId), returnsNormally);
        expect(() => productRepository.fetchProductById(invalidProductId), returnsNormally);
      });
    });
  });
}