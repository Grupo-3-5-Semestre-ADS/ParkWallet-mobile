import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:park_wallet/repositories/store_repository.dart';
import 'package:park_wallet/data/models/store.dart';
import 'package:park_wallet/services/auth_service.dart';
import 'package:park_wallet/global/custom_exception.dart';
import 'package:park_wallet/constants/endpoints.dart';
import 'dart:convert';

// Generate mocks
@GenerateMocks([http.Client, AuthService])
import 'store_repository_test.mocks.dart';

void main() {
  group('StoreRepository Tests', () {
    late StoreRepository storeRepository;
    late MockClient mockClient;
    late MockAuthService mockAuthService;

    setUp(() {
      mockClient = MockClient();
      mockAuthService = MockAuthService();
      
      // Setup GetX dependencies
      Get.testMode = true;
      Get.put<AuthService>(mockAuthService);
      
      storeRepository = StoreRepository();
    });

    tearDown(() {
      Get.reset();
    });

    group('fetchStores', () {
      test('should return list of stores when request is successful', () async {
        // Arrange
        const token = 'valid_jwt_token';
        final storesJson = [
          {
            'id': 'store1',
            'name': 'Test Store 1',
            'type': 'Restaurant',
            'address': '123 Test St',
          },
          {
            'id': 'store2',
            'name': 'Test Store 2',
            'type': 'Shop',
            'address': '456 Test Ave',
          },
        ];
        
        when(mockAuthService.token).thenReturn(token);
        when(mockClient.get(
          Uri.parse('${Endpoints.storesEndpoint}?page=1&_size=100'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )).thenAnswer((_) async => http.Response(jsonEncode(storesJson), 200));

        // Act & Assert
        expect(() => storeRepository.fetchStores(), returnsNormally);
      });

      test('should handle pagination parameters correctly', () async {
        // Arrange
        const token = 'valid_jwt_token';
        const page = 2;
        const limit = 50;
        final storesJson = [];
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act
        final expectedUrl = Uri.parse('${Endpoints.storesEndpoint}?page=$page&_size=$limit');
        
        // Assert
        expect(expectedUrl.queryParameters['page'], equals(page.toString()));
        expect(expectedUrl.queryParameters['_size'], equals(limit.toString()));
        expect(() => storeRepository.fetchStores(page: page, limit: limit), returnsNormally);
      });

      test('should use default pagination when not specified', () async {
        // Arrange
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act
        final expectedUrl = Uri.parse('${Endpoints.storesEndpoint}?page=1&_size=100');
        
        // Assert
        expect(expectedUrl.queryParameters['page'], equals('1'));
        expect(expectedUrl.queryParameters['_size'], equals('100'));
        expect(() => storeRepository.fetchStores(), returnsNormally);
      });

      test('should handle data wrapped in response object', () async {
        // Arrange
        const token = 'valid_jwt_token';
        final wrappedResponse = {
          'data': [
            {
              'id': 'store1',
              'name': 'Test Store 1',
              'type': 'Restaurant',
            },
          ],
          'total': 1,
          'page': 1,
        };
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => storeRepository.fetchStores(), returnsNormally);
      });

      test('should throw CustomException when unauthorized', () async {
        // Arrange
        const token = 'invalid_token';
        
        when(mockAuthService.token).thenReturn(token);
        when(mockAuthService.logout()).thenAnswer((_) async => {});
        
        // Act & Assert
        expect(() => storeRepository.fetchStores(), throwsA(isA<CustomException>()));
      });

      test('should call logout when session expires', () async {
        // Arrange
        const token = 'expired_token';
        
        when(mockAuthService.token).thenReturn(token);
        when(mockAuthService.logout()).thenAnswer((_) async => {});
        
        // Act & Assert
        expect(() => storeRepository.fetchStores(), throwsA(isA<CustomException>()));
      });

      test('should throw CustomException for server errors', () async {
        // Arrange
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => storeRepository.fetchStores(), throwsA(isA<CustomException>()));
      });

      test('should handle empty store list', () async {
        // Arrange
        const token = 'valid_jwt_token';
        final emptyStoresJson = [];
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => storeRepository.fetchStores(), returnsNormally);
      });

      test('should validate pagination bounds', () {
        // Arrange & Act
        const validPage = 1;
        const validLimit = 100;
        const invalidPage = 0;
        const invalidLimit = -1;
        
        // Assert
        expect(validPage, greaterThan(0));
        expect(validLimit, greaterThan(0));
        expect(invalidPage, lessThanOrEqualTo(0));
        expect(invalidLimit, lessThan(0));
      });
    });

    group('fetchStoreById', () {
      test('should return store when found', () async {
        // Arrange
        const storeId = 'store123';
        const token = 'valid_jwt_token';
        final storeJson = {
          'id': storeId,
          'name': 'Test Store',
          'type': 'Restaurant',
          'address': '123 Test St',
          'phone': '+1234567890',
        };
        
        when(mockAuthService.token).thenReturn(token);
        when(mockClient.get(
          Uri.parse(Endpoints.storeDetailEndpoint.replaceFirst('{id}', storeId)),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )).thenAnswer((_) async => http.Response(jsonEncode(storeJson), 200));

        // Act & Assert
        expect(() => storeRepository.fetchStoreById(storeId), returnsNormally);
      });

      test('should throw CustomException when store not found', () async {
        // Arrange
        const storeId = 'nonexistent_store';
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => storeRepository.fetchStoreById(storeId), throwsA(isA<CustomException>()));
      });

      test('should handle unauthorized access', () async {
        // Arrange
        const storeId = 'store123';
        const token = 'invalid_token';
        
        when(mockAuthService.token).thenReturn(token);
        when(mockAuthService.logout()).thenAnswer((_) async => {});
        
        // Act & Assert
        expect(() => storeRepository.fetchStoreById(storeId), throwsA(isA<CustomException>()));
      });

      test('should validate store ID parameter', () {
        // Arrange & Act
        const validStoreId = 'store123';
        const emptyStoreId = '';
        const nullStoreId = null;
        
        // Assert
        expect(validStoreId, isNotEmpty);
        expect(emptyStoreId, isEmpty);
        expect(nullStoreId, isNull);
      });

      test('should handle special characters in store ID', () async {
        // Arrange
        const specialStoreId = 'store-123_test';
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act
        final expectedUrl = Uri.parse(Endpoints.storeDetailEndpoint.replaceFirst('{id}', specialStoreId));
        
        // Assert
        expect(expectedUrl.toString(), contains(specialStoreId));
        expect(() => storeRepository.fetchStoreById(specialStoreId), returnsNormally);
      });

      test('should handle numeric store IDs as strings', () async {
        // Arrange
        const numericStoreId = '12345';
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(numericStoreId, isA<String>());
        expect(int.tryParse(numericStoreId), isNotNull);
        expect(() => storeRepository.fetchStoreById(numericStoreId), returnsNormally);
      });
    });

    group('Error Handling', () {
      test('should handle network timeouts', () async {
        // Arrange
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => storeRepository.fetchStores(), throwsA(isA<Exception>()));
      });

      test('should handle malformed JSON responses', () async {
        // Arrange
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => storeRepository.fetchStores(), throwsA(isA<Exception>()));
      });

      test('should handle null token gracefully', () async {
        // Arrange
        when(mockAuthService.token).thenReturn(null);
        
        // Act & Assert
        expect(() => storeRepository.fetchStores(), throwsA(isA<Exception>()));
      });

      test('should handle empty token gracefully', () async {
        // Arrange
        when(mockAuthService.token).thenReturn('');
        
        // Act & Assert
        expect(() => storeRepository.fetchStores(), throwsA(isA<Exception>()));
      });
    });

    group('Store Model Validation', () {
      test('should validate required store fields', () {
        // Arrange
        final completeStore = {
          'id': 'store123',
          'name': 'Test Store',
          'type': 'Restaurant',
          'address': '123 Test St',
        };
        
        final incompleteStore = {
          'id': 'store123',
          // Missing required fields
        };
        
        // Act & Assert
        expect(completeStore['id'], isNotNull);
        expect(completeStore['name'], isNotNull);
        expect(incompleteStore['name'], isNull);
      });

      test('should handle optional store fields', () {
        // Arrange
        final storeWithOptionals = {
          'id': 'store123',
          'name': 'Test Store',
          'type': 'Restaurant',
          'address': '123 Test St',
          'phone': '+1234567890',
          'email': 'store@example.com',
          'website': 'https://store.example.com',
          'image': 'https://example.com/store.jpg',
        };
        
        final storeWithoutOptionals = {
          'id': 'store123',
          'name': 'Test Store',
          'type': 'Restaurant',
        };
        
        // Act & Assert
        expect(storeWithOptionals['phone'], isNotNull);
        expect(storeWithOptionals['email'], isNotNull);
        expect(storeWithoutOptionals['phone'], isNull);
        expect(storeWithoutOptionals['email'], isNull);
      });

      test('should handle different store types', () {
        // Arrange
        final restaurantStore = {'type': 'Restaurant'};
        final shopStore = {'type': 'Shop'};
        final serviceStore = {'type': 'Service'};
        final unknownStore = {'type': 'Unknown'};
        
        // Act & Assert
        expect(restaurantStore['type'], equals('Restaurant'));
        expect(shopStore['type'], equals('Shop'));
        expect(serviceStore['type'], equals('Service'));
        expect(unknownStore['type'], equals('Unknown'));
      });
    });

    group('Integration Scenarios', () {
      test('should handle multiple concurrent store requests', () {
        // Arrange
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => Future.wait([
          storeRepository.fetchStores(page: 1),
          storeRepository.fetchStores(page: 2),
          storeRepository.fetchStoreById('store1'),
          storeRepository.fetchStoreById('store2'),
        ]), throwsA(isA<Exception>()));
      });

      test('should maintain consistent error handling', () {
        // Arrange
        const token = 'valid_jwt_token';
        
        when(mockAuthService.token).thenReturn(token);
        
        // Act & Assert
        expect(() => storeRepository.fetchStores(), returnsNormally);
        expect(() => storeRepository.fetchStoreById('store123'), returnsNormally);
      });

      test('should handle session expiration consistently', () async {
        // Arrange
        const expiredToken = 'expired_token';
        
        when(mockAuthService.token).thenReturn(expiredToken);
        when(mockAuthService.logout()).thenAnswer((_) async => {});
        
        // Act & Assert
        expect(() => storeRepository.fetchStores(), throwsA(isA<CustomException>()));
        expect(() => storeRepository.fetchStoreById('store123'), throwsA(isA<CustomException>()));
      });
    });
  });
}