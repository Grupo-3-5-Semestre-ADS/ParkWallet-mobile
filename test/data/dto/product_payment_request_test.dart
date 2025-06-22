import 'package:flutter_test/flutter_test.dart';
import 'package:park_wallet/data/dto/product_payment_request.dart';

void main() {
  group('ProductPaymentRequest Tests', () {
    group('Constructor Tests', () {
      test('should create ProductPaymentRequest with required fields', () {
        // Arrange & Act
        final request = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );

        // Assert
        expect(request.productId, equals(123));
        expect(request.quantity, equals(2));
      });

      test('should create ProductPaymentRequest with minimum values', () {
        // Arrange & Act
        final request = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
        );

        // Assert
        expect(request.productId, equals(1));
        expect(request.quantity, equals(1));
      });

      test('should create ProductPaymentRequest with large values', () {
        // Arrange & Act
        final request = ProductPaymentRequest(
          productId: 999999,
          quantity: 100,
        );

        // Assert
        expect(request.productId, equals(999999));
        expect(request.quantity, equals(100));
      });

      test('should create ProductPaymentRequest with zero values', () {
        // Arrange & Act
        final request = ProductPaymentRequest(
          productId: 0,
          quantity: 0,
        );

        // Assert
        expect(request.productId, equals(0));
        expect(request.quantity, equals(0));
      });

      test('should create ProductPaymentRequest with negative values', () {
        // Arrange & Act
        final request = ProductPaymentRequest(
          productId: -1,
          quantity: -5,
        );

        // Assert
        expect(request.productId, equals(-1));
        expect(request.quantity, equals(-5));
      });
    });

    group('toJson Tests', () {
      test('should convert ProductPaymentRequest to JSON correctly', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['productId'], equals(123));
        expect(json['quantity'], equals(2));
      });

      test('should convert ProductPaymentRequest with minimum values to JSON', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 1,
          quantity: 1,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json['productId'], equals(1));
        expect(json['quantity'], equals(1));
      });

      test('should convert ProductPaymentRequest with large values to JSON', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 999999,
          quantity: 100,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json['productId'], equals(999999));
        expect(json['quantity'], equals(100));
      });

      test('should convert ProductPaymentRequest with zero values to JSON', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 0,
          quantity: 0,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json['productId'], equals(0));
        expect(json['quantity'], equals(0));
      });

      test('should convert ProductPaymentRequest with negative values to JSON', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: -1,
          quantity: -5,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json['productId'], equals(-1));
        expect(json['quantity'], equals(-5));
      });

      test('should have correct JSON keys', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json.keys, containsAll(['productId', 'quantity']));
        expect(json.keys.length, equals(2));
      });

      test('should maintain data types in JSON', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json['productId'], isA<int>());
        expect(json['quantity'], isA<int>());
      });
    });

    group('Immutability Tests', () {
      test('should be immutable after creation', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );

        // Act & Assert
        expect(request.productId, equals(123));
        expect(request.quantity, equals(2));
        
        // Fields should remain the same
        expect(request.productId, equals(123));
        expect(request.quantity, equals(2));
      });

      test('should create independent instances', () {
        // Arrange & Act
        final request1 = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );
        
        final request2 = ProductPaymentRequest(
          productId: 456,
          quantity: 5,
        );

        // Assert
        expect(request1.productId, isNot(equals(request2.productId)));
        expect(request1.quantity, isNot(equals(request2.quantity)));
      });
    });

    group('Edge Cases Tests', () {
      test('should handle maximum integer values', () {
        // Arrange
        const maxInt = 9223372036854775807; // Max value for 64-bit signed integer
        
        final request = ProductPaymentRequest(
          productId: maxInt,
          quantity: maxInt,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(request.productId, equals(maxInt));
        expect(request.quantity, equals(maxInt));
        expect(json['productId'], equals(maxInt));
        expect(json['quantity'], equals(maxInt));
      });

      test('should handle minimum integer values', () {
        // Arrange
        const minInt = -9223372036854775808; // Min value for 64-bit signed integer
        
        final request = ProductPaymentRequest(
          productId: minInt,
          quantity: minInt,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(request.productId, equals(minInt));
        expect(request.quantity, equals(minInt));
        expect(json['productId'], equals(minInt));
        expect(json['quantity'], equals(minInt));
      });

      test('should handle typical e-commerce scenarios', () {
        // Arrange - Common product IDs and quantities
        final scenarios = [
          {'productId': 1001, 'quantity': 1}, // Single item
          {'productId': 2002, 'quantity': 3}, // Multiple items
          {'productId': 5555, 'quantity': 10}, // Bulk purchase
          {'productId': 9999, 'quantity': 50}, // Large quantity
        ];

        for (final scenario in scenarios) {
          // Act
          final request = ProductPaymentRequest(
            productId: scenario['productId'] as int,
            quantity: scenario['quantity'] as int,
          );
          final json = request.toJson();

          // Assert
          expect(request.productId, equals(scenario['productId']));
          expect(request.quantity, equals(scenario['quantity']));
          expect(json['productId'], equals(scenario['productId']));
          expect(json['quantity'], equals(scenario['quantity']));
        }
      });

      test('should handle business logic edge cases', () {
        // Arrange - Edge cases that might occur in business logic
        final edgeCases = [
          {'productId': 0, 'quantity': 1}, // Invalid product ID
          {'productId': 123, 'quantity': 0}, // Zero quantity
          {'productId': -1, 'quantity': 1}, // Negative product ID
          {'productId': 123, 'quantity': -1}, // Negative quantity (refund?)
        ];

        for (final edgeCase in edgeCases) {
          // Act
          final request = ProductPaymentRequest(
            productId: edgeCase['productId'] as int,
            quantity: edgeCase['quantity'] as int,
          );
          final json = request.toJson();

          // Assert
          expect(request.productId, equals(edgeCase['productId']));
          expect(request.quantity, equals(edgeCase['quantity']));
          expect(json['productId'], equals(edgeCase['productId']));
          expect(json['quantity'], equals(edgeCase['quantity']));
        }
      });
    });

    group('JSON Consistency Tests', () {
      test('should produce consistent JSON for same data', () {
        // Arrange
        final request1 = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );
        
        final request2 = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );

        // Act
        final json1 = request1.toJson();
        final json2 = request2.toJson();

        // Assert
        expect(json1['productId'], equals(json2['productId']));
        expect(json1['quantity'], equals(json2['quantity']));
      });

      test('should produce different JSON for different data', () {
        // Arrange
        final request1 = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );
        
        final request2 = ProductPaymentRequest(
          productId: 456,
          quantity: 5,
        );

        // Act
        final json1 = request1.toJson();
        final json2 = request2.toJson();

        // Assert
        expect(json1['productId'], isNot(equals(json2['productId'])));
        expect(json1['quantity'], isNot(equals(json2['quantity'])));
      });

      test('should maintain JSON structure across multiple calls', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );

        // Act
        final json1 = request.toJson();
        final json2 = request.toJson();
        final json3 = request.toJson();

        // Assert
        expect(json1, equals(json2));
        expect(json2, equals(json3));
        expect(json1, equals(json3));
      });
    });

    group('Performance Tests', () {
      test('should handle multiple instance creation efficiently', () {
        // Arrange & Act
        final requests = <ProductPaymentRequest>[];
        
        for (int i = 0; i < 1000; i++) {
          requests.add(ProductPaymentRequest(
            productId: i,
            quantity: i % 10 + 1,
          ));
        }

        // Assert
        expect(requests.length, equals(1000));
        expect(requests.first.productId, equals(0));
        expect(requests.last.productId, equals(999));
      });

      test('should handle multiple JSON conversions efficiently', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );

        // Act
        final jsonList = <Map<String, dynamic>>[];
        for (int i = 0; i < 1000; i++) {
          jsonList.add(request.toJson());
        }

        // Assert
        expect(jsonList.length, equals(1000));
        for (final json in jsonList) {
          expect(json['productId'], equals(123));
          expect(json['quantity'], equals(2));
        }
      });
    });

    group('Type Safety Tests', () {
      test('should maintain type safety for productId', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );

        // Act & Assert
        expect(request.productId, isA<int>());
        expect(request.productId.runtimeType, equals(int));
      });

      test('should maintain type safety for quantity', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );

        // Act & Assert
        expect(request.quantity, isA<int>());
        expect(request.quantity.runtimeType, equals(int));
      });

      test('should maintain type safety in JSON output', () {
        // Arrange
        final request = ProductPaymentRequest(
          productId: 123,
          quantity: 2,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json['productId'], isA<int>());
        expect(json['quantity'], isA<int>());
        expect(json['productId'].runtimeType, equals(int));
        expect(json['quantity'].runtimeType, equals(int));
      });
    });
  });
}