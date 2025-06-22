import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:park_wallet/constants/endpoints.dart';
import 'package:park_wallet/data/dto/transaction.dart';
import 'package:park_wallet/global/custom_exception.dart';
import 'package:park_wallet/repositories/history_repository.dart';
import 'package:park_wallet/services/auth_service.dart';

import 'history_repository_test.mocks.dart';

@GenerateMocks([http.Client, AuthService])
void main() {
  group('HistoryRepository Tests', () {
    late HistoryRepository historyRepository;
    late MockClient mockClient;
    late MockAuthService mockAuthService;

    setUp(() {
      Get.testMode = true;
      mockClient = MockClient();
      mockAuthService = MockAuthService();
      
      // Register mock AuthService with GetX
      Get.put<AuthService>(mockAuthService);
      
      historyRepository = HistoryRepository();
    });

    tearDown(() {
      Get.reset();
    });

    group('fetchHistory Tests', () {
      test('should fetch transaction history successfully', () async {
        // Arrange
        const userId = '123';
        const token = 'valid_token';
        
        when(mockAuthService.userId).thenReturn(userId);
        when(mockAuthService.token).thenReturn(token);
        
        final mockResponseBody = '''
        {
          "transactions": [
            {
              "id": 1,
              "amount": 25.50,
              "description": "Coffee purchase",
              "date": "2024-01-15T10:30:00Z",
              "type": "debit",
              "storeId": 1,
              "storeName": "Coffee Shop"
            },
            {
              "id": 2,
              "amount": 100.00,
              "description": "Balance top-up",
              "date": "2024-01-14T09:15:00Z",
              "type": "credit",
              "storeId": null,
              "storeName": null
            }
          ],
          "totalPages": 5,
          "currentPage": 1
        }
        ''';
        
        final mockResponse = http.Response(
          mockResponseBody,
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await historyRepository.fetchHistory(page: 1, size: 10);

        // Assert
        expect(result, isA<List<Transaction>>());
        expect(result.length, equals(2));
        
        expect(result[0].id, equals(1));
        expect(result[0].amount, equals(25.50));
        expect(result[0].description, equals('Coffee purchase'));
        expect(result[0].type, equals('debit'));
        expect(result[0].storeName, equals('Coffee Shop'));
        
        expect(result[1].id, equals(2));
        expect(result[1].amount, equals(100.00));
        expect(result[1].description, equals('Balance top-up'));
        expect(result[1].type, equals('credit'));
        expect(result[1].storeName, isNull);
        
        verify(mockClient.get(
          Uri.parse('${Endpoints.historyEndpoint}?userId=$userId&page=1&size=10'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )).called(1);
      });

      test('should fetch history with default pagination parameters', () async {
        // Arrange
        const userId = '123';
        const token = 'valid_token';
        
        when(mockAuthService.userId).thenReturn(userId);
        when(mockAuthService.token).thenReturn(token);
        
        final mockResponse = http.Response(
          '{"transactions": [], "totalPages": 0, "currentPage": 1}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await historyRepository.fetchHistory();

        // Assert
        expect(result, isA<List<Transaction>>());
        expect(result.isEmpty, isTrue);
        
        verify(mockClient.get(
          Uri.parse('${Endpoints.historyEndpoint}?userId=$userId&page=1&size=10'),
          headers: anyNamed('headers'),
        )).called(1);
      });

      test('should fetch history with custom pagination', () async {
        // Arrange
        const userId = '456';
        const token = 'valid_token';
        
        when(mockAuthService.userId).thenReturn(userId);
        when(mockAuthService.token).thenReturn(token);
        
        final mockResponse = http.Response(
          '{"transactions": [], "totalPages": 3, "currentPage": 2}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await historyRepository.fetchHistory(page: 2, size: 20);

        // Assert
        expect(result, isA<List<Transaction>>());
        
        verify(mockClient.get(
          Uri.parse('${Endpoints.historyEndpoint}?userId=$userId&page=2&size=20'),
          headers: anyNamed('headers'),
        )).called(1);
      });

      test('should throw CustomException when unauthorized (401)', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('invalid_token');
        
        final mockResponse = http.Response(
          '{"error": "Unauthorized access"}',
          401,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(),
          throwsA(isA<CustomException>().having(
            (e) => e.message,
            'message',
            contains('Unauthorized'),
          )),
        );
      });

      test('should throw CustomException when user not found (404)', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('nonexistent');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponse = http.Response(
          '{"error": "User not found"}',
          404,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(),
          throwsA(isA<CustomException>().having(
            (e) => e.message,
            'message',
            contains('User not found'),
          )),
        );
      });

      test('should throw CustomException when server error (500)', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponse = http.Response(
          '{"error": "Internal server error"}',
          500,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(),
          throwsA(isA<CustomException>().having(
            (e) => e.message,
            'message',
            contains('Internal server error'),
          )),
        );
      });

      test('should handle network timeout', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network timeout'));

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle malformed JSON response', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponse = http.Response(
          'Invalid JSON response',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle empty transaction list', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponse = http.Response(
          '{"transactions": [], "totalPages": 0, "currentPage": 1}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await historyRepository.fetchHistory();

        // Assert
        expect(result, isA<List<Transaction>>());
        expect(result.isEmpty, isTrue);
      });

      test('should handle missing transactions field in response', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponse = http.Response(
          '{"totalPages": 0, "currentPage": 1}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(),
          throwsA(isA<Exception>()),
        );
      });

      test('should include correct headers in request', () async {
        // Arrange
        const userId = '789';
        const token = 'test_token_456';
        
        when(mockAuthService.userId).thenReturn(userId);
        when(mockAuthService.token).thenReturn(token);
        
        final mockResponse = http.Response(
          '{"transactions": [], "totalPages": 0, "currentPage": 1}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        await historyRepository.fetchHistory();

        // Assert
        verify(mockClient.get(
          Uri.parse('${Endpoints.historyEndpoint}?userId=$userId&page=1&size=10'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )).called(1);
      });

      test('should handle transactions with null optional fields', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponseBody = '''
        {
          "transactions": [
            {
              "id": 1,
              "amount": 15.75,
              "description": "Transaction with nulls",
              "date": "2024-01-15T10:30:00Z",
              "type": "debit",
              "storeId": null,
              "storeName": null
            }
          ],
          "totalPages": 1,
          "currentPage": 1
        }
        ''';
        
        final mockResponse = http.Response(
          mockResponseBody,
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await historyRepository.fetchHistory();

        // Assert
        expect(result.length, equals(1));
        expect(result[0].storeId, isNull);
        expect(result[0].storeName, isNull);
      });

      test('should handle large transaction amounts', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponseBody = '''
        {
          "transactions": [
            {
              "id": 1,
              "amount": 999999.99,
              "description": "Large transaction",
              "date": "2024-01-15T10:30:00Z",
              "type": "credit",
              "storeId": 1,
              "storeName": "Big Store"
            }
          ],
          "totalPages": 1,
          "currentPage": 1
        }
        ''';
        
        final mockResponse = http.Response(
          mockResponseBody,
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await historyRepository.fetchHistory();

        // Assert
        expect(result.length, equals(1));
        expect(result[0].amount, equals(999999.99));
      });

      test('should handle special characters in transaction descriptions', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponseBody = '''
        {
          "transactions": [
            {
              "id": 1,
              "amount": 12.50,
              "description": "Café & Açaí \"Premium\" 🍇☕",
              "date": "2024-01-15T10:30:00Z",
              "type": "debit",
              "storeId": 1,
              "storeName": "Café Especial"
            }
          ],
          "totalPages": 1,
          "currentPage": 1
        }
        ''';
        
        final mockResponse = http.Response(
          mockResponseBody,
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await historyRepository.fetchHistory();

        // Assert
        expect(result.length, equals(1));
        expect(result[0].description, equals('Café & Açaí "Premium" 🍇☕'));
        expect(result[0].storeName, equals('Café Especial'));
      });
    });

    group('Error Handling Tests', () {
      test('should handle connection refused error', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Connection refused'));

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Connection refused'),
          )),
        );
      });

      test('should handle DNS resolution error', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Failed host lookup'));

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Authentication Tests', () {
      test('should handle missing user ID', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn(null);
        when(mockAuthService.token).thenReturn('valid_token');

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle missing token', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn(null);

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle empty user ID', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('');
        when(mockAuthService.token).thenReturn('valid_token');

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Pagination Tests', () {
      test('should handle negative page numbers', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponse = http.Response(
          '{"error": "Invalid page number"}',
          400,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(page: -1),
          throwsA(isA<CustomException>()),
        );
      });

      test('should handle zero page size', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponse = http.Response(
          '{"error": "Invalid page size"}',
          400,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () async => await historyRepository.fetchHistory(size: 0),
          throwsA(isA<CustomException>()),
        );
      });

      test('should handle very large page size', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponse = http.Response(
          '{"transactions": [], "totalPages": 0, "currentPage": 1}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await historyRepository.fetchHistory(size: 1000);

        // Assert
        expect(result, isA<List<Transaction>>());
        
        verify(mockClient.get(
          Uri.parse('${Endpoints.historyEndpoint}?userId=123&page=1&size=1000'),
          headers: anyNamed('headers'),
        )).called(1);
      });
    });

    group('Integration Tests', () {
      test('should handle concurrent history requests', () async {
        // Arrange
        when(mockAuthService.userId).thenReturn('123');
        when(mockAuthService.token).thenReturn('valid_token');
        
        final mockResponse = http.Response(
          '{"transactions": [], "totalPages": 0, "currentPage": 1}',
          200,
          headers: {'content-type': 'application/json'},
        );

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final futures = [
          historyRepository.fetchHistory(page: 1),
          historyRepository.fetchHistory(page: 2),
          historyRepository.fetchHistory(page: 3),
        ];
        
        final results = await Future.wait(futures);

        // Assert
        expect(results.length, equals(3));
        for (final result in results) {
          expect(result, isA<List<Transaction>>());
        }
      });
    });
  });
}